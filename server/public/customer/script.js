/* eslint-disable */
// Base Layer with Open Street Maps
var baseMapLayer = new ol.layer.Tile({
	source: new ol.source.OSM(),
});

//Construct the Map Object
var map = new ol.Map({
	target: "map",
	layers: [baseMapLayer],
	view: new ol.View({
		center: ol.proj.fromLonLat([106.759822, 10.916225]),
		zoom: 15, //Initial Zoom Level
	}),
});

//Set up an  Style for the marker note the image used for marker
var customerIconStyle = new ol.style.Style({
	image: new ol.style.Icon({
		src: "/user.png", // Replace with your custom icon path
		anchor: [0.5, 1], // Anchor point of the icon (center bottom)
		scale: 0.04, // Scale factor of the icon
	}),
});

var driverIconStyle = new ol.style.Style({
	image: new ol.style.Icon({
		src: "/car.png", // Replace with your custom icon path
		anchor: [0.5, 1], // Anchor point of the icon (center bottom)
		scale: 0.04, // Scale factor of the icon
	}),
});

var onDriverIconStyle = new ol.style.Style({
	image: new ol.style.Icon({
		src: "/on_car.png", // Replace with your custom icon path
		anchor: [0.5, 1], // Anchor point of the icon (center bottom)
		scale: 0.04, // Scale factor of the icon
	}),
});

// //Adding a marker on the map
// const src = [106.752583612375, 10.918649726255254];
// var marker = new ol.Feature({
// 	geometry: new ol.geom.Point(ol.proj.fromLonLat(src)),
// });
// marker.setStyle(customerIconStyle);

var vectorSource = new ol.source.Vector({});

var markerVectorLayer = new ol.layer.Vector({
	source: vectorSource,
});

// add style to Vector layer style map
map.addLayer(markerVectorLayer);

var booking = {
	customerId: "64d8abbacd43b24158a8c2f3",
	phoneNumber: "0972360214",
	vehicleType: "2",
	pickupAddr: {},
	destAddr: {},
};

const logPos = document.getElementById("logPos");
function book() {
	if (
		!booking.pickupAddr.lat ||
		!booking.pickupAddr.lon ||
		!booking.destAddr.lat ||
		!booking.destAddr.lon
	) {
		return;
	}
	var el = document.createElement("div");
	el.innerHTML = "Booking: <br>" + "<pre>" + JSON.stringify(booking, null, 2) + "</pre>";
	logPos.appendChild(el);

	console.log(booking);
	socket.emit("call", "bookingSystem.bookThroughApp", booking);
}

function logCoord(coord) {
	var el = document.createElement("div");
	el.innerHTML =
		"Lon: " + coord.lon + " Lat: " + coord.lat + "| [" + coord.lon + "," + coord.lat + "]";
	logPos.appendChild(el);
}

function convertCoord(coordinate) {
	const convertedCoordinate = ol.proj.toLonLat(coordinate, "EPSG:3857");
	const coordObj = {
		lat: convertedCoordinate[1],
		lon: convertedCoordinate[0],
	};
	return coordObj;
}

function updateLocation(coordinate) {
	socket.emit("call", "storeSystem.updateDriverLocation", coordinate);
}

let myMarkerFeature = null;
function showMyMarker(coord) {
	if (myMarkerFeature) {
		vectorSource.removeFeature(myMarkerFeature);
	}
	myMarkerFeature = new ol.Feature({
		geometry: new ol.geom.Point(ol.proj.fromLonLat([coord.lon, coord.lat])),
	});

	myMarkerFeature.setStyle(customerIconStyle);
	vectorSource.addFeature(myMarkerFeature);
}

let markerFeature = null;
function showDriverMarker(coord) {
	if (markerFeature) {
		vectorSource.removeFeature(markerFeature);
	}
	markerFeature = new ol.Feature({
		geometry: new ol.geom.Point(ol.proj.fromLonLat([coord.lon, coord.lat])),
	});

	markerFeature.setStyle(driverIconStyle);
	vectorSource.addFeature(markerFeature);
}

let onGoingDriverMarker = null;
function showOnDriverMarker(coord) {
	if (onGoingDriverMarker) {
		vectorSource.removeFeature(onGoingDriverMarker);
	}
	onGoingDriverMarker = new ol.Feature({
		geometry: new ol.geom.Point(ol.proj.fromLonLat([coord.lon, coord.lat])),
	});

	onGoingDriverMarker.setStyle(onDriverIconStyle);
	vectorSource.addFeature(onGoingDriverMarker);
}

map.on("click", function (event) {
	const clickedCoordinate = convertCoord(event.coordinate);
	logCoord(clickedCoordinate);
	showDriverMarker(clickedCoordinate);
	booking.destAddr.lat = clickedCoordinate.lat;
	booking.destAddr.lon = clickedCoordinate.lon;
});

// Test
let authToken =
	"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7Il9pZCI6IjY0ZDhhYmJhY2Q0M2IyNDE1OGE4YzJmMyIsImZ1bGxOYW1lIjoiRMawxqFuZyBRdWFuZyBWaW5oIiwicGhvbmVOdW1iZXIiOiIwOTcyMzYwMjE0IiwicGFzc3dvcmRIYXNoIjoiJDJhJDEwJDNCN1pPdVhRQUxBUUJlTzZXOExrYXV5VmpodFhwbDEwQ3ZLbXkuNTFZV3JYWEJjdWIzUTRtIiwicGhvbmVOdW1iZXJWZXJpZmllZCI6dHJ1ZSwiZW5hYmxlIjp0cnVlLCJhY3RpdmUiOnRydWUsImNyZWF0ZWRBdCI6IjIwMjMtMDgtMTNUMTA6MDg6NTguODc4WiIsInVwZGF0ZWRBdCI6IjIwMjMtMDgtMTNUMTA6MDg6NTguODc4WiIsInJvbGVzIjpbIkNVU1RPTUVSIl19LCJpYXQiOjE2OTMzMjM4MjUsImV4cCI6MTY5MzkyODYyNX0.EhLxvjO0q7-Hg72PZgvt7qjIgogKQj8eIxhjC8cA_LE";
const eventDiv = document.getElementById("events");
const resultDiv = document.getElementById("res");
var socket = io("ws://localhost:3003/customers", {
	transports: ["websocket", "polling", "flashsocket"],
	auth: {
		token: authToken,
	},
	query: {
		service: "customers",
	},
});

socket.on("booking_updated", (data) => {
	console.log(JSON.stringify(data, null, 2));
});

socket.on("connect", function () {
	console.log("Websocket connection established!");
	if (navigator.geolocation) {
		navigator.geolocation.getCurrentPosition((pos) => {
			const coord = {
				lat: pos.coords.latitude,
				lon: pos.coords.longitude,
			};
			logCoord(coord);
			showMyMarker(coord);
			booking.pickupAddr.lat = coord.lat;
			booking.pickupAddr.lon = coord.lon;
			try {
				map.getView().setCenter(ol.proj.fromLonLat([coord.lon, coord.lat]));
			} catch (e) {
				console.log(e);
			}
		});
	}
});

socket.on("driver_update_location", function (data) {
	console.log(data);
	showOnDriverMarker(data);
});

socket.on("disconnect", function () {
	console.log("Websocket disconnected!");
});

socket.on("connect_error", (error) => {
	console.log(error);
});
