@SuppressWarnings('PMD.ApexDoc')
@IsTest
private class BenchmarkLogsTest {
	// **** CONSTANTS **** //
	private static final Type DEFAULT_ADAPTER_TYPE = BenchmarkLogs.DefaultLogger.class;

	// **** TESTS **** //
	@IsTest
	static void shouldUseProvidedAdapter() {
		Type adapterType = BenchmarkLogsTest.TestAdapter.class;
		BenchmarkSetting__c setting = new BenchmarkSetting__c(LogAdapter__c = adapterType?.getName(), Name = 'Test');
		insert setting;

		Test.startTest();
		BenchmarkLogs.Adapter adapter = BenchmarkLogs.LOGGER;
		Test.stopTest();

		Assert.areNotEqual(null, adapter, 'Returned null BenchmarkLogs.Adapter');
		Assert.isInstanceOfType(adapter, adapterType, 'Wrong type of BenchmarkLogs.Adapter');
	}

	@IsTest
	static void shouldUseDefaultLoggerIfSpecified() {
		BenchmarkSetting__c setting = new BenchmarkSetting__c(
			LogAdapter__c = DEFAULT_ADAPTER_TYPE?.getName(),
			Name = 'Test'
		);
		insert setting;

		Test.startTest();
		BenchmarkLogs.Adapter adapter = BenchmarkLogs.LOGGER;
		Test.stopTest();

		Assert.areNotEqual(null, adapter, 'Returned null BenchmarkLogs.Adapter');
		Assert.isInstanceOfType(adapter, DEFAULT_ADAPTER_TYPE, 'Wrong type of BenchmarkLogs.Adapter');
	}

	@IsTest
	static void shouldUseDefaultLoggerIfNoSettingsDefined() {
		Test.startTest();
		BenchmarkLogs.Adapter adapter = BenchmarkLogs.LOGGER;
		Test.stopTest();

		Assert.areNotEqual(null, adapter, 'Returned null BenchmarkLogs.Adapter');
		Assert.isInstanceOfType(adapter, DEFAULT_ADAPTER_TYPE, 'Wrong type of BenchmarkLogs.Adapter');
	}

	@IsTest
	static void shouldUseDefaultLoggerIfNoLogAdapterDefined() {
		BenchmarkSetting__c setting = new BenchmarkSetting__c(Name = 'Test');
		insert setting;

		Test.startTest();
		BenchmarkLogs.Adapter adapter = BenchmarkLogs.LOGGER;
		Test.stopTest();

		Assert.areNotEqual(null, adapter, 'Returned null BenchmarkLogs.Adapter');
		Assert.isInstanceOfType(adapter, DEFAULT_ADAPTER_TYPE, 'Wrong type of BenchmarkLogs.Adapter');
	}

	@IsTest
	static void shouldUseDefaultLoggerIfInvalidLogAdapter() {
		BenchmarkSetting__c setting = new BenchmarkSetting__c(
			LogAdapter__c = 'abcd1234', // Not a real log adapter!
			Name = 'Test'
		);
		insert setting;

		Test.startTest();
		BenchmarkLogs.Adapter adapter = BenchmarkLogs.LOGGER;
		Test.stopTest();

		Assert.areNotEqual(null, adapter, 'Returned null BenchmarkLogs.Adapter');
		Assert.isInstanceOfType(adapter, DEFAULT_ADAPTER_TYPE, 'Wrong type of BenchmarkLogs.Adapter');
	}

	@IsTest
	static void shouldUseDefaultLoggingBehavior() {
		// This method is mostly for coverage, since we can't check/assert standard System.debug behavior
		BenchmarkLogs.Adapter logger = new BenchmarkLogs.DefaultLogger();

		Test.startTest();
		try {
			logger?.log(System.LoggingLevel.INFO, 'This is a test!');
			logger?.save();
		} catch (Exception error) {
			Assert.fail('Failed to log: ' + error);
		}
		Test.stopTest();
	}

	// **** SETUP **** //
	@TestSetup
	static void setup() {
		// Clear the current Benchmark Settings for testing
		delete [SELECT Id FROM BenchmarkSetting__c];
	}

	// **** INNER **** //
	@SuppressWarnings('PMD.EmptyStatementBlock')
	public class TestAdapter implements BenchmarkLogs.Adapter {
		public void log(System.LoggingLevel level, Object message) {
			// This test adapter doesn't need to do anything
		}

		public void save() {
			// This test adapter doesn't need to do anything
		}
	}
}
