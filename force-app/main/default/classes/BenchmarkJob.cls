public without sharing class BenchmarkJob implements System.Queueable, System.Finalizer {
	@TestVisible
	private static Environment environment = new Environment();

	private Benchmark__c benchmarkRecord;
	private BenchmarkJobSetting__mdt currentJob;
	private Map<String, BenchmarkJobSetting__mdt> pending;

	public BenchmarkJob() {
		this.pending = BenchmarkJobSettingSelector.getAll();
		this.getNext();
	}

	public void execute(System.QueueableContext context) {
		System.attachFinalizer(this);
		// Is the Benchmark job enabled? If not, terminate the job
		if (this.shouldRun() == true) {
			// Instantiate a Benchmark__c record using the settings record
			this.benchmarkRecord = this.initBenchmarkRecord();
			// Create an instance of the Benchmarkable instance
			Benchmarkable instance = this.initBenchmarkable();
			// Run the setup method
			this.doSetup(instance);
			// Run the benchmark method
			this.doBenchmark(instance);
		}
	}

	public void execute(System.FinalizerContext context) {
		try {
			// Prevent inserting empty benchmark records
			if (this.benchmarkRecord != null) {
				this.captureErrorDetails(context);
				Database.insert(this.benchmarkRecord, System.AccessLevel.SYSTEM_MODE);
			}
			// Launch the next iteration of the job
			this.getNext()?.launch();
		} catch (Exception error) {
			System.debug(System.LoggingLevel.ERROR, error);
		}
	}

	public Id launch() {
		if (this.currentJob != null) {
			Id jobId = System.enqueueJob(this);
			System.debug(System.LoggingLevel.INFO, 'Launching new job: ' + jobId);
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
		if (this.currentJob?.Active__c == false) {
			// If so, skip the currentJob job, and recurse to find the next job in the chain
			System.debug(System.LoggingLevel.FINEST, 'Skipping inactive job');
			this.getNext();
		}
		System.debug(System.LoggingLevel.FINEST, 'Next GarbageCollector__mdt job: ' + this.currentJob?.DeveloperName);
		System.debug(System.LoggingLevel.FINEST, 'Pending GarbageCollector__mdt jobs: ' + this.pending?.keySet());
		return this;
	}

	private Benchmark__c initBenchmarkRecord() {
		// Create a benchmark record based on the details of the corresponding cmdt record
		return new Benchmark__c(); // TODO!
	}

	private Benchmarkable initBenchmarkable() {
		// Initialize a Benchmarkable instance, using the apex class name stored in the cmdt
		return null; // TODO!
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
		// Returns true if the current job is eligible to be run
		// Returns false if Inactive,
		// or in an excluded sandbox,
		// or if in a production environment w/"Run in Production" set to false
		return true; // TODO!
	}

	// **** INNER **** //
	public virtual class Environment {
		public virtual String getSandboxName() {
			System.Url url = System.Url.getOrgDomainUrl();
			return System.DomainParser.parse(url)?.getSandboxName();
		}

		public Boolean isSandbox() {
			return this.getSandboxName() != null;
		}
	}
}
