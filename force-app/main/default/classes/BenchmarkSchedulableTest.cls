@IsTest
private class BenchmarkSchedulableTest {
	@IsTest
	static void shouldLaunchABenchmarkJob() {
		// Instanatiate a test BenchmarkJobSetting__mdt record
		BenchmarkTestUtils.initSetting();

		Test.startTest();
		new BenchmarkSchedulable()?.execute(null);
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkTestUtils.getAsyncJobs();
		Assert.areEqual(1, jobs?.size(), 'Wrong # of Benchmark Jobs ran');
	}
}
