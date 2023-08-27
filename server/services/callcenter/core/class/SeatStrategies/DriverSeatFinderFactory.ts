import { VehicleType } from "../../../../../entities";
import type DriverSeatFinderStrategy from "./DriverSeatFinderStrategy ";
import FourSeatStrategy from "./FourSeatStrategy";
import SevenSeatStrategy from "./SevenSeatStrategy";
import TwoSeatStrategy from "./TwoSeatStrategy";

class DriverSeatFinderFactory {
	createStrategy(vehicleType: VehicleType): DriverSeatFinderStrategy {
		switch (vehicleType) {
			case VehicleType.TWO_SEATS:
				return new TwoSeatStrategy();

			case VehicleType.FOUR_SEATS:
				return new FourSeatStrategy();

			case VehicleType.SEVEN_SEATS:
				return new SevenSeatStrategy();

			default:
				throw new Error("Invalid vehicle type");
		}
	}
}

const driverSeatFinderFactory = new DriverSeatFinderFactory();
export default driverSeatFinderFactory;
