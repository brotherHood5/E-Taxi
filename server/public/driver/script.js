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

// //Adding a marker on the map
// var marker = new ol.Feature({
// 	geometry: new ol.geom.Point(ol.proj.fromLonLat([80.24586, 12.9859])),
// });
// marker.setStyle(iconStyle);

var vectorSource = new ol.source.Vector();
var markerVectorLayer = new ol.layer.Vector({
	source: vectorSource,
});

// add style to Vector layer style map
map.addLayer(markerVectorLayer);

let markerFeature = null;

function logCoord(coord) {
	const logPos = document.getElementById("logPos");
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

// const sendLoc = setInterval(() => {
// 	if (!markerFeature) return;
// 	updateLocation(convertCoord(markerFeature.getGeometry().getCoordinates()));
// }, 500);

const customerId = "64de13237ee4b5326542e99e";
function updateLocation(coordinate) {
	const customerIdValue = document.querySelector("input[name=customerId]").value;
	socket.emit("call", "bookingSystem.updateDriverLocation", {
		...coordinate,
		customerId: customerIdValue,
	});
}

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

map.on("click", function (event) {
	const clickedCoordinate = convertCoord(event.coordinate);
	logCoord(clickedCoordinate);

	showDriverMarker(clickedCoordinate);
	updateLocation(clickedCoordinate);
});

// Test
var baseUrl = "http://localhost:3002/api/v1";
var authToken = "";
async function login() {
	const phoneNumber = document.querySelector("input[name=phoneNumber]").value;
	const password = document.querySelector("input[name=password]").value;
	const response = await fetch(`${baseUrl}/drivers/login`, {
		method: "POST",
		body: JSON.stringify({ phoneNumber, password }), // string or object
		headers: {
			"Content-Type": "application/json",
		},
	});
	const myJson = await response.json();
	console.log(myJson);

	authToken = myJson.accessToken;
	main();
}

window.onload = function () {
	window.addEventListener("beforeunload", function () {
		if (window.socket) {
			console.log("Closing socket");
			window.socket.close();
			window.socket = null;
			socket.close();
		}
	});
};

function main() {
	var booking;
	const eventDiv = document.getElementById("events");
	const resultDiv = document.getElementById("res");
	console.log("Closing socket");
	if (window.socket) {
		window.socket.close();
		window.socket = null;
		if (socket) socket.close();
	}
	var socket = io("ws://localhost:3003/drivers", {
		transports: ["websocket", "polling", "flashsocket"],
		auth: {
			token: authToken,
		},
		query: {
			service: "drivers",
		},
	});

	window.socket = socket;
	var currBookReceive = null;

	function onBookingFound(data) {
		socket.off("booking_found");
		console.log("Data: ", data);
		currBookReceive = data;
		if (currBookReceive) {
			socket.emit("call", "bookingSystem.driverAccept", data, (err, res) => {
				console.log("Accepted: ", res);
				if (!res) {
					currBookReceive = null;
					socket.on("booking_found", onBookingFound);
				}
			});
		}
	}
	socket.on("booking_found", onBookingFound);

	socket.on("connect", function () {
		console.log("Websocket connection established!");
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition((pos) => {
				try {
					socket.emit(
						"call",
						"bookingSystem.driverConnected",
						{
							lat: pos.coords.latitude,
							lon: pos.coords.longitude,
						},
						(err, res) => {
							console.log(res);
						},
					);
					const coord = {
						lat: pos.coords.latitude,
						lon: pos.coords.longitude,
					};
					showDriverMarker(coord);
					map.getView().setCenter(ol.proj.fromLonLat([coord.lon, coord.lat]));
				} catch (e) {
					console.log(e);
				}
			});
		} else {
			console.log("No geolocation");
		}
	});

	socket.on("disconnect", function () {
		console.log("Websocket disconnected!");
	});

	socket.on("connect_error", (error) => {
		console.log(error);
	});
}
