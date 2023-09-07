import { Errors } from "moleculer";
import ErrorType from "./type";
import MoleculerClientError = Errors.MoleculerClientError;

export default class SmsConfigError extends MoleculerClientError {
	constructor(msg = "SmsConfigError") {
		super(msg, 500, ErrorType.configError);
	}
}
