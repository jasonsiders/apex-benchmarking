public abstract without sharing class BenchmarkJobSettingSelector {
	@TestVisible
	private static Map<String, BenchmarkJobSetting__mdt> settings;

	public static Map<String, BenchmarkJobSetting__mdt> getAll() {
		settings = settings ?? BenchmarkJobSettingSelector.queryAndMapSettings();
		return settings;
	}

	public static BenchmarkJobSetting__mdt get(String className) {
		return BenchmarkJobSettingSelector.getAll()?.get(className);
	}

	private static Map<String, BenchmarkJobSetting__mdt> queryAndMapSettings() {
		Map<String, BenchmarkJobSetting__mdt> settingsMap = new Map<String, BenchmarkJobSetting__mdt>();
		for (BenchmarkJobSetting__mdt setting : [
			SELECT
				Id,
				Active__c,
				ApexClass__c,
				Description__c,
				ExcludedSandboxes__c,
				Operation__c,
				RunInProduction__c,
				SObjectType__r.QualifiedApiName
			FROM BenchmarkJobSetting__mdt
			WITH SYSTEM_MODE
		]) {
			String className = setting?.ApexClass__c;
			settingsMap?.put(className, setting);
		}
		return settingsMap;
	}
}
