@SuppressWarnings('PMD.AvoidGlobalModifier')
global class BenchmarkLaunchUtility {
	/**
	 * This class contains an @AuraEnabled method to launch benchmark jobs from LWC
	 **/
	@TestVisible
	private static System.Quiddity context = System.Request.getCurrent()?.getQuiddity();

	@AuraEnabled(cacheable=false)
	global static Id launch(String developerName) {
		try {
			// Validate & launch the specified Benchmark Job
			BenchmarkJob.validate(developerName);
			return new BenchmarkJob(developerName)?.launch();
		} catch (Exception error) {
			BenchmarkLogs.LOGGER?.log(LoggingLevel.ERROR, error + '\n' + error?.getStackTraceString());
			// Cast the error to an AuraHandledException if currently in an Aura/LWC context, and re-throw
			throw (BenchmarkLaunchUtility.context == System.Quiddity.AURA)
				? new System.AuraHandledException(error?.getMessage())
				: error;
		}
	}
}
