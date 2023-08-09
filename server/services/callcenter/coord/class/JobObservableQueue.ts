import ObservableQueue from "../../../../core/class/ObservableQueue";

interface ResovleAddressJob {
	id: string;
	data: any;
}
class JobObservableQueue<T = ResovleAddressJob> extends ObservableQueue<T> {}

export default JobObservableQueue;
