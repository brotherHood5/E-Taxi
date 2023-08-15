import { Queue } from "queue-typescript";
import type IObserver from "../interfaces/IObserver";
import type Observable from "../interfaces/Observable";

class QueueObservable<T = any> implements Observable {
	private observers: { [key: string]: IObserver } = {};

	private queue: Queue<T> = new Queue<T>();

	length(): number {
		return this.queue.length;
	}

	enqueue(item: T): void {
		this.queue.enqueue(item);
		this.notifyObserver("enqueue");
	}

	dequeue(): T {
		const data = this.queue.dequeue();
		this.notifyObserver("dequeue");
		return data;
	}

	attachObserver(event: string, observer: IObserver): void {
		// Check if the observer has already been attached
		const observerExists = this.observers[event];

		if (observerExists) {
			throw new Error("Observer has already been subscribed ");
		}

		// Add a new observer
		this.observers[event] = observer;
	}

	detachObserver(event: string): void {
		const observerIndex = this.observers[event];

		if (!observerIndex) {
			throw new Error("Observer does not exist");
		}

		delete this.observers[event];
	}

	notifyObserver(event?: string | string[] | undefined): void {
		if (!event) {
			this.notifyAll();
			return;
		}

		if (Array.isArray(event)) {
			for (const e of event) {
				this.notify(e);
			}
			return;
		}

		this.notify(event);
	}

	notify(event: string): void {
		const observer = this.observers[event];

		if (!observer) {
			return;
		}

		observer.update(this);
	}

	notifyAll(): void {
		for (const event of Object.keys(this.observers)) {
			this.observers[event].update(this);
		}
	}
}

export default QueueObservable;
