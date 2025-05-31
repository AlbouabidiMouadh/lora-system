// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter_application/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application/config/config.dart';

class AuthService {
  final String baseUrl = Config.baseUrl;

  // Register a user
  Future<bool> register(
    String fullName,
    String phoneNumber,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': fullName,
              'phoneNumber': phoneNumber,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      print('Register response: ${response.statusCode} - ${data.toString()}');
      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
        return true;
      } else {
        return false;
      }
    } on http.ClientException {
      throw Exception(
        'Cannot connect to server. Check your internet connection.',
      );
    } on FormatException {
      throw Exception('Server response format error');
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Login a user
  Future<bool> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      final result = jsonDecode(response.body);
      final data = result['data'] ?? result; // Handle both cases

      print('Login response: ${response.statusCode} - ${result.toString()}');
      if (response.statusCode == 200) {
        // Save token and user information
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
        return true;
      } else {
        return false;
      }
    } on http.ClientException {
      throw Exception(
        'Cannot connect to server. Check your internet connection.',
      );
    } on FormatException {
      throw Exception('Server response format error');
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Check if the user is logged in
  Future<bool> isLoggedIn() async {
    try {
      print('Checking if user is logged in...');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final hasToken = token != null;
      print('Token found: $hasToken');
      return hasToken;
    } catch (e) {
      print('Error checking login status: $e');
      // If there's any error, assume user is not logged in
      return false;
    }
  }

  // Get the token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Get user data
  Future<User?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      if (userData != null) {
        return User.fromJson((jsonDecode(userData) as Map<String, dynamic>));
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Update user details
  Future<Map<String, dynamic>> updateDetails(
    String fullName,
    String email,
  ) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/updatedetails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fullName': fullName, 'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update stored user information
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data['data']));
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error updating details');
      }
    } catch (e) {
      print('Update details error: $e');
      rethrow;
    }
  }

  // Change password
  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/updatepassword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update the token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return true;
      } else {
        throw Exception(data['message'] ?? 'Error changing password');
      }
    } catch (e) {
      print('Change password error: $e');
      rethrow;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/forgotpassword'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error requesting password reset');
      }
    } catch (e) {
      print('Forgot password error: $e');
      rethrow;
    }
  }

  // Reset Password
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/auth/resetpassword/$token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'password': newPassword}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error resetting password');
      }
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }
}
