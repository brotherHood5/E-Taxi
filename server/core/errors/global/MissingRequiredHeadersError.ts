import { Errors } from "moleculer";
import ErrorType from "./type";
import MoleculerClientError = Errors.MoleculerClientError;

export default class MissingRequiredHeadersError extends MoleculerClientError {
	constructor(msg: string | string[], customMsg?: string) {
		if (typeof msg === "string") {
			super(msg || "MissingRequiredHeadersError", 401, ErrorType.missingRequiredHeader);
		} else {
			super(
				customMsg ||
					(msg.length !== 0
						? `Missing [${msg.join(", ")}] in request headers`
						: "MissingRequiredHeadersError"),
				400,
				ErrorType.missingRequiredHeader,
				msg,
			);
		}
	}
}
