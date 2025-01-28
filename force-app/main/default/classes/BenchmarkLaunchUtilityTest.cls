@SuppressWarnings('PMD.EmptyCatchBlock')
@IsTest
private class BenchmarkLaunchUtilityTest {
	@IsTest
	static void shouldLaunchBenchmarkJob() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting();
		String developerName = setting?.DeveloperName;

		Test.startTest();
		Id jobId = BenchmarkLaunchUtility.launch(developerName);
		Test.stopTest();

		Assert.areNotEqual(null, jobId, 'A job was not lauched');
	}

	@IsTest
	static void shouldHandleErrorsInAuraContext() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting();
		String developerName = setting?.DeveloperName;
		// Inject an error into the container logic
		BenchmarkLaunchUtility.container = new BenchmarkLaunchUtilityTest.ErrorContainer();
		BenchmarkLaunchUtility.context = System.Quiddity.AURA;

		Test.startTest();
		try {
			Id jobId = BenchmarkLaunchUtility.launch(developerName);
			Assert.fail('Did not throw an error');
		} catch (System.AuraHandledException error) {
			// As expected!
		}
		Test.stopTest();
	}

	@IsTest
	static void shouldHandleErrorsOutsideOfAuraContext() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting();
		String developerName = setting?.DeveloperName;
		// Inject an error into the container logic
		BenchmarkLaunchUtility.container = new BenchmarkLaunchUtilityTest.ErrorContainer();
		BenchmarkLaunchUtility.context = System.Quiddity.UNDEFINED;

		Test.startTest();
		try {
			Id jobId = BenchmarkLaunchUtility.launch(developerName);
			Assert.fail('Did not throw an error');
		} catch (System.AuraHandledException error) {
			Assert.fail('Should not have cast to AuraHandledException');
		} catch (Exception error) {
			// As expected...
		}
		Test.stopTest();
	}

	// **** INNER **** //
	private class ErrorContainer extends BenchmarkLaunchUtility.Container {
		// Use this class to simulate failures in the container logic
		public override Id runJob(String developerName) {
			throw new System.NoSuchElementException('Mock Exception!');
		}
	}
}
