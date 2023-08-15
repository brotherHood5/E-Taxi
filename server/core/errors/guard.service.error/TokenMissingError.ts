import { Errors } from "moleculer";
import ErrorType from "./type";
import MoleculerClientError = Errors.MoleculerClientError;

export default class TokenMissingError extends MoleculerClientError {
	constructor(msg = "TokenMissingError") {
		super(msg, 401, ErrorType.missingToken);
	}
}
