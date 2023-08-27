import type { IDriver } from "../../../../../entities";
import { VehicleType } from "../../../../../entities";
import type DriverSeatFinderStrategy from "./DriverSeatFinderStrategy ";

class TwoSeatStrategy implements DriverSeatFinderStrategy {
	findDriver(drivers: IDriver[]): IDriver[] {
		return drivers.filter((driver) => driver.vehicleType === VehicleType.TWO_SEATS);
	}
}

export default TwoSeatStrategy;
