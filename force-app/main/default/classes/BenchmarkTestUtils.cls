@SuppressWarnings('PMD.AvoidGlobalModifier')
@IsTest
global class BenchmarkTestUtils {
	global static List<AsyncApexJob> getAsyncJobs() {
		// Retrieve any BenchmarkJobs that were enqueued and/or run
		List<AsyncApexJob> jobs = [
			SELECT Id, ApexClass.Name, JobType, Status, CreatedDate
			FROM AsyncApexJob
			WHERE JobType = 'Queueable' AND ApexClass.Name LIKE 'Benchmark%'
		];
		System.debug(LoggingLevel.FINEST, 'AsyncApexJobs: ' + JSON.serializePretty(jobs));
		return jobs;
	}

	global static BenchmarkJobSetting__mdt initSetting(Type apexClass, String developerName) {
		// Initialize a new setting record for testing.
		// This is necessary since custom metadata types can't be DML'd
		BenchmarkJobSetting__mdt setting = new BenchmarkJobSetting__mdt(
			Active__c = true,
			ApexClass__c = apexClass?.toString(),
			DeveloperName = developerName,
			RunInProduction__c = true
		);
		BenchmarkTestUtils.inject(setting);
		return setting;
	}

	global static BenchmarkJobSetting__mdt initSetting(Type apexClass) {
		return BenchmarkTestUtils.initSetting(apexClass, apexClass?.toString());
	}

	global static BenchmarkJobSetting__mdt initSetting() {
		Type defaultClass = BenchmarkMocks.BenchmarkableExample.class;
		return BenchmarkTestUtils.initSetting(defaultClass);
	}

	global static void inject(BenchmarkJobSetting__mdt setting) {
		// Inject the test record into the cache of settings to be used in place of actual cmdt records
		String developerName = setting?.DeveloperName;
		BenchmarkTestUtils.useMockSettings()?.put(developerName, setting);
	}

	private static Map<String, BenchmarkJobSetting__mdt> useMockSettings() {
		// Ensure the BenchmarkJobSettingSelector uses mock/injected settings for testing,
		// and not "real" cmdt records that actually exist in the org
		BenchmarkJobSettingSelector.settings = (BenchmarkJobSettingSelector.settings != null)
			? BenchmarkJobSettingSelector.settings
			: new Map<String, BenchmarkJobSetting__mdt>();
		return BenchmarkJobSettingSelector.settings;
	}
}
