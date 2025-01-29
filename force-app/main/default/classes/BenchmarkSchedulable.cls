@SuppressWarnings('PMD.ApexDoc, PMD.AvoidGlobalModifier')
global class BenchmarkSchedulable implements System.Schedulable {
	// This class provides a simple schedulable interface
	// to execute the BenchmarkJob on a regular cadence
	global void execute(System.SchedulableContext context) {
		new BenchmarkJob()?.launch();
	}
}
