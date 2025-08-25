import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';

class ConnectivityDiagnostics {
  final int pingMs;
  final bool reachable;

  const ConnectivityDiagnostics({required this.pingMs, required this.reachable});
}

class ConnectivityService {
  final DioClient _dioClient;
  final Connectivity _connectivity;

  ConnectivityService(this._dioClient, this._connectivity);

  // Stream of connectivity changes (WiFi, mobile, none, etc.)
  Stream<List<ConnectivityResult>> get statusStream => _connectivity.onConnectivityChanged;

  Future<List<ConnectivityResult>> getCurrentConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  // Checks if the device has actual internet reachability by calling a lightweight endpoint
  Future<bool> hasInternet({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final response = await _dioClient.dio.get(
        'https://www.google.com/generate_204',
        options: Options(
          method: 'GET',
          receiveTimeout: timeout,
          sendTimeout: timeout,
          followRedirects: false,
          validateStatus: (code) => code != null && code < 400,
        ),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<ConnectivityDiagnostics> runDiagnostics({Duration timeout = const Duration(seconds: 5)}) async {
    final stopwatch = Stopwatch()..start();
    final reachable = await hasInternet(timeout: timeout);
    stopwatch.stop();
    final ping = reachable ? stopwatch.elapsedMilliseconds : -1;
    return ConnectivityDiagnostics(pingMs: ping, reachable: reachable);
  }
}
