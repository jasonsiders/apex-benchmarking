public without sharing class BenchmarkJob implements System.Queueable, System.Finalizer {
	@TestVisible
	private static Environment environment = new Environment();

	public void execute(System.QueueableContext context) {
		// TODO!
	}

	public void execute(System.FinalizerContext context) {
		// TODO!
	}

	public Id launch() {
		return null; // TODO!
	}

	// **** INNER **** //
	public virtual class Environment {
		public virtual String getSandboxName() {
			System.Url url = System.Url.getOrgDomainUrl();
			return System.DomainParser.parse(url)?.getSandboxName();
		}

		public Boolean isSandbox() {
			return this.getSandboxName() != null;
		}
	}
}
