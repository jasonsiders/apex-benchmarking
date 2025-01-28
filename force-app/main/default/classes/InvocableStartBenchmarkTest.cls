@IsTest
private class InvocableStartBenchmarkTest {
	@IsTest
	static void shouldStampBenchmarkStartTime() {
		Benchmark__c record = new Benchmark__c();
		InvocableStartBenchmark.currentRecord = record;

		Test.startTest();
		InvocableStartBenchmark.invoke();
		Test.stopTest();

		Assert.areNotEqual(null, record?.SetupCompletedAt__c, 'Missing SetupCompletedAt__c');
		Assert.areNotEqual(null, record?.BenchmarkStartedAt__c, 'Missing BenchmarkStartedAt__c');
		Assert.areEqual(null, InvocableStartBenchmark.currentRecord, 'Did not remove pointer');
	}
}
