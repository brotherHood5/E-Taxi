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

const customerId = "64d8abbacd43b24158a8c2f3";
function updateLocation(coordinate) {
	socket.emit("call", "storeSystem.updateDriverLocation", { ...coordinate, customerId });
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
var booking;
let authToken =
	"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7Il9pZCI6IjY0ZGUxMzIzN2VlNGI1MzI2NTQyZTk5ZSIsImZ1bGxOYW1lIjoiRMawxqFuZyBRdWFuZyBWaW5oIiwicGhvbmVOdW1iZXIiOiIwOTcyMzYwMjE0IiwicGFzc3dvcmRIYXNoIjoiJDJhJDEwJGdETU1oUlg3aXNrNlptRW1FMnZYaXVWWUZIeEh6ODJCcXppRVhjMGRSbHRpQWMyeGtBbkU2IiwicGhvbmVOdW1iZXJWZXJpZmllZCI6dHJ1ZSwiZW5hYmxlIjp0cnVlLCJhY3RpdmUiOnRydWUsImNyZWF0ZWRBdCI6IjIwMjMtMDgtMTdUMTI6MzE6MzEuOTYxWiIsInVwZGF0ZWRBdCI6IjIwMjMtMDgtMTdUMTI6MzE6MzEuOTYxWiIsInJvbGVzIjpbIkRSSVZFUiJdLCJ2ZWhpY2xlVHlwZSI6IjQifSwiaWF0IjoxNjkyMzMyMjQxLCJleHAiOjE2OTI5MzcwNDF9.pbF413MWlq2A225TyIOxpi1fDgx6Js7qXPGvojD1LV8";
const eventDiv = document.getElementById("events");
const resultDiv = document.getElementById("res");
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

socket.on("connect", function () {
	console.log("Websocket connection established!");
});

socket.on("disconnect", function () {
	console.log("Websocket disconnected!");
});

socket.on("connect_error", (error) => {
	console.log(error);
});