import { Errors } from "moleculer";
import ErrorType from "./type";
import MoleculerClientError = Errors.MoleculerClientError;

export default class ForbiddenServiceError extends MoleculerClientError {
	constructor(msg = "ForbiddenServiceError") {
		super(msg, 401, ErrorType.forbidden);
	}
}
