/* eslint-disable capitalized-comments */
import os from "os";
import dotenvFlow from "dotenv-flow";
import _ from "lodash";

const processEnv = process.env;
let configObj = processEnv;

try {
	const envVars = Object.keys(dotenvFlow.parse([".env", ".env.dev"]));
	configObj = _.pick(processEnv, envVars);
} catch (e) {
	console.log(e);
	/* empty */
}

const isTrue = (text?: string | number) => [1, true, "1", "true", "yes"].includes(text || "");

const isFalse = (text?: string | number) => [0, false, "0", "false", "no"].includes(text || "");

const getValue = (text?: string, defaultValud?: string | boolean) => {
	const vtrue = isTrue(text);
	const vfalse = isFalse(text);
	const val = text || defaultValud;
	if (vtrue) {
		return true;
	}

	if (vfalse) {
		return false;
	}

	return val;
};

const HOST_NAME = os.hostname().toLowerCase();

export default class ConfigClass {
	[index: string]: any;

	static NODEID: string;

	static HOST = process.env.HOST || "0.0.0.0";

	static PORT = +(process.env.PORT || 80);

	static REQUEST_TIMEOUT = +(process.env.REQUEST_TIMEOUT || 10000);

	static NAMESPACE = process.env.NAMESPACE || undefined;

	static TRANSPORTER = process.env.TRANSPORTER || undefined;

	static CACHER = getValue(process.env.CACHER, undefined);

	static MAXCALLLEVEL = +(process.env.MAXCALLLEVEL || 100);

	static MONGO_URI = process.env.MONGO_URI;

	static SALT = +(process.env.SALT_VALUE || 10);

	static MAPPING_POLICY = process.env.MAPPING_POLICY || "all";

	constructor() {
		Object.keys(configObj).forEach((key: string) => {
			this[key] = configObj[key];
		});
		this.NODE_ENV = process.env.NODE_ENV;
		this.NODEID = `${process.env.NODE_ID ? `${process.env.NODE_ID}-` : ""}${HOST_NAME}-${
			this.NODE_ENV
		}`;
	}
}
