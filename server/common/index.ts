import ConfigClass from "./config";

const config = new ConfigClass();
console.log(JSON.stringify(config, null, 2));
export { config as Config };
