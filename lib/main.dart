import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rfkicks_admin/views/admin_analytics_screen.dart';
import 'package:rfkicks_admin/views/admin_dashboard_screen.dart';
import 'package:rfkicks_admin/views/admin_login_screen.dart';
import 'package:rfkicks_admin/views/admin_orders_screen.dart';
import 'package:rfkicks_admin/views/admin_services_screen.dart';
import 'package:rfkicks_admin/views/admin_users_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Internet Connectivity Checker
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final Connectivity _connectivity = Connectivity();
  bool _isSnackbarActive = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _initConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> result =
        await _connectivity.checkConnectivity();
    _updateConnectionStatus(result.first); // Use the first result
  }

  Future<void> _initConnectivity() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results.first); // Use the first result
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (!mounted) return;

    if (result == ConnectivityResult.none) {
      if (!_isSnackbarActive) {
        _isSnackbarActive = true;
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Please check your connection',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF323232),
            behavior: SnackBarBehavior.fixed,
            duration: const Duration(days: 365),
            animation: CurvedAnimation(
              parent: const AlwaysStoppedAnimation(1),
              curve: Curves.easeOutCirc,
            ),
          ),
        );
      }
    } else {
      if (_isSnackbarActive) {
        _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        _isSnackbarActive = false;
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.wifi_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Back Online',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.fixed,
            duration: const Duration(seconds: 3),
            animation: CurvedAnimation(
              parent: const AlwaysStoppedAnimation(1),
              curve: Curves.easeOutCirc,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Outfit',
      ),
      home: AdminLoginScreen(),
      routes: {
        '/admin-login': (context) => AdminLoginScreen(),
        '/admin-dashboard': (context) => AdminDashboardScreen(),
        '/admin-services': (context) => AdminServicesScreen(),
        '/admin-users': (context) => AdminUsersScreen(),
        '/admin-analytics': (context) => AdminAnalyticsScreen(),
        '/admin-orders': (context) => AdminOrdersScreen(),
      },
    );
  }
}
