import type { Context } from "moleculer";
import TwilioClient from "twilio";
import { Config } from "../../common";
import { SmsConfigError, SmsCreateError, SmsSendError } from "../../core/errors";
import type { SendSmsParams, SmsServiceSchema, SmsThis } from "../../types/common";
import { SmsSendParamsValidator } from "../../types/common";

const SmsService: SmsServiceSchema = {
	name: "sms",
	authToken: Config.SMS_AUTH_TOKEN,
	settings: {
		accountSid: Config.TWILIO_ACCOUNT_SID,
		authToken: Config.TWILIO_AUTH_TOKEN,
		phoneNumber: Config.TWILIO_PHONE_NUMBER,
	},

	actions: {
		/**
		 * Send an SMS
		 *
		 * @actions
		 * @param {String} to - Target phone number
		 * @param {String} message - Message text
		 * @param {String} [mediaUrl] - Media URL
		 * @returns {String}
		 */
		send: {
			restricted: ["socket"],
			params: SmsSendParamsValidator,
			handler(this: SmsThis, ctx: Context<SendSmsParams>): Promise<any> {
				this.logger.info(
					`Sending SMS to '${ctx.params.to}' phone number. Message: ${ctx.params.message}`,
				);

				if (Config.NODE_ENV !== "development") {
					return this.sendSMS(ctx.params.to, ctx.params.message, ctx.params.mediaUrl);
				}

				return Promise.resolve();
			},
		},
	},
	methods: {
		sendSMS(to: string, body = "", mediaUrl = "") {
			this.logger.debug(`Sending SMS to '${to}' phone number. Message: ${body}`);
			return this.client.messages
				.create({
					from: this.settings.phoneNumber,
					to,
					body,
					mediaUrl,
				})
				.then((sms: any) => {
					this.logger.debug(`The SMS sent to '${to}' successfully! Sid: ${sms.sid}`);
					return sms;
				})
				.catch((err: any) => {
					this.logger.error(`Unable to send SMS to '${to}' phone number!`, err);
					return Promise.reject(new SmsSendError(`${err.message} ${err.detail}`));
				});
		},
	},

	created(): any {
		if (this.settings.accountSid == null) {
			this.logger.warn(
				"The `accountSid` is not configured. Please set the 'TWILIO_ACCOUNT_SID' environment variable!",
			);
			return Promise.reject(new SmsConfigError("The `accountSid` is not configured!"));
		}

		if (this.settings.authToken == null) {
			this.logger.warn(
				"The `authToken` is not configured. Please set the 'TWILIO_AUTH_TOKEN' environment variable!",
			);
			return Promise.reject(new SmsConfigError("The `authToken` is not configured!"));
		}

		if (this.settings.phoneNumber == null) {
			this.logger.warn(
				"The `phoneNumber` is not configured. Please set the 'TWILIO_PHONE_NUMBER' environment variable!",
			);
			return Promise.reject(new SmsConfigError("The `phoneNumber` is not configured!"));
		}

		return Promise.resolve();
	},

	started(): any {
		try {
			this.client = new (TwilioClient as any)(
				this.settings.accountSid,
				this.settings.authToken,
			);
		} catch (err) {
			this.logger.error("Unable to connect to Twilio API!", err);
			return Promise.reject(
				new SmsCreateError(`Unable to connect to Twilio API!: ${err.message}`),
			);
		}

		return Promise.resolve();
	},
};

export default SmsService;
