@SuppressWarnings('PMD.ApexDoc')
@IsTest
public class BenchmarkMocks {
	/**
	 * This class contains mock objects used to test the Benchmarkable framework
	 **/
	public virtual class Example implements Benchmarkable {
		/**
		 * This example Benchmarkable instance measures the creation of a simple Contact
		 * Creating a Contact requires the presence of a parent Account; this is done in the setup method
		 **/
		private Id accountId;

		public virtual void setup() {
			// Create an Account
			Account account = new Account(Name = 'Test Account');
			Database.insert(account, System.AccessLevel.SYSTEM_MODE);
			this.accountId = account?.Id;
		}

		public virtual void benchmark() {
			// Create a Case related to the Account
			Case testCase = new Case(AccountId = this.accountId);
			insert testCase;
		}
	}
}
