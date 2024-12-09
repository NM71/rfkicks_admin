import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rfkicks_admin/views/admin_users_screen.dart';

import '../models/admin_services.dart';


class AdminApiService {
  static const String baseUrl = 'https://rfkicks.com/api';
  static const Duration timeoutDuration = Duration(seconds: 10);

  // static Future<String> adminLogin(String username, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/admin_login.php'),
  //       body: json.encode({
  //         'username': username,
  //         'password': password,
  //       }),
  //       headers: {'Content-Type': 'application/json'},
  //     ).timeout(timeoutDuration);

  //     final data = json.decode(response.body);
  //     if (response.statusCode == 200 && data['status'] == 'success') {
  //       return data['token'];
  //     } else {
  //       throw Exception(data['message'] ?? 'Login failed');
  //     }
  //   } catch (e) {
  //     throw Exception('Error during admin login: $e');
  //   }
  // }

  // Admin Authentication
  static Future<String> adminLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/admin_login.php'),
        body: json.encode({
          'username': username,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['token'];
      } else {
        throw Exception(data['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  static Future<bool> validateAdminToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/validate_admin_token.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Admin Services CRUD
  static Future<List<Service>> getServices() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(
        Uri.parse('$baseUrl/admin/services.php?all=true&t=$timestamp'),
        // Uri.parse('$baseUrl/admin/services.php'),
        // Uri.parse('$baseUrl/admin/services.php?limit=100'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ).timeout(timeoutDuration);

      print(
          'Raw API Response: ${response.body}'); // This will show us the complete raw data

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final services = data.map((json) => Service.fromJson(json)).toList();

        // Print each service ID and type
        services.forEach((service) {
          print('Service ID: ${service.id}, Type: ${service.serviceType}');
        });

        return services;
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      throw Exception('Error loading services: $e');
    }
  }

  // static Future<List<Service>> getServices() async {
  //   try {
  //     final response = await http.get(
  //       // Uri.parse('$baseUrl/admin/services.php'),
  //       Uri.parse('$baseUrl/admin/services.php?all=true'),
  //       headers: {'Content-Type': 'application/json'},
  //     ).timeout(timeoutDuration);

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data.map((json) => Service.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to load services');
  //     }
  //   } catch (e) {
  //     throw Exception('Error loading services: $e');
  //   }
  // }

  // static Future<void> addService(Map<String, dynamic> serviceData) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/admin/services.php'),
  //       body: json.encode(serviceData),
  //       headers: {'Content-Type': 'application/json'},
  //     ).timeout(timeoutDuration);

  //     if (response.statusCode != 201) {
  //       throw Exception('Failed to add service');
  //     }
  //   } catch (e) {
  //     throw Exception('Error adding service: $e');
  //   }
  // }

  // static Future<void> updateService(
  //     int id, Map<String, dynamic> serviceData) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('$baseUrl/admin/services.php?id=$id'),
  //       body: json.encode(serviceData),
  //       headers: {'Content-Type': 'application/json'},
  //     ).timeout(timeoutDuration);

  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to update service');
  //     }
  //   } catch (e) {
  //     throw Exception('Error updating service: $e');
  //   }
  // }

  static Future<Service> addService(Map<String, dynamic> serviceData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/services.php'),
        body: json.encode(serviceData),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Service.fromJson(data['service']);
      } else {
        throw Exception('Failed to add service');
      }
    } catch (e) {
      throw Exception('Error adding service: $e');
    }
  }

  static Future<Service> updateService(
      int id, Map<String, dynamic> serviceData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/services.php?id=$id'),
        body: json.encode(serviceData),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Service.fromJson(data['service']);
      } else {
        throw Exception('Failed to update service');
      }
    } catch (e) {
      throw Exception('Error updating service: $e');
    }
  }

  static Future<void> deleteService(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/services.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete service');
      }
    } catch (e) {
      throw Exception('Error deleting service: $e');
    }
  }

  // Services Image Upload
  static Future<String> uploadServiceImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_service_image.php'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        return jsonData['url'];
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // --------------------------------------------------------------------
  // Users Screen Functions
  //---------------------------------------------------------------------

  // Add these functions in AdminApiService class

// Get all users
  static Future<List<UserData>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/get_users.php'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error loading users: $e');
    }
  }

// Get single user details
  static Future<UserData> getUserDetails(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/get_user_details.php?id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserData.fromJson(data);
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      throw Exception('Error loading user details: $e');
    }
  }

// Update user status
  static Future<void> updateUserStatus(int userId, int status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users/update_user_status.php'),
        body: json.encode({
          'user_id': userId,
          'status': status,
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception('Failed to update user status');
      }
    } catch (e) {
      throw Exception('Error updating user status: $e');
    }
  }

// Delete user
  static Future<void> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/delete_user.php?id=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }
}
