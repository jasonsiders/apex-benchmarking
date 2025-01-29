@SuppressWarnings('PMD.ApexDoc')
public without sharing abstract class BenchmarkJobSettingSelector {
	/**
	 * This class is used internally by the framework to centralize queries for BenchmarkJobSetting__mdt records
	 * This pattern is necessary since custom metadata types can't be DML'd in a test context
	 * External callers shouldn't need to interact with this class directly;
	 * Instead, use the global "BenchmarkTestUtils" class methods to mock settings
	 **/

	// **** STATIC **** //
	@TestVisible
	private static Map<String, BenchmarkJobSetting__mdt> settings;

	public static Map<String, BenchmarkJobSetting__mdt> getAll() {
		// This method uses lazy-initialization to retrieve all defined BenchmarkJobSetting__mdt records in the org
		// Successive calls to this method will return the results from the first time it was called
		settings = settings ?? BenchmarkJobSettingSelector.retrieveFromOrg();
		return settings;
	}

	public static Map<String, BenchmarkJobSetting__mdt> get(Set<String> settingNames) {
		// This method returns a subset of the defined BenchmarkJobSetting__mdt records,
		// where the key of the map is the DeveloperName of each record
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
		// This method returns the specified BenchmarkJobSetting__mdt record
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
				Flow__c,
				MasterLabel,
				Operation__c,
				RunInProduction__c,
				SObjectType__r.QualifiedApiName,
				SObjectTypeName__c
			FROM BenchmarkJobSetting__mdt
			WITH SYSTEM_MODE
			LIMIT 50000
		];
	}

	private static Map<String, BenchmarkJobSetting__mdt> retrieveFromOrg() {
		List<BenchmarkJobSetting__mdt> settings = BenchmarkJobSettingSelector.querySettings();
		return BenchmarkJobSettingSelector.mapByDeveloperName(settings);
	}
}
