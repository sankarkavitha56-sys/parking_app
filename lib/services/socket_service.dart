import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  socket_io.Socket? _socket;
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://parking-api.onrender.com',
  );

  void connect(String token) {
    if (_socket != null) return;

    _socket = socket_io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint("Socket connected");
      debugPrint("Socket ID: ${_socket!.id}");
    });

    _socket!.onDisconnect((_) {
      debugPrint("Socket disconnected");
    });

    _socket!.onConnectError((err) {
      debugPrint("Socket error: $err");
    });
  }

  void listen(void Function(dynamic data) callback) {
    _socket?.on('parkingUpdated', callback);
  }

  void disconnect() {
    _socket?.off('parkingUpdated');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {}
}
