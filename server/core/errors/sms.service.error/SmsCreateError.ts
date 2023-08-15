import { Errors } from "moleculer";
import ErrorType from "./type";
import MoleculerClientError = Errors.MoleculerClientError;

export default class SmsCreateError extends MoleculerClientError {
	constructor(msg = "SmsCreateError") {
		super(msg, 500, ErrorType.createError);
	}
}
