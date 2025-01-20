@IsTest
private class BenchmarkJobTest {
	@IsTest
	static void shouldRunBenchmarkJob() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.ExampleBenchmarkable.class);

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		// Verify that the job saved the run results in a Benchmark record
		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(1, results?.size(), 'Wrong # of results');
		Benchmark__c result = results?.get(0);
		Assert.areEqual(setting?.MasterLabel, result?.JobLabel__c, 'Wrong JobLabel__c');
		Assert.areEqual(setting?.DeveloperName, result?.JobName__c, 'Wrong JobName__c');
		Assert.areEqual(setting?.Operation__c, result?.Operation__c, 'Wrong Operation__c');
		Assert.areEqual(setting?.SObjectType__r.QualifiedApiName, result?.SObjectType__c, 'Wrong SObjectType__c');
		Assert.areEqual(null, result?.Error__c, 'Should not have Error__c');
		Assert.areNotEqual(null, result?.SetupStartedAt__c, 'Missing SetupStartedAt__c');
		Assert.areNotEqual(null, result?.SetupCompletedAt__c, 'Missing SetupCompletedAt__c');
		Assert.areNotEqual(null, result?.BenchmarkStartedAt__c, 'Missing BenchmarkStartedAt__c');
		Assert.areNotEqual(null, result?.BenchmarkCompletedAt__c, 'Missing BenchmarkCompletedAt__c');
		// Verify that any records processed in the job were rolled back
		Assert.areEqual(true, [SELECT Id FROM Account]?.isEmpty(), 'Did not rollback Account(s)');
		Assert.areEqual(true, [SELECT Id FROM Case]?.isEmpty(), 'Did not rollback Case(s)');
	}

	@IsTest
	static void shouldHandleErrorsDuringInSetupMethod() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.SetupFail.class);

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		// Verify that the job saved the run results in a Benchmark record
		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(1, results?.size(), 'Wrong # of results');
		Benchmark__c result = results?.get(0);
		Assert.areEqual(setting?.DeveloperName, result?.JobName__c, 'Wrong JobName__c');
		Assert.areNotEqual(null, result?.Error__c, 'Missing Error__c');
		Assert.areNotEqual(null, result?.SetupStartedAt__c, 'Missing SetupStartedAt__c');
		Assert.areEqual(null, result?.SetupCompletedAt__c, 'Should not have SetupCompletedAt__c');
		Assert.areEqual(null, result?.BenchmarkStartedAt__c, 'Should not have BenchmarkStartedAt__c');
		Assert.areEqual(null, result?.BenchmarkCompletedAt__c, 'Should not have BenchmarkCompletedAt__c');
		// Verify that any records processed in the job were rolled back
		Assert.areEqual(true, [SELECT Id FROM Account]?.isEmpty(), 'Did not rollback Account(s)');
		Assert.areEqual(true, [SELECT Id FROM Case]?.isEmpty(), 'Did not rollback Case(s)');
	}

	@IsTest
	static void shouldHandleErrorsInBenchmarkMethod() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.BenchmarkFail.class);

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		// Verify that the job saved the run results in a Benchmark record
		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(1, results?.size(), 'Wrong # of results');
		Benchmark__c result = results?.get(0);
		Assert.areEqual(setting?.DeveloperName, result?.JobName__c, 'Wrong JobName__c');
		Assert.areNotEqual(null, result?.Error__c, 'Missing Error__c');
		Assert.areNotEqual(null, result?.SetupStartedAt__c, 'Missing SetupStartedAt__c');
		Assert.areNotEqual(null, result?.SetupCompletedAt__c, 'Should not have SetupCompletedAt__c');
		Assert.areNotEqual(null, result?.BenchmarkStartedAt__c, 'Should not have BenchmarkStartedAt__c');
		Assert.areEqual(null, result?.BenchmarkCompletedAt__c, 'Should not have BenchmarkCompletedAt__c');
		// Verify that any records processed in the job were rolled back
		Assert.areEqual(true, [SELECT Id FROM Account]?.isEmpty(), 'Did not rollback Account(s)');
		Assert.areEqual(true, [SELECT Id FROM Case]?.isEmpty(), 'Did not rollback Case(s)');
	}

	@IsTest
	static void shouldHandleMissingApexClassName() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(null);
		setting.DeveloperName = 'Test_Setting';

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(1, results?.size(), 'Wrong # of results');
		Benchmark__c result = results?.get(0);
		Assert.areEqual(setting?.DeveloperName, result?.JobName__c, 'Wrong JobName__c');
		Assert.areNotEqual(null, result?.Error__c, 'Missing Error__c');
		Assert.areEqual(null, result?.SetupStartedAt__c, 'Missing SetupStartedAt__c');
		Assert.areEqual(null, result?.SetupCompletedAt__c, 'Should not have SetupCompletedAt__c');
		Assert.areEqual(null, result?.BenchmarkStartedAt__c, 'Should not have BenchmarkStartedAt__c');
		Assert.areEqual(null, result?.BenchmarkCompletedAt__c, 'Should not have BenchmarkCompletedAt__c');
	}

	@IsTest
	static void shouldHandleInvalidApexClassName() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.ExampleBenchmarkable.class);
		setting.ApexClass__c = 'asdflkjasdflkjadsf'; // ! Not a real apex class name
		setting.DeveloperName = setting?.ApexClass__c;

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(1, results?.size(), 'Wrong # of results');
		Benchmark__c result = results?.get(0);
		Assert.areEqual(setting?.DeveloperName, result?.JobName__c, 'Wrong JobName__c');
		Assert.areNotEqual(null, result?.Error__c, 'Missing Error__c');
		Assert.areEqual(null, result?.SetupStartedAt__c, 'Missing SetupStartedAt__c');
		Assert.areEqual(null, result?.SetupCompletedAt__c, 'Should not have SetupCompletedAt__c');
		Assert.areEqual(null, result?.BenchmarkStartedAt__c, 'Should not have BenchmarkStartedAt__c');
		Assert.areEqual(null, result?.BenchmarkCompletedAt__c, 'Should not have BenchmarkCompletedAt__c');
	}

	@IsTest
	static void shouldHandleClassThatDoesNotImplementBenchmarkable() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.NotBenchmarkable.class);

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(1, results?.size(), 'Wrong # of results');
		Benchmark__c result = results?.get(0);
		Assert.areEqual(setting?.DeveloperName, result?.JobName__c, 'Wrong JobName__c');
		Assert.areNotEqual(null, result?.Error__c, 'Missing Error__c');
		Assert.areEqual(null, result?.SetupStartedAt__c, 'Missing SetupStartedAt__c');
		Assert.areEqual(null, result?.SetupCompletedAt__c, 'Should not have SetupCompletedAt__c');
		Assert.areEqual(null, result?.BenchmarkStartedAt__c, 'Should not have BenchmarkStartedAt__c');
		Assert.areEqual(null, result?.BenchmarkCompletedAt__c, 'Should not have BenchmarkCompletedAt__c');
	}

	@IsTest
	static void shouldHandleErrorsInFinalizer() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.ExampleBenchmarkable.class);
		BenchmarkJob cursedJob = new JobWithErrorInFinalizer();

		try {
			Test.startTest();
			System.enqueueJob(cursedJob);
			Test.stopTest();
		} catch (Exception error) {
			// Try/Catch needed to prevent aborting the test, and to trigger the finalizer
		}

		List<AsyncApexJob> jobs = BenchmarkJobTest.getAsyncJobs();
		Assert.areEqual(1, jobs?.size(), 'Wrong # of Jobs ran');
		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(0, results?.size(), 'Wrong # of results');
	}

	@IsTest
	static void shouldLaunchNextJobInChain() {
		Integer numJobs = 3;
		for (Integer i = 0; i < numJobs; i++) {
			BenchmarkTestUtils.initSetting(BenchmarkJobTest.ExampleBenchmarkable.class, 'Job_' + (i + 1));
		}

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkJobTest.getAsyncJobs();
		Assert.areEqual(numJobs, jobs?.size(), 'Wrong # of Jobs ran');
	}

	@IsTest
	static void shouldNotLaunchJobIfNoJobs() {
		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkJobTest.getAsyncJobs();
		Assert.areEqual(0, jobs?.size(), 'Wrong # of Jobs ran');
	}

	@IsTest
	static void shouldNotRunIfInactive() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.NotBenchmarkable.class);
		setting.Active__c = false;

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkJobTest.getAsyncJobs();
		Assert.areEqual(0, jobs?.size(), 'Wrong # of Jobs ran');
	}

	@IsTest
	static void shouldNotRunInProductionIfExcluded() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.ExampleBenchmarkable.class);
		setting.RunInProduction__c = false;
		// Simulate a production environment...
		BenchmarkJob.environment = new BenchmarkJobTest.MockEnvironment();

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkJobTest.getAsyncJobs();
		Assert.areEqual(0, jobs?.size(), 'Wrong # of Jobs ran');
	}

	@IsTest
	static void shouldNotRunInSandboxIfExcluded() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.ExampleBenchmarkable.class);
		setting.ExcludedSandboxes__c = 'sandbox1,sandbox2,sandbox3';
		// Simulate a specific sandbox environment
		BenchmarkJob.environment = new BenchmarkJobTest.MockEnvironment('sandbox2');

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkJobTest.getAsyncJobs();
		Assert.areEqual(0, jobs?.size(), 'Wrong # of Jobs ran');
	}

	@IsTest
	static void shouldProcessMixOfActiveAndInactiveJobs() {
		BenchmarkJobSetting__mdt setting1 = BenchmarkTestUtils.initSetting(
			BenchmarkJobTest.ExampleBenchmarkable.class,
			'Job_1'
		);
		setting1.Active__c = false;
		BenchmarkJobSetting__mdt setting2 = BenchmarkTestUtils.initSetting(
			BenchmarkJobTest.ExampleBenchmarkable.class,
			'Job_2'
		);
		setting2.Active__c = true;
		BenchmarkJobSetting__mdt setting3 = BenchmarkTestUtils.initSetting(
			BenchmarkJobTest.ExampleBenchmarkable.class,
			'Job_3'
		);
		setting3.Active__c = false;

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkJobTest.getAsyncJobs();
		Assert.areEqual(1, jobs?.size(), 'Wrong # of Jobs ran');
		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(1, results?.size(), 'Wrong # of results');
		Benchmark__c result = results?.get(0);
		Assert.areEqual(setting2?.DeveloperName, result?.JobName__c, 'Wrong job ran');
	}

	// **** HELPER **** //
	private static List<AsyncApexJob> getAsyncJobs() {
		return [
			SELECT Id, ApexClass.Name, Status, CreatedDate
			FROM AsyncApexJob
			WHERE ApexClass.Name = :BenchmarkJob.class.getName() AND Status IN ('Aborted', 'Completed', 'Failed')
		];
	}

	private static List<Benchmark__c> getResults() {
		return [
			SELECT
				Id,
				BenchmarkCompletedAt__c,
				BenchmarkStartedAt__c,
				Error__c,
				ErrorDetail__c,
				ErrorLocation__c,
				JobLabel__c,
				JobName__c,
				Operation__c,
				SetupCompletedAt__c,
				SetupStartedAt__c,
				SObjectType__c
			FROM Benchmark__c
		];
	}

	// **** INNER **** //
	public virtual class ExampleBenchmarkable implements Benchmarkable {
		private Id accountId;

		public virtual void setup() {
			// Create an Account
			Account account = new Account(Name = 'Test Account');
			Database.insert(account, System.AccessLevel.SYSTEM_MODE);
			this.accountId = account?.Id;
		}

		public virtual void benchmark() {
			// Create a Case related to the Account
			Case testCase = new Case(AccountId = this.accountId);
			insert testCase;
		}
	}

	public class BenchmarkFail extends ExampleBenchmarkable {
		public override void benchmark() {
			throw new System.DmlException('Mock Exception!');
		}
	}

	public class JobWithErrorInFinalizer extends BenchmarkJob {
		public override Id launch() {
			throw new System.DmlException('Test Exception');
		}
	}

	public class MockEnvironment extends BenchmarkJob.Environment {
		private String sandboxName;

		public MockEnvironment(String sandboxName) {
			// This constructor simulates a specific sandbox environment
			this.sandboxName = sandboxName;
		}

		public MockEnvironment() {
			// The 0-arg constructor simulates a production environment
			this(null);
		}

		public override String getSandboxName() {
			return this.sandboxName;
		}
	}

	public class NotBenchmarkable {
		// This class doesn't implement Benchmarkable
	}

	public class SetupFail extends ExampleBenchmarkable {
		public override void setup() {
			throw new System.DmlException('Mock Exception!');
		}
	}
}
