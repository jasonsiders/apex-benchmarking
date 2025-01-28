@SuppressWarnings('PMD.EmptyCatchBlock')
@IsTest
private class BenchmarkJobTest {
	@IsTest
	static void shouldRunAllBenchmarkJobs() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkMocks.BenchmarkableExample.class);

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
	static void shouldRunSpecifiedBenchmarkJobs() {
		// Create 3 settings records
		BenchmarkJobSetting__mdt setting1 = BenchmarkTestUtils.initSetting(
			BenchmarkMocks.BenchmarkableExample.class,
			'Setting_1'
		);
		BenchmarkJobSetting__mdt setting2 = BenchmarkTestUtils.initSetting(
			BenchmarkMocks.BenchmarkableExample.class,
			'Setting_2'
		);
		BenchmarkJobSetting__mdt setting3 = BenchmarkTestUtils.initSetting(
			BenchmarkMocks.BenchmarkableExample.class,
			'Setting_3'
		);
		// Only submit one of these settings records for processing
		Set<String> toProcess = new Set<String>{ setting2?.DeveloperName };

		Test.startTest();
		new BenchmarkJob(toProcess)?.launch();
		Test.stopTest();

		// Verify that the job saved the run results in a Benchmark record
		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(1, results?.size(), 'Wrong # of results');
		Benchmark__c result = results?.get(0);
		Assert.areEqual(setting2?.DeveloperName, result?.JobName__c, 'Wrong JobName__c');
	}

	@IsTest
	static void shouldRunSpecifiedBenchmarkJob() {
		// Create a settings record to process
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkMocks.BenchmarkableExample.class);

		Test.startTest();
		new BenchmarkJob(setting?.DeveloperName)?.launch();
		Test.stopTest();

		// Verify that the job saved the run results in a Benchmark record
		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(1, results?.size(), 'Wrong # of results');
		Benchmark__c result = results?.get(0);
		Assert.areEqual(setting?.DeveloperName, result?.JobName__c, 'Wrong JobName__c');
	}

	@IsTest
	static void shouldHandleErrorsDuringInSetupMethod() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.SetupFail.class);

		try {
			Test.startTest();
			new BenchmarkJob()?.launch();
			Test.stopTest();
			Assert.fail('An exception was not thrown');
		} catch (Exception error) {
			// Try/Catch needed to prevent aborting the test, and to trigger the finalizer
		}

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

		try {
			Test.startTest();
			new BenchmarkJob()?.launch();
			Test.stopTest();
			Assert.fail('An exception was not thrown');
		} catch (Exception error) {
			// Try/Catch needed to prevent aborting the test, and to trigger the finalizer
		}

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
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(null, 'Test_Setting');

		try {
			Test.startTest();
			new BenchmarkJob()?.launch();
			Test.stopTest();
			Assert.fail('An exception was not thrown');
		} catch (Exception error) {
			// Try/Catch needed to prevent aborting the test, and to trigger the finalizer
		}

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
		String badClassName = 'asdflkjasdflkjadsf'; // ! Not a real apex class name
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(
			BenchmarkMocks.BenchmarkableExample.class,
			badClassName
		);
		setting.ApexClass__c = badClassName;

		try {
			Test.startTest();
			new BenchmarkJob()?.launch();
			Test.stopTest();
			Assert.fail('An exception was not thrown');
		} catch (Exception error) {
			// Try/Catch needed to prevent aborting the test, and to trigger the finalizer
		}

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

		try {
			Test.startTest();
			new BenchmarkJob()?.launch();
			Test.stopTest();
			Assert.fail('An exception was not thrown');
		} catch (Exception error) {
			// Try/Catch needed to prevent aborting the test, and to trigger the finalizer
		}

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
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkMocks.BenchmarkableExample.class);
		BenchmarkJob cursedJob = new JobWithErrorInFinalizer();

		Id jobId;
		try {
			Test.startTest();
			jobId = System.enqueueJob(cursedJob);
			Test.stopTest();
			Assert.fail('An exception was not thrown');
		} catch (Exception error) {
			// Try/Catch needed to prevent aborting the test, and to trigger the finalizer
		}

		List<AsyncApexJob> jobs = BenchmarkTestUtils.getAsyncJobs();
		Assert.areEqual(1, jobs?.size(), 'Wrong # of Jobs ran');
		// Note: A Benchmark__c record *shouldn't* be inserted here, but it is...
		// We can't assert this behavior since this test is catching the exception
		// Unfortunately, we don't have a way to test for this behavior
	}

	@IsTest
	static void shouldLaunchNextJobInChain() {
		Integer numJobs = 3;
		for (Integer i = 0; i < numJobs; i++) {
			BenchmarkTestUtils.initSetting(BenchmarkMocks.BenchmarkableExample.class, 'Job_' + (i + 1));
		}

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkTestUtils.getAsyncJobs();
		Assert.areEqual(numJobs, jobs?.size(), 'Wrong # of Jobs ran');
	}

	@IsTest
	static void shouldNotLaunchJobIfNoJobs() {
		// Inject an empty list of metadata to be processed
		BenchmarkJobSettingSelector.settings = new Map<String, BenchmarkJobSetting__mdt>();

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkTestUtils.getAsyncJobs();
		Assert.areEqual(0, jobs?.size(), 'Wrong # of Jobs ran');
	}

	@IsTest
	static void shouldNotRunIfInactive() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.NotBenchmarkable.class);
		setting.Active__c = false;

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkTestUtils.getAsyncJobs();
		Assert.areEqual(0, jobs?.size(), 'Wrong # of Jobs ran');
	}

	@IsTest
	static void shouldNotRunInProductionIfExcluded() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkMocks.BenchmarkableExample.class);
		setting.RunInProduction__c = false;
		// Simulate a production environment...
		BenchmarkJob.environment = new BenchmarkMocks.ProductionEnvironment();

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkTestUtils.getAsyncJobs();
		Assert.areEqual(0, jobs?.size(), 'Wrong # of Jobs ran');
	}

	@IsTest
	static void shouldNotRunInSandboxIfExcluded() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkMocks.BenchmarkableExample.class);
		setting.ExcludedSandboxes__c = 'sandbox1,sandbox2,sandbox3';
		// Simulate a specific sandbox environment
		BenchmarkJob.environment = new BenchmarkMocks.SandboxEnvironment('sandbox2');

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkTestUtils.getAsyncJobs();
		Assert.areEqual(0, jobs?.size(), 'Wrong # of Jobs ran');
	}

	@IsTest
	static void shouldProcessMixOfActiveAndInactiveJobs() {
		BenchmarkJobSetting__mdt setting1 = BenchmarkTestUtils.initSetting(
			BenchmarkMocks.BenchmarkableExample.class,
			'Job_1'
		);
		setting1.Active__c = false;
		BenchmarkJobSetting__mdt setting2 = BenchmarkTestUtils.initSetting(
			BenchmarkMocks.BenchmarkableExample.class,
			'Job_2'
		);
		setting2.Active__c = true;
		BenchmarkJobSetting__mdt setting3 = BenchmarkTestUtils.initSetting(
			BenchmarkMocks.BenchmarkableExample.class,
			'Job_3'
		);
		setting3.Active__c = false;

		Test.startTest();
		new BenchmarkJob()?.launch();
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkTestUtils.getAsyncJobs();
		Assert.areEqual(1, jobs?.size(), 'Wrong # of Jobs ran');
		List<Benchmark__c> results = BenchmarkJobTest.getResults();
		Assert.areEqual(1, results?.size(), 'Wrong # of results');
		Benchmark__c result = results?.get(0);
		Assert.areEqual(setting2?.DeveloperName, result?.JobName__c, 'Wrong job ran');
	}

	// **** HELPER **** //
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
	public class BenchmarkFail extends BenchmarkMocks.BenchmarkableExample {
		public override void benchmark() {
			throw new System.DmlException('Mock Exception!');
		}
	}

	public class JobWithErrorInFinalizer extends BenchmarkJob {
		public override Id launch() {
			throw new System.DmlException('Test Exception');
		}
	}

	public class NotBenchmarkable {
		// This class doesn't implement Benchmarkable
	}

	public class SetupFail extends BenchmarkMocks.BenchmarkableExample {
		public override void setup() {
			throw new System.DmlException('Mock Exception!');
		}
	}
}
