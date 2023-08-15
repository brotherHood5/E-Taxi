import { Errors } from "moleculer";
import ErrorType from "./type";
import MoleculerClientError = Errors.MoleculerClientError;

export default class ServiceError extends MoleculerClientError {
	constructor(msg: string, code?: number | unknown, data?: unknown) {
		// two arguments
		if (code && !data) {
			if (typeof code === "number") {
				super(msg, code, ErrorType.serviceError);
				return;
			}

			data = code;
		} else if (code && data) {
			// three arguments
			if (typeof code === "number") {
				super(msg, code, ErrorType.serviceError, data);
				return;
			}
			throw new Error("Invalid arguments: code must be a number");
		}

		// one argument
		super(msg, 500, ErrorType.serviceError, data);
	}
}
