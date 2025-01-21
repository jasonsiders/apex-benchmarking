public without sharing class BenchmarkOpportunityClosedWon implements Benchmarkable {
	private Opportunity opportunity;

	public void setup() {
		Account account = new Account(Name = 'Doe Industries, LLC');
		insert account;
		this.opportunity = new Opportunity(
			AccountId = account?.Id,
			Amount = 100,
			CloseDate = Date.today()?.addDays(30),
			Name = 'Doe Industries, LLC',
			StageName = 'New'
		);
		insert this.opportunity;
	}

	public void benchmark() {
		this.opportunity.StageName = 'Closed Won';
		update this.opportunity;
	}
}
