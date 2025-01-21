public with sharing class BenchmarkFailedAccount implements Benchmarkable {
	public void setup() {
		// Nothing needed here...
	}

	public void benchmark() {
		// Missing Name - should cause a failure
		insert new Account();
	}
}
