import amqp from "amqplib";
import _ from "lodash";
import type { ServiceSchema } from "moleculer";
import { Errors } from "moleculer";

const validateOption = (queueOption: any) =>
	_.defaultsDeep(queueOption, {
		channel: {
			assert: {
				durable: true,
			},
			prefetch: 1,
		},
		consume: {
			noAck: false,
		},
	});

const AmqpService: ServiceSchema = {
	name: "amqp",
	settings: {
		url: process.env.AMQP_URL,
	},

	actions: {},

	methods: {
		async getAMQPQueue(name): Promise<amqp.Channel> {
			if (!this.$queues[name]) {
				const queueOption = validateOption(this.$queueOptions[name]);
				try {
					const channel = await this.AMQPConn.createChannel();
					channel.on("close", () => {
						delete this.$queues[name];
					});
					channel.on("error", (err: any) => {
						/* istanbul ignore next */
						this.logger.error(err);
					});
					await channel.assertQueue(name, queueOption.channel.assert);
					channel.prefetch(queueOption.channel.prefetch);
					this.$queues[name] = channel;
					this.logger.info(`AMQP Queue ${name} created`);
				} catch (err) {
					this.logger.error(err);
					throw new Errors.MoleculerError("Unable to start queue");
				}
			}
			return this.$queues[name];
		},
		async addAMQPJob(name, message, options) {
			const jobOption = _.defaultsDeep(options, {
				persistent: true,
			});

			const queue = await this.getAMQPQueue(name);
			await queue.sendToQueue(name, Buffer.from(JSON.stringify(message)), jobOption);
			this.logger.info(`AMQP Job ${name} added to queue`);
		},

		// eslint-disable-next-line @typescript-eslint/naming-convention
		async AMQPdispose() {
			if (this.AMQPConn) {
				await this.AMQPConn.close();
				this.AMQPConn = null;
			}
			this.$queues = {};
			this.$queueOptions = {};
		},
	},

	created() {
		this.AMQPConn = null;
		this.$queues = {};
		this.$queueOptions = {};
	},

	async started() {
		if (!this.settings.url) {
			throw new Errors.ServiceSchemaError("Missing options URL", null);
		}

		this.logger.warn("Connecting to AMQP server...");
		try {
			this.AMQPConn = await amqp.connect(this.settings.url);
			if (this.schema.AMQPQueues) {
				_.forIn(this.schema.AMQPQueues, async (option, name) => {
					if (typeof option.handler !== "function") {
						throw new Errors.ServiceSchemaError(
							"all AMQPQueues properties must contain handler function",
							null,
						);
					}

					this.$queueOptions[name] = validateOption(option);
					const { handler } = this.$queueOptions[name];
					delete this.$queueOptions[name].handler;

					const channel = (await this.getAMQPQueue(name)) as amqp.Channel;
					await channel.consume(
						name,
						handler.bind(this, channel),
						this.$queueOptions[name].consume,
					);
				});
			}
		} catch (err) {
			this.logger.error(err);
			throw new Errors.MoleculerError("Unable to connect to AMQP");
		}
	},

	async stopped() {
		await this.AMQPdispose();
	},
};

export default AmqpService;
