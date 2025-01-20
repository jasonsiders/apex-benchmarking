public abstract without sharing class BenchmarkJobSettingSelector {
	@TestVisible
	private static Map<String, BenchmarkJobSetting__mdt> settings;

	public static Map<String, BenchmarkJobSetting__mdt> getAll() {
		settings = settings ?? BenchmarkJobSettingSelector.retrieveFromOrg();
		return settings;
	}

	public static BenchmarkJobSetting__mdt get(String developerName) {
		return BenchmarkJobSettingSelector.getAll()?.get(developerName);
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
