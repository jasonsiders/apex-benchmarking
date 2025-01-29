/**
 * @description Any class listed in BenchmarkJobSetting__mdt should implement this interface
 * It is used to setup and test actions to be "benchmarked", or have its performance measured
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global interface Benchmarkable {
	/**
	 * @description This method is used to set up the test data for the benchmark.
	 */
	void setup();

	/**
	 * @description This method is used to execute the benchmark.
	 */
	void benchmark();
}
