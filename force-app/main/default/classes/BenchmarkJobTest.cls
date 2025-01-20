@IsTest
private class BenchmarkJobTest {
	@IsTest
	static void shouldRunBenchmarkJob() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.HappyPath.class);

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
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.FailDuringSetup.class);

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
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.FailDuringBenchmark.class);

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
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.HappyPath.class);
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
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting(BenchmarkJobTest.UnrelatedClass.class);

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
	static void shouldLaunchNextJob() {
		Assert.fail('You still need to build this test');
	}

	@IsTest
	static void shouldNotLaunchJobIfNoNext() {
		Assert.fail('You still need to build this test');
	}

	@IsTest
	static void shouldNotRunIfInactive() {
		Assert.fail('You still need to build this test');
	}

	@IsTest
	static void shouldNotRunInProductionIfExcluded() {
		Assert.fail('You still need to build this test');
	}

	@IsTest
	static void shouldNotRunInSandboxIfExcluded() {
		Assert.fail('You still need to build this test');
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
	public virtual class HappyPath implements Benchmarkable {
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

	public class FailDuringSetup extends HappyPath {
		public override void setup() {
			throw new System.DmlException('Mock Exception!');
		}
	}

	public class FailDuringBenchmark extends HappyPath {
		public override void benchmark() {
			throw new System.DmlException('Mock Exception!');
		}
	}

	public class UnrelatedClass {
		// This class doesn't implement Benchmarkable
	}
}
