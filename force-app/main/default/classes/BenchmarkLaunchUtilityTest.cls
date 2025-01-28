@SuppressWarnings('PMD.EmptyCatchBlock')
@IsTest
private class BenchmarkLaunchUtilityTest {
	@IsTest
	static void shouldLaunchBenchmarkJob() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting();

		Test.startTest();
		Id jobId = BenchmarkLaunchUtility.launch(setting?.DeveloperName);
		Test.stopTest();

		Assert.areNotEqual(null, jobId, 'A job was not lauched');
	}

	@IsTest
	static void shouldHandleErrorsInAuraContext() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting();
		// Mark the job as inactive - this will cause a BenchmarkJob.IneligibleJobException to be thrown
		setting.Active__c = false;
		// Ensure the current quiddity is AURA
		BenchmarkLaunchUtility.context = System.Quiddity.AURA;

		Test.startTest();
		try {
			BenchmarkLaunchUtility.launch(setting?.DeveloperName);
			Assert.fail('Did not throw an error');
		} catch (System.AuraHandledException error) {
			// As expected!
		}
		Test.stopTest();
	}

	@IsTest
	static void shouldHandleErrorsOutsideOfAuraContext() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting();
		// Mark the job as inactive - this will cause a BenchmarkJob.IneligibleJobException to be thrown
		setting.Active__c = false;
		// Ensure the current quiddity is not AURA
		BenchmarkLaunchUtility.context = System.Quiddity.UNDEFINED;

		Test.startTest();
		try {
			BenchmarkLaunchUtility.launch(setting?.DeveloperName);
			Assert.fail('Did not throw an error');
		} catch (System.AuraHandledException auraError) {
			Assert.fail('Should not have cast to AuraHandledException');
		} catch (BenchmarkJob.IneligibleJobException benchmarkError) {
			// As expected...
		}
		Test.stopTest();
	}
}
