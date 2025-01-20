@SuppressWarnings('PMD.AvoidGlobalModifier')
@IsTest
global class BenchmarkTestUtils {
	global static BenchmarkJobSetting__mdt initSetting(Type apexClass, String developerName) {
		// Initialize a new setting record for testing
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

	private static void inject(BenchmarkJobSetting__mdt setting) {
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
