import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class BenchmarkRetryButton extends LightningElement {
	@api invoke() {
		console.log(`@jason: hello world!`);
		const event = new ShowToastEvent({
			title: "Hello World!",
			variant: "success"
		});
		this.dispatchEvent(event);
	}
}
