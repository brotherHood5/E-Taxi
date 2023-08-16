import type { Service } from "moleculer";
import type { IOSetting } from "moleculer-io";
import type { ApiSettingsSchema } from "moleculer-web";
import type { GuardServiceSchema } from "./interfaces";

export interface SocketServiceSettings extends ApiSettingsSchema {
	io?: IOSetting;
}

export type SocketServiceSchema = GuardServiceSchema<SocketServiceSettings>;

export type SocketThis = Service<SocketServiceSettings>;
