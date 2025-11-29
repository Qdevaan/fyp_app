import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum ConnectionStatus { disconnected, connecting, connected, error }

class ConnectionService with ChangeNotifier {
  // --- Private State ---
  String _serverUrl = '';
  ConnectionStatus _status = ConnectionStatus.disconnected;
  Timer? _statusCheckTimer;
  bool _isChecking = false;

  // --- Public Getters ---
  String get serverUrl => _serverUrl;
  // Backwards compatibility if needed, but prefer serverUrl
  String get serverIp => _serverUrl; 
  ConnectionStatus get status => _status;
  bool get isConnected => _status == ConnectionStatus.connected;

  // --- Initialization ---
  ConnectionService() {
    _loadSavedUrlAndInitialCheck();
  }

  // --- URL Management ---
  Future<void> _loadSavedUrlAndInitialCheck() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString('server_url') ?? '';
    notifyListeners();
    
    if (_serverUrl.isNotEmpty) {
      await checkConnection(notifyResult: false);
    }
    _startPeriodicChecks();
  }

  Future<void> saveUrl(String url) async {
    // Normalize URL: remove trailing slash, ensure protocol
    String cleanUrl = url.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    
    // If user just types an IP or domain, assume http (or https for ngrok)
    if (!cleanUrl.startsWith('http')) {
      if (cleanUrl.contains('ngrok')) {
        cleanUrl = 'https://$cleanUrl';
      } else {
        // Assume local dev server on HTTP
        cleanUrl = 'http://$cleanUrl'; 
        // If it's just an IP like 192.168.1.5, append port 8000 if missing? 
        // Better to let user type port, but we can be smart:
        if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(url.trim())) {
             cleanUrl = 'http://${url.trim()}:8000';
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', cleanUrl);
    _serverUrl = cleanUrl;
    notifyListeners();
    
    // Test immediately
    await checkConnection();
  }

  // --- Connection Testing ---
  Future<bool> checkConnection({bool notifyResult = true}) async {
    if (_serverUrl.isEmpty) {
      _updateStatus(ConnectionStatus.disconnected);
      return false;
    }

    if (_isChecking) return false;
    _isChecking = true;
    // Only show "connecting" spinner on explicit checks, not background ones
    if (notifyResult) _updateStatus(ConnectionStatus.connecting);

    try {
      print('Pinging $_serverUrl/ ...');
      final response = await http.get(
        Uri.parse('$_serverUrl/'),
        headers: {"ngrok-skip-browser-warning": "true"},
      ).timeout(const Duration(seconds: 5));

      print('Ping response: ${response.statusCode}');

      // Accept 200 (OK), 404 (Not Found), and 405 (Method Not Allowed) as "Connected"
      // This is because the root URL "/" might not have a handler on the Python server,
      // but the server is still reachable.
      if (response.statusCode == 200 || response.statusCode == 404 || response.statusCode == 405) {
        _updateStatus(ConnectionStatus.connected);
        if (notifyResult) print('Connection successful! (Status: ${response.statusCode})');
        return true;
      } else {
        print('Server returned error status: ${response.statusCode}');
        _updateStatus(ConnectionStatus.error);
        return false;
      }
    } catch (e) {
      print('Connection check failed: $e');
      _updateStatus(ConnectionStatus.error);
      return false;
    } finally {
      _isChecking = false;
    }
  }

  void _updateStatus(ConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  // --- Periodic Checks ---
  void _startPeriodicChecks() {
    _statusCheckTimer?.cancel();
    // Check every 30 seconds to keep status green
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isChecking && _serverUrl.isNotEmpty) {
        checkConnection(notifyResult: false);
      }
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }
}