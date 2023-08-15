import type { Service, ServiceSettingSchema } from "moleculer";
import type { GuardServiceSchema } from "./interfaces";

export interface SmsServiceSettings extends ServiceSettingSchema {
	accountSid: string;
	authToken: string;
	phoneNumber: string;
}

export interface SmsServiceMethods {
	/**
	 * Send an SMS
	 *
	 * @methods
	 * @param {String} to - Target phone number
	 * @param {String} [body=""] - Body of SMS
	 * @param {String} [mediaUrl] - Media URL
	 * @returns {String}
	 */
	sendSMS(to: string, body?: string, mediaUrl?: string): Promise<string>;
}

export type SmsServiceSchema = GuardServiceSchema<SmsServiceSettings> & {
	methods: SmsServiceMethods;
};

export type SmsThis = Service<SmsServiceSettings>;

export interface SendSmsParams {
	to: string;
	message: string;
	mediaUrl?: string;
}

export const SmsSendParamsValidator = {
	to: { type: "string" },
	message: { type: "string" },
	mediaUrl: { type: "string", optional: true },
};
