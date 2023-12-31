import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_application_1/lib/userdata.dart'; // Update the path as necessary
import 'lib/verificationsrequest.dart'; // Update the path as necessary

class DatabaseService with ChangeNotifier {
  IO.Socket? _socket;
  List<User> _users = [];
  List<VerificationRequest> _verificationRequests = [];

  List<User> get users => _users;
  List<VerificationRequest> get verificationRequests => _verificationRequests;

  // Initialize socket connection
  void initSocket() {
    if (_socket == null) {
      _socket = IO.io('http://192.168.1.7:3000', <String, dynamic>{ // Update with your actual server address
        'transports': ['websocket'],
        'autoConnect': false,
      });
      _socket?.connect();
      _setupSocketListeners();
      connectAndListen();
    }
  }

  // Connect and set up listeners
  void connectAndListen() {
    if (_socket == null) {
      initSocket();
    } else {
      _socket!.connect();
    }
  }

  // Method to fetch verification requests
  void fetchVerificationRequests() {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('request-verification-requests');
    } else {
      print('Socket is not connected. Attempting to reconnect.');
      initSocket(); // Attempt to initialize and connect the socket
      Future.delayed(Duration(seconds: 2), () { // Wait for a few seconds
        if (_socket!.connected) {
          _socket!.emit('request-verification-requests');
          print('yuh');
        } else {
          print('Failed to connect. Please check your network or server status.');
        }
      });
    }
  }


  // Setting up socket listeners
  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      print('Connected to the socket server');
      _socket!.emit('request-users');
    });
    _socket?.onConnectError((data) => print('Connection Error: $data'));
    _socket?.onError((data) => print('Error socket: $data'));

    _socket?.on('users', (data) {
      _users = (data as List).map((u) => User.fromMap(u)).toList();
      notifyListeners();
    });

    // _socket?.on('verification-requests', (data) {
    //   _verificationRequests = (data as List)
    //       .map((v) => VerificationRequest.fromMap(v))
    //       .toList();
    //   notifyListeners();
    // });

    _socket?.on('disconnect', (_) => print('Disconnected from the server'));
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket = null;
    super.dispose();
  }
}
