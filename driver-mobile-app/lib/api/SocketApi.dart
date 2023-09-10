import 'dart:async';
import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart';

import '../utils/app_constants.dart';

class SocketEvent {
  static const String DRIVER_CONNECTED = "driver_connected";
  static const String BOOKING_FOUND = "booking_found";

  static const String UPDATE_LOCATION = "bookingSystem.updateDriverLocation";
  static const String DRIVER_ACCEPT = "bookingSystem.driverAccept";

  static const String DRIVER_FINISH = "bookingSystem.driverFinish";
}

class SocketApi {
  static final SocketApi _singleton = SocketApi._internal();

  factory SocketApi() {
    return _singleton;
  }

  SocketApi._internal();

  static final Socket _io = io(
      ApiConstants.socketUrl,
      OptionBuilder()
          .enableForceNewConnection()
          .setTransports(['websocket'])
          .setTimeout(5000)
          .setReconnectionDelay(10000)
          .enableReconnection()
          .disableAutoConnect()
          .setQuery({
            "service": "drivers",
          })
          .setAuthFn((callback) {
            callback({
              "token": accessToken,
            });
          })
          .build());

  static late String? accessToken;
  static void setAuthToken(String token) {
    accessToken = token;
  }

  static void init() {
    if (_io.connected) {
      log('Socket is already connected: ${_io.id}', name: "Socket API");
      return;
    }
    if (accessToken == null) {
      log('Missing access token socket', name: "Socket API");
      throw Exception("Missing access token socket");
    }

    _io.connect();

    _io.onConnect((dynamic data) {
      log('Socket is connected: ${_io.id}', name: "Socket API");
    });

    _io.onConnectError((dynamic data) {
      log('Socket connect error: \n$data', name: "Socket API");
    });

    _io.on('unauthorized', (dynamic data) {
      log('Socket unauthorized', name: "Socket API");
    });

    _io.onError(
      (dynamic error) =>
          {log("Socket error: \n$error", name: "Socket API", error: error)},
    );

    _io.onDisconnect((dynamic data) {
      log('Socket disconnected', name: "Socket API");
    });
  }

  static void disconnect() {
    if (_io.connected) {
      accessToken = null;
      _io.disconnect();
      _io.close();
    }
  }

  Socket get ins => _io;
}

class StreamSocket<T> {
  StreamSocket() {
    print('Init Stream Socket: ${T.toString()}');
  }

  final _socketResponse = StreamController<T>();

  void Function(T) get addResponse => _socketResponse.sink.add;

  Stream<T> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
