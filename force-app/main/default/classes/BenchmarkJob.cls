@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing virtual class BenchmarkJob implements System.Queueable, System.Finalizer {
	/**
	 * The BenchmarkJob queueable runs on the BenchmarkJobSetting__mdt custom metadata type.
	 * Each record represents a single job to be run, and will invoke 1 Queueable run,
	 * provided that it is active & eligible to be run in the current environment.
	 * The BenchmarkJob dynamically instantiates a "Benchmarkable" Apex Clas, or a Flow (depending on the configuration).
	 * It uses this artifact to perform measurable tasks to be recorded in a Benchmark__c record.
	 * Developers can run reports on Benchmark__c records over time to track changes in performance over time.
	 **/

	// **** STATIC **** //
	private static final String FLOW_ERROR_PROPERTY = 'error';
	@TestVisible
	private static Environment Environment = new BenchmarkJob.Environment();
	@TestVisible
	private static FlowRunner FlowRunner = new BenchmarkJob.FlowRunner();

	global static void validate(String jobName) {
		// Checks if the given job is active & eligible to be run in the current environment
		// If not, throws an IneligibleJobException
		BenchmarkJobSetting__mdt job = BenchmarkJobSettingSelector.get(jobName);
		if (job != null && job?.Active__c == false) {
			String msg = jobName + ' is inactive';
			throw new BenchmarkJob.IneligibleJobException(msg);
		} else if (job != null && BenchmarkJob.environment?.isEligible(job) == false) {
			String msg = jobName + ' is ineligible to be run in this environment';
			throw new BenchmarkJob.IneligibleJobException(msg);
		}
	}

	// **** MEMBERS **** //
	private Benchmark__c benchmarkRecord;
	private BenchmarkJobSetting__mdt currentJob;
	private Map<String, BenchmarkJobSetting__mdt> pending;

	// **** CONSTRUCTORS **** //
	global BenchmarkJob(Set<String> jobNames) {
		// Retrieve the specified list of Benchmark Job Setting records,
		// and load the first active one for processing
		this.pending = BenchmarkJobSettingSelector.get(jobNames);
		this.getNext();
	}

	global BenchmarkJob(String jobName) {
		// This overload processes the specified Benchmark Job Settings record
		this(new Set<String>{ jobName });
	}

	global BenchmarkJob() {
		// This overload processes all defined Benchmark Job Settings records
		this(BenchmarkJobSettingSelector.getAll()?.keySet());
	}

	// **** METHODS **** //
	global void execute(System.QueueableContext context) {
		System.Savepoint savepoint = Database.setSavepoint();
		try {
			System.attachFinalizer(this);
			this.initBenchmarkRecord();
			AbstractProcessor processor = this.initProcessor();
			processor?.process();
		} catch (Exception error) {
			this.logAndRethrow(error);
		} finally {
			Database.rollback(savepoint);
		}
	}

	global void execute(System.FinalizerContext context) {
		try {
			// Prevent inserting empty benchmark records
			if (this.benchmarkRecord != null) {
				this.captureErrorDetails(context);
				Database.insert(this.benchmarkRecord, System.AccessLevel.SYSTEM_MODE);
				System.debug(LoggingLevel.FINEST, 'Saved Benchmark: ' + this.benchmarkRecord);
			}
			// Launch the next iteration of the job
			this.getNext()?.launch();
		} catch (Exception error) {
			this.logAndRethrow(error);
		}
	}

	global virtual Id launch() {
		if (this.currentJob != null) {
			Id jobId = System.enqueueJob(this);
			System.debug(System.LoggingLevel.FINEST, 'Launching new job: ' + jobId);
			return jobId;
		} else {
			return null;
		}
	}

	// **** PRIVATE **** //
	private void captureErrorDetails(System.FinalizerContext context) {
		// Record any errors that resulted in the process
		if (context?.getResult() == System.ParentJobResult.UNHANDLED_EXCEPTION) {
			System.Exception error = context?.getException();
			this.benchmarkRecord.Error__c = error?.getTypeName();
			this.benchmarkRecord.ErrorDetail__c = String.join(
				new List<String>{ error?.getMessage(), error?.getStackTraceString() },
				'\n'
			);
		}
	}

	private BenchmarkJob getNext() {
		try {
			// Get the next BenchmarkJobSetting__mdt to process
			String jobName = (this.pending?.isEmpty() == false) ? this.pending?.values()?.get(0)?.DeveloperName : null;
			this.currentJob = BenchmarkJobSettingSelector.get(jobName);
			// Remove the currentJob job from the list of pending jobs
			this.pending?.remove(jobName);
			// Validate that the current settings record is active & eligible to be run in this environment
			BenchmarkJob.validate(jobName);
			// If an exception wasn't thrown, return the current job instance
			return this;
		} catch (BenchmarkJob.IneligibleJobException error) {
			// If so, skip the current job, and recurse to find the next job in the chain
			return this.getNext();
		} finally {
			System.debug(System.LoggingLevel.FINEST, 'Next Benchmark Job: ' + this.currentJob?.DeveloperName);
			System.debug(System.LoggingLevel.FINEST, 'Pending Benchmark Jobs: ' + this.pending?.keySet());
		}
	}

	protected String getSObjectType() {
		// Returns the value of the SObjectType from the current custom metadata record
		// This is primarily stored in an EntityDefinition dropdown,
		// but it can also be stored in a free text field, to support SObjects not listed in that dropdown
		return this.currentJob?.SObjectType__r?.QualifiedApiName ?? this.currentJob?.SObjectTypeName__c;
	}

	protected void initBenchmarkRecord() {
		// Create a benchmark record based on the details of the corresponding cmdt record
		this.benchmarkRecord = new Benchmark__c(
			Description__c = this.currentJob?.Description__c,
			JobLabel__c = this.currentJob?.MasterLabel,
			JobName__c = this.currentJob?.DeveloperName,
			Operation__c = this.currentJob?.Operation__c,
			SObjectType__c = this.getSObjectType()
		);
	}

	private AbstractProcessor initProcessor() {
		return (String.isNotBlank(this.currentJob?.ApexClass__c))
			? (AbstractProcessor) new ApexProcessor(this.currentJob, this.benchmarkRecord)
			: (AbstractProcessor) new FlowProcessor(this.currentJob, this.benchmarkRecord);
	}

	private void logAndRethrow(Exception error) {
		String msg = error + '\n' + error?.getStackTraceString();
		System.debug(System.LoggingLevel.ERROR, msg);
		throw error;
	}

	// **** INNER **** //
	private abstract class AbstractProcessor {
		// This class contains logic central to the processing of Benchmark Jobs,
		// regardless of how these jobs are run (Apex or Flow)
		protected BenchmarkJobSetting__mdt setting;
		protected Benchmark__c record;

		protected AbstractProcessor(BenchmarkJobSetting__mdt setting, Benchmark__c record) {
			this.setting = setting;
			this.record = record;
		}

		public abstract void process();

		protected void stamp(SObjectField field) {
			// Use this method to record the current Limits.getCpuTime() value on a certain SObjectField
			this.record?.put(field, Limits.getCpuTime());
		}
	}

	private class ApexProcessor extends AbstractProcessor {
		// This class is responsible for processing Benchmark Jobs with an ApexClass__c value
		// The listed Apex Class is instantiated as a Benchmarkable object, and then its methods are called
		// Along the way, the processor records start & stop times for each step.
		public ApexProcessor(BenchmarkJobSetting__mdt setting, Benchmark__c record) {
			super(setting, record);
		}

		public override void process() {
			Benchmarkable instance = this.initBenchmarkable();
			this.stamp(Benchmark__c.SetupStartedAt__c);
			instance?.setup();
			this.stamp(Benchmark__c.SetupCompletedAt__c);
			this.stamp(Benchmark__c.BenchmarkStartedAt__c);
			instance?.benchmark();
			this.stamp(Benchmark__c.BenchmarkCompletedAt__c);
		}

		private Benchmarkable initBenchmarkable() {
			// Initialize a Benchmarkable instance, using the apex class name stored in the cmdt
			String instanceName = this.setting?.ApexClass__c ?? 'null';
			Type instanceType = Type.forName(instanceName);
			Benchmarkable instance = (Benchmarkable) instanceType?.newInstance();
			if (instance != null) {
				return instance;
			} else {
				throw new System.IllegalArgumentException(instanceName + ' is not of type Benchmarkable');
			}
		}
	}

	@TestVisible
	private virtual class Environment {
		// Responsible for determining the current environment type
		// ie., Production vs. Sandbox, and if Sandbox, which one,
		// as well as whether a given Benchmark Job is eligible to be run
		public virtual String getSandboxName() {
			System.Url url = System.Url.getOrgDomainUrl();
			return System.DomainParser.parse(url)?.getSandboxName();
		}

		public Boolean isEligible(BenchmarkJobSetting__mdt setting) {
			if (this.isSandbox() == true) {
				// Check the configured list of excluded sandboxes to see if the current one is listed
				String currentSandbox = this.getSandboxName();
				String excluded = setting?.ExcludedSandboxes__c?.deleteWhitespace();
				List<String> blacklist = excluded?.split('\\,') ?? new List<String>();
				return new Set<String>(blacklist)?.contains(currentSandbox) == false;
			} else {
				// Only run if "Run in Production" is checked
				return setting?.RunInProduction__c == true;
			}
		}

		public Boolean isSandbox() {
			return this.getSandboxName() != null;
		}
	}

	@TestVisible
	private virtual class FlowProcessor extends AbstractProcessor {
		// This class is responsible for processing Benchmark Jobs with a Flow__c value
		// The listed Flow is dynamically instantiated and ran
		// Before the flow runs, the SetupStartedAt__c value is set;
		// After the flow runs, the BenchmarkCompletedAt__c value is set
		// Developers must use the InvocableStartBenchmark class
		// to set values for SetupCompletedAt__c & BenchmarkStartedAt__c
		public FlowProcessor(BenchmarkJobSetting__mdt setting, Benchmark__c record) {
			super(setting, record);
			// Store a reference to the current Benchmark Record for the InvocableStartBenchmark class to reference
			InvocableStartBenchmark.currentRecord = this.record;
		}

		public override virtual void process() {
			this.stamp(Benchmark__c.SetupStartedAt__c);
			String flowName = this.setting?.Flow__c;
			BenchmarkJob.flowRunner?.run(flowName);
			this.stamp(Benchmark__c.BenchmarkCompletedAt__c);
			this.reconcileTimestamps();
		}

		private void reconcileTimestamps() {
			// This class automatically adds the SetupStartedAt__c and BenchmarkCompletedAt__c timestamps,
			// but relies on subscribers to use the InvocableBenchmarkStart class
			// to manually set the SetupCompletedAt__c and BenchmarkStartedAt__c timestamps.
			// If they fail to do this, provide default values instead of leaving null
			Decimal defaultValue = this.record?.SetupStartedAt__c;
			this.record.SetupCompletedAt__c = this.record.SetupCompletedAt__c ?? defaultValue;
			this.record.BenchmarkStartedAt__c = this.record.BenchmarkStartedAt__c ?? defaultValue;
		}
	}

	@TestVisible
	private virtual class FlowRunner {
		// This class provides a simple interface for interacting with autolaunched flows from apex
		// It's mostly used to give tests a seam to mock Flow execution,
		// since this package currently does not contain any flows
		public void run(String flowName) {
			Flow.Interview interview = this.createInterview(flowName);
			interview?.start();
			this.handleFlowErrors(interview);
		}

		protected virtual Flow.Interview createInterview(String flowName) {
			return Flow.Interview.createInterview(flowName, new Map<String, Object>{});
		}

		protected virtual String getFlowErrors(Flow.Interview interview) {
			// Retrieves an error message stored in the FLOW_ERROR_PROPERTY
			return (String) interview?.getVariableValue(FLOW_ERROR_PROPERTY);
		}

		protected void handleFlowErrors(Flow.Interview interview) {
			// Note: By default, flows throw a generic System.FlowException: "An unhandled fault has occurred".
			// To get a readable error message, subscribers should use a fault path to store the {!$Flow.FaultMessage}
			// in an output property, named in the FLOW_ERROR_PROPERTY constant.
			// The class will retrieve the value of this error property after running the flow.
			// If the error property has a value, use it to generate/throw a System.FlowException.
			String error = this.getFlowErrors(interview);
			if (error != null) {
				throw new System.FlowException(error);
			}
		}
	}

	global class IneligibleJobException extends Exception {
		// This Exception indicates that an instance of a Benchmark Job is ineligible to be run
		// It could be thrown if any of the following are true:
		// - The job is not "Active__c"
		// - The job does not have "RunInProduction__c", and it's in a Production environment
		// - The current Sandbox environment is listed in "ExcludedSandboxes__c"
	}
}
