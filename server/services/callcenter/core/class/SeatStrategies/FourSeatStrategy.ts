import type { IDriver } from "../../../../../entities";
import { VehicleType } from "../../../../../entities";
import type DriverSeatFinderStrategy from "./DriverSeatFinderStrategy ";

class FourSeatStrategy implements DriverSeatFinderStrategy {
	findDriver(drivers: IDriver[]): IDriver[] {
		return drivers.filter((driver) => driver.vehicleType === VehicleType.FOUR_SEATS);
	}
}

export default FourSeatStrategy;
