import { Errors } from "moleculer";
import ErrorType from "./type";
import MoleculerClientError = Errors.MoleculerClientError;

export default class SmsSendError extends MoleculerClientError {
	constructor(msg = "SmsSendError") {
		super(msg, 500, ErrorType.sendError);
	}
}
