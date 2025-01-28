import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import jobNameField from "@salesforce/schema/Benchmark__c.JobName__c";
import launch from "@salesforce/apex/BenchmarkLaunchUtility.launch";

export default class BenchmarkRetryButton extends LightningElement {
	@api recordId;

	@api async invoke() {
		try {
			const jobId = await launch({ developerName: this.jobName });
			this.showSuccessToast(jobId);
		} catch (error) {
			console.error(error);
			this.showErrorToast(error);
		}
	}

	@wire(getRecord, { recordId: "$recordId", fields: [jobNameField] })
	record;

	get jobName() {
		const fieldName = jobNameField?.fieldApiName;
		return this.record ? this.record?.data?.fields[fieldName]?.value : undefined;
	}

	showErrorToast(error) {
		const event = new ShowToastEvent({
			title: "Something went wrong...",
			message: error,
			variant: "error"
		});
		this.dispatchEvent(event);
	}

	showSuccessToast(jobId) {
		const event = new ShowToastEvent({
			title: `Launched ${this.jobName} via ${jobId}`,
			message: "A new Benchmark record will be created in a few moments...",
			variant: "success"
		});
		this.dispatchEvent(event);
	}
}
