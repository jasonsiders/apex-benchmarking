public without sharing class BenchmarkContactCreate implements Benchmarkable {
	/**
	 * This example Benchmarkable instance measures the creation of a simple Contact
	 * Creating a Contact requires the presence of a parent Account; this is done in the setup method
	 */
	private Id accountId;

	public void setup() {
		// Create an Account
		Account account = new Account(Name = 'Test Account');
		Database.insert(account, System.AccessLevel.SYSTEM_MODE);
		this.accountId = account?.Id;
	}

	public void benchmark() {
		// Create a Contact related to the Account
		Contact testContact = new Contact(AccountId = this.accountId, FirstName = 'John', LastName = 'Doe');
		Database.insert(testContact, System.AccessLevel.SYSTEM_MODE);
	}
}
