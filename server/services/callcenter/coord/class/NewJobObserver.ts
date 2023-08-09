import type IObserver from "../../../../core/interfaces/IObserver";

class NewJobObserver implements IObserver {
	private job: any;

	update(): void {
		console.log("New job received!");
	}
}

export default NewJobObserver;
