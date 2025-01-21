public without sharing class BenchmarkLeadConvert implements Benchmarkable {
	private Lead lead;
	private LeadStatus status;

	public void setup() {
		this.lead = new Lead(Company = 'Doe Industries, LLC', FirstName = 'John', LastName = 'Doe');
		insert this.lead;
		this.status = [SELECT Id, ApiName FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1] ?? null;
	}

	public void benchmark() {
		Database.LeadConvert leadConvert = new Database.LeadConvert();
		leadConvert?.setConvertedStatus(this.status?.ApiName);
		leadConvert?.setLeadId(this.lead?.Id);
		Database.convertLead(leadConvert, System.AccessLevel.SYSTEM_MODE);
	}
}
