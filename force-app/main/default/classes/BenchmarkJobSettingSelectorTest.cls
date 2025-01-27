@IsTest
private class BenchmarkJobSettingSelectorTest {
	@IsTest
	static void shouldRetrieveAllInOrg() {
		Test.startTest();
		List<BenchmarkJobSetting__mdt> settings = BenchmarkJobSettingSelector.getAll()?.values();
		Test.stopTest();

		Integer actualNumSettings = BenchmarkJobSetting__mdt.getAll()?.size();
		Assert.areEqual(actualNumSettings, settings?.size(), 'Wrong # of org settings');
	}

	@IsTest
	static void shouldOnlyQueryOnce() {
		Test.startTest();
		// 101 queries would break the governor limit,
		// but the class should only query once and cache the results
		for (Integer i = 0; i < 101; i++) {
			BenchmarkJobSettingSelector.getAll();
		}
		Integer numQueries = Limits.getQueries();
		Test.stopTest();

		Assert.areEqual(1, numQueries, 'Wrong # of queries');
	}

	@IsTest
	static void shouldReturnInjectedResults() {
		String devName = 'My_Test_Setting';
		BenchmarkJobSetting__mdt mockSetting = new BenchmarkJobSetting__mdt(DeveloperName = devName);
		BenchmarkJobSettingSelector.settings = new Map<String, BenchmarkJobSetting__mdt>{
			mockSetting?.DeveloperName => mockSetting
		};

		Test.startTest();
		Map<String, BenchmarkJobSetting__mdt> settings = BenchmarkJobSettingSelector.getAll();
		Test.stopTest();

		Assert.areEqual(1, settings?.size(), 'Wrong # of settings returned');
		Assert.areEqual(true, settings?.containsKey(devName), 'Did not return mocked setting');
	}

	@IsTest
	static void shouldReturnMultipleRecordsByDeveloperName() {
		BenchmarkJobSettingSelector.settings = new Map<String, BenchmarkJobSetting__mdt>();
		for (Integer i = 0; i < 3; i++) {
			String devName = 'My_Test_Setting_' + i;
			BenchmarkJobSetting__mdt mockSetting = new BenchmarkJobSetting__mdt(DeveloperName = devName);
			BenchmarkJobSettingSelector.settings?.put(devName, mockSetting);
		}
		// Select a subset of the chosen settings
		Set<String> settingNames = new Set<String>{ 'My_Test_Setting_0', 'My_Test_Setting_1' };

		Test.startTest();
		Map<String, BenchmarkJobSetting__mdt> settings = BenchmarkJobSettingSelector.get(settingNames);
		Test.stopTest();

		Assert.areEqual(settingNames?.size(), settings?.size(), 'Wrong # of settings returned');
		for (String settingName : settingNames) {
			Assert.areEqual(true, settings?.containsKey(settingName), 'Did not return mocked setting');
		}
	}

	@IsTest
	static void shouldReturnSingleRecordByDeveloperName() {
		String devName = 'My_Test_Setting';
		BenchmarkJobSetting__mdt mockSetting = new BenchmarkJobSetting__mdt(DeveloperName = devName);
		BenchmarkJobSettingSelector.settings = new Map<String, BenchmarkJobSetting__mdt>{
			mockSetting?.DeveloperName => mockSetting
		};

		Test.startTest();
		BenchmarkJobSetting__mdt setting = BenchmarkJobSettingSelector.get(devName);
		Test.stopTest();

		Assert.areNotEqual(null, setting, 'Did not return a setting');
	}

	@IsTest
	static void shouldReturnNullIfNoMatchingRecord() {
		String devName = 'a'?.repeat(1000); // ! Illegal DeveloperName; would never actually exist

		Test.startTest();
		BenchmarkJobSetting__mdt setting = BenchmarkJobSettingSelector.get(devName);
		Test.stopTest();

		Assert.areEqual(null, setting, 'Returned a setting, but none should exist');
	}

	@IsTest
	static void shouldMapSettingsByDeveloperName() {
		// Note: Testing a private method for code coverage in orgs without any existing settings records
		List<BenchmarkJobSetting__mdt> settings = new List<BenchmarkJobSetting__mdt>();
		for (Integer i = 0; i < 3; i++) {
			BenchmarkJobSetting__mdt setting = new BenchmarkJobSetting__mdt(DeveloperName = 'Test_Setting_' + i);
			settings?.add(setting);
		}

		Test.startTest();
		Map<String, BenchmarkJobSetting__mdt> settingsMap = BenchmarkJobSettingSelector.mapByDeveloperName(settings);
		Test.stopTest();

		Assert.areEqual(settings?.size(), settingsMap?.size(), 'Wrong # of settings mapped');
	}
}
