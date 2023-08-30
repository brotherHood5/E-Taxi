import type { IDriver } from "../../../../../entities";

interface DriverSeatFinderStrategy {
	findDriver(drivers: IDriver[]): IDriver[];
}

export default DriverSeatFinderStrategy;
