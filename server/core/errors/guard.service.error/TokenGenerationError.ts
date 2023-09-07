import { Errors } from "moleculer";
import ErrorType from "./type";
import MoleculerClientError = Errors.MoleculerClientError;

export default class TokenGenerationError extends MoleculerClientError {
	constructor(msg = "TokenGenerationError") {
		super(msg, 500, ErrorType.unableGenerateToken);
	}
}
