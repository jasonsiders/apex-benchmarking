@SuppressWarnings('PMD.ApexDoc, PMD.AvoidGlobalModifier')
global abstract class InvocableStartBenchmark {
	/**
	 * This class is used by flows to indicate when setup has completed, and benchmarking is about to begin
	 * The method ensures the current benchmark record has accurate values for these timestamps.
	 * This is necessary to support benchmarking via flow, and not just apex
	 **/
	public static Benchmark__c currentRecord;

	@InvocableMethod(label='Record Benchmark Start Time' category='Benchmarks')
	global static void invoke() {
		if (currentRecord != null) {
			currentRecord.SetupCompletedAt__c = Limits.getCpuTime();
			currentRecord.BenchmarkStartedAt__c = Limits.getCpuTime();
			// Remove the current pointer
			currentRecord = null;
		}
	}
}
