import type IObserver from "./IObserver";

export default interface Observable {
	attachObserver(event: string, observer: IObserver): void;
	detachObserver(event: string): void;
	notifyObserver(event?: string[] | string | undefined): void;
}
