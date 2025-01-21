@IsTest
private class BenchmarkSchedulableTest {
	@IsTest
	static void shouldLaunchABenchmarkJob() {
		BenchmarkJobSetting__mdt setting = BenchmarkTestUtils.initSetting();

		Test.startTest();
		new BenchmarkSchedulable()?.execute(null);
		Test.stopTest();

		List<AsyncApexJob> jobs = BenchmarkTestUtils.getAsyncJobs();
		Assert.areEqual(1, jobs?.size(), 'Wrong # of Benchmark Jobs ran');
	}
}
