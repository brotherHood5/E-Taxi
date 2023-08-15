import type Observable from "./Observable";

export default interface IObserver {
	update(subject: Observable): void;
}
