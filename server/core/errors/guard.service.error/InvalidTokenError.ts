import { Errors } from "moleculer";
import ErrorType from "./type";
import MoleculerClientError = Errors.MoleculerClientError;

export default class InvalidTokenError extends MoleculerClientError {
	constructor(msg = "InvalidTokenError") {
		super(msg, 401, ErrorType.invalidToken);
	}
}
