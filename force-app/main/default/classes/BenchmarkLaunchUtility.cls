@SuppressWarnings('PMD.AvoidGlobalModifier')
global class BenchmarkLaunchUtility {
	/**
	 * This class contains an @AuraEnabled method to launch benchmark jobs from LWC
	 **/
	@TestVisible
	private static BenchmarkLaunchUtility.Container container = new BenchmarkLaunchUtility.Container();
	@TestVisible
	private static System.Quiddity context = System.Request.getCurrent()?.getQuiddity();

	@AuraEnabled(cacheable=false)
	global static Id launch(String developerName) {
		try {
			// Launch the specified BenchmarkJob
			return BenchmarkLaunchUtility.container?.runJob(developerName);
		} catch (Exception error) {
			System.debug(LoggingLevel.ERROR, error + '\n' + error?.getStackTraceString());
			// Cast the error to an AuraHandledException if currently in an Aura/LWC context, and re-throw
			throw (BenchmarkLaunchUtility.context == System.Quiddity.AURA)
				? new System.AuraHandledException(error?.getMessage())
				: error;
		}
	}

	// **** INNER **** //
	@TestVisible
	private virtual class Container {
		/**
		 * This class contains the logic to launch a new job
		 * It primarily exists to be overridden in @IsTest context, to test error handling
		 **/
		public virtual Id runJob(String developerName) {
			System.debug(LoggingLevel.FINEST, 'Invocable to launch BenchmarkJob: ' + developerName);
			return new BenchmarkJob(developerName)?.launch();
		}
	}
}
