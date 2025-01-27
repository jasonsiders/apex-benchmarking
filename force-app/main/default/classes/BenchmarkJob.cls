@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing virtual class BenchmarkJob implements System.Queueable, System.Finalizer {
	/**
	 * The BenchmarkJob queueable runs on the BenchmarkJobSetting__mdt custom metadata type.
	 * Each record represents a single job to be run, and will invoke 1 Queueable run,
	 * provided that it is active & eligible to be run in the current environment.
	 * The BenchmarkJob dynamically instantiates a Benchmarkable instance,
	 * and uses this instance to perform measurable tasks to be recorded in a Benchmark__c record.
	 * Developers can run reports on Benchmark__c records over time to track changes in performance over time.
	 **/
	@TestVisible
	private static Environment environment = new Environment();

	private Benchmark__c benchmarkRecord;
	private BenchmarkJobSetting__mdt currentJob;
	private Map<String, BenchmarkJobSetting__mdt> pending;

	global BenchmarkJob(Set<String> jobNames) {
		// Retrieve the specified list of Benchmark Job Setting records,
		// and load the first active one for processing
		this.pending = BenchmarkJobSettingSelector.get(jobNames);
		this.getNext();
	}

	global BenchmarkJob() {
		// This overload processes all defined Benchmark Job Settings records
		this(BenchmarkJobSettingSelector.getAll()?.keySet());
	}

	global void execute(System.QueueableContext context) {
		System.Savepoint savepoint = Database.setSavepoint();
		try {
			System.attachFinalizer(this);
			this.benchmarkRecord = this.initBenchmarkRecord();
			Benchmarkable instance = this.initBenchmarkable();
			this.doSetup(instance);
			this.doBenchmark(instance);
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

	private void doBenchmark(Benchmarkable instance) {
		this.benchmarkRecord.BenchmarkStartedAt__c = Limits.getCpuTime();
		instance?.benchmark();
		this.benchmarkRecord.BenchmarkCompletedAt__c = Limits.getCpuTime();
	}

	private void doSetup(Benchmarkable instance) {
		// Run the current instance's setup method
		this.benchmarkRecord.SetupStartedAt__c = Limits.getCpuTime();
		instance?.setup();
		this.benchmarkRecord.SetupCompletedAt__c = Limits.getCpuTime();
	}

	private BenchmarkJob getNext() {
		// Get the next BenchmarkJobSetting__mdt to process
		String jobName = (this.pending?.isEmpty() == false) ? this.pending?.values()?.get(0)?.DeveloperName : null;
		this.currentJob = BenchmarkJobSettingSelector.get(jobName);
		// Remove the currentJob job from the list of pending jobs
		this.pending?.remove(jobName);
		// Validate that the job's settings record is still active
		if (this.currentJob != null && this.shouldRun() == false) {
			// If so, skip the currentJob job, and recurse to find the next job in the chain
			this.getNext();
		}
		System.debug(System.LoggingLevel.FINEST, 'Next GarbageCollector__mdt job: ' + this.currentJob?.DeveloperName);
		System.debug(System.LoggingLevel.FINEST, 'Pending GarbageCollector__mdt jobs: ' + this.pending?.keySet());
		return this;
	}

	private void logAndRethrow(Exception error) {
		String msg = error + '\n' + error?.getStackTraceString();
		System.debug(System.LoggingLevel.ERROR, msg);
		throw error;
	}

	private Benchmark__c initBenchmarkRecord() {
		// Create a benchmark record based on the details of the corresponding cmdt record
		return new Benchmark__c(
			Description__c = this.currentJob?.Description__c,
			JobLabel__c = this.currentJob?.MasterLabel,
			JobName__c = this.currentJob?.DeveloperName,
			Operation__c = this.currentJob?.Operation__c,
			SObjectType__c = this.currentJob?.SObjectType__r?.QualifiedApiName
		);
	}

	private Benchmarkable initBenchmarkable() {
		// Initialize a Benchmarkable instance, using the apex class name stored in the cmdt
		String instanceName = this.currentJob?.ApexClass__c;
		Type instanceType = Type.forName(instanceName);
		Benchmarkable instance = (Benchmarkable) instanceType?.newInstance();
		if (instance != null) {
			return instance;
		} else {
			throw new System.IllegalArgumentException(instanceName + ' is not of type Benchmarkable');
		}
	}

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

	private Boolean shouldRun() {
		// Returns true if the current job is active & eligible to be run in the current environment
		Boolean result = (this.currentJob?.Active__c == true && BenchmarkJob.environment?.isEligible(this.currentJob));
		System.debug(LoggingLevel.FINEST, this.currentJob?.DeveloperName + ' is eligible? ' + result);
		return result;
	}

	// **** INNER **** //
	global virtual class Environment {
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
}
