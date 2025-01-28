import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import benchmarkObject from "@salesforce/schema/Benchmark__c";
import jobNameField from "@salesforce/schema/Benchmark__c.JobName__c";
import launch from "@salesforce/apex/BenchmarkLaunchUtility.launch";

const COMPONENT = "c-benchmark-retry-button";

export default class BenchmarkRetryButton extends NavigationMixin(LightningElement) {
	@api recordId;

	@api async invoke() {
		try {
			await launch({ developerName: this.jobName });
			this.showSuccessToast();
			this.navigateToBenchmarksHome();
		} catch (error) {
			this.handleError(error);
		}
	}

	@wire(getRecord, { recordId: "$recordId", fields: [jobNameField] })
	record;

	get jobName() {
		const fieldName = jobNameField?.fieldApiName;
		return this.record ? this.record?.data?.fields[fieldName]?.value : undefined;
	}

	handleError(error) {
		// Extract the error message - this differs if it originated in JS or Apex:
		const msg = error?.message ?? error?.body?.message;
		// Log the error and throw a toast
		console.error(COMPONENT, `Error: ${msg}`);
		const event = new ShowToastEvent({
			title: "Something went wrong...",
			message: msg,
			variant: "error"
		});
		this.dispatchEvent(event);
	}

	navigateToBenchmarksHome() {
		// Navigate to the Benchmarks home page
		this[NavigationMixin.Navigate]({
			type: "standard__objectPage",
			attributes: {
				objectApiName: benchmarkObject?.objectApiName,
				actionName: "home"
			}
		});
	}

	showSuccessToast() {
		const event = new ShowToastEvent({
			title: `Launching ${this.jobName}...`,
			message: "A new Benchmark record will be created in a few moments",
			variant: "success"
		});
		this.dispatchEvent(event);
	}
}
