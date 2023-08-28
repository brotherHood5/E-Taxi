import type { IDriver } from "../../../../../entities";
import { VehicleType } from "../../../../../entities";
import type DriverSeatFinderStrategy from "./DriverSeatFinderStrategy ";

class SevenSeatStrategy implements DriverSeatFinderStrategy {
	findDriver(drivers: IDriver[]): IDriver[] {
		return drivers.filter((driver) => driver.vehicleType === VehicleType.SEVEN_SEATS);
	}
}

export default SevenSeatStrategy;
