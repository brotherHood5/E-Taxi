import type { Service } from "moleculer";
import type { IOSetting } from "moleculer-io";
import type { ApiSettingsSchema } from "moleculer-web";
import type { GuardServiceSchema } from "./interfaces";

export interface NotifServiceSettings extends ApiSettingsSchema {
	io?: IOSetting;
}

export type NotifServiceSchema = GuardServiceSchema<NotifServiceSettings>;

export type NotifThis = Service<NotifServiceSettings>;
