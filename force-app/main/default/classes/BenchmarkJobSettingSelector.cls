public without sharing abstract class BenchmarkJobSettingSelector {
	@TestVisible
	private static Map<String, BenchmarkJobSetting__mdt> settings;

	public static Map<String, BenchmarkJobSetting__mdt> getAll() {
		settings = settings ?? BenchmarkJobSettingSelector.retrieveFromOrg();
		System.debug(LoggingLevel.FINEST, 'All BenchmarkJobSetting__mdt: ' + settings?.values());
		return settings;
	}

	public static Map<String, BenchmarkJobSetting__mdt> get(Set<String> settingNames) {
		Map<String, BenchmarkJobSetting__mdt> results = new Map<String, BenchmarkJobSetting__mdt>();
		for (String settingName : settingNames) {
			BenchmarkJobSetting__mdt setting = BenchmarkJobSettingSelector.getAll()?.get(settingName);
			if (setting != null) {
				results?.put(settingName, setting);
			}
		}
		return results;
	}

	public static BenchmarkJobSetting__mdt get(String developerName) {
		return BenchmarkJobSettingSelector.get(new Set<String>{ developerName })?.get(developerName);
	}

	@TestVisible
	private static Map<String, BenchmarkJobSetting__mdt> mapByDeveloperName(List<BenchmarkJobSetting__mdt> settings) {
		Map<String, BenchmarkJobSetting__mdt> settingsMap = new Map<String, BenchmarkJobSetting__mdt>();
		for (BenchmarkJobSetting__mdt setting : settings) {
			String developerName = setting?.DeveloperName;
			settingsMap?.put(setting?.DeveloperName, setting);
		}
		return settingsMap;
	}

	private static List<BenchmarkJobSetting__mdt> querySettings() {
		return [
			SELECT
				Id,
				Active__c,
				ApexClass__c,
				Description__c,
				DeveloperName,
				ExcludedSandboxes__c,
				MasterLabel,
				Operation__c,
				RunInProduction__c,
				SObjectType__r.QualifiedApiName
			FROM BenchmarkJobSetting__mdt
			WITH SYSTEM_MODE
		];
	}

	private static Map<String, BenchmarkJobSetting__mdt> retrieveFromOrg() {
		List<BenchmarkJobSetting__mdt> settings = BenchmarkJobSettingSelector.querySettings();
		return BenchmarkJobSettingSelector.mapByDeveloperName(settings);
	}
}
