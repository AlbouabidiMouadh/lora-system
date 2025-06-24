import 'dart:convert';
import 'package:flutter_application/config/config.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/utils/api_exception.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = Config.baseUrl;
  final AuthService _authService = AuthService();

  // Test server connection
  Future<bool> testConnection() async {
    try {
      print('Testing server connection...');
      print('Test URL: $baseUrl/auth/me');

      final token = await _authService.getToken();
      if (token == null) {
        print('No token found, testing basic connection');
        // If no token, just test the basic connection
        final response = await http
            .get(Uri.parse('$baseUrl/auth/login'))
            .timeout(const Duration(seconds: 5));

        print('Status code (login): ${response.statusCode}');
        return response.statusCode < 500;
      }

      // Test with the token
      final response = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      print('Status code: ${response.statusCode}');
      print('Response: ${response.body}');

      return response.statusCode < 500;
    } catch (e) {
      print('Connection test error: $e');
      return false;
    }
  }

  // GET method with authentication token
  Future<dynamic> get(String endpoint) async {
    try {
      // Test connection before each request
    /*   final isConnected = await testConnection();
      if (!isConnected) {
        throw ApiException('No connection to server.');
      } */

      final token = await _authService.getToken();
      final fullUrl = '$baseUrl/$endpoint';
      print('Full URL: $fullUrl');
      print('Token: ${token != null ? 'present' : 'absent'}');

      final response = await http
          .get(
            Uri.parse(fullUrl),
            headers: token != null ? {'Authorization': 'Bearer $token'} : {},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out. Please try again.');
            },
          );

      print('Status code: ${response.statusCode}');
      print('Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print('Decoded response: $decodedResponse');
        return decodedResponse;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw ApiException('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        throw ApiException('Resource not found.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException  catch (e) {
      print('Client error: $e');
      throw ApiException('Cannot connect to server. Please try again.');
    } catch (e) {
      print('Network error: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw Exception('Connection error.');
      }
    }
  }

  // POST method with authentication token
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final token = await _authService.getToken();
      final fullUrl = '$baseUrl/$endpoint';
      print('POST request to: $fullUrl');
      print('Data: $data');

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('Status code: ${response.statusCode}');
      print('Raw response: ${response.body}');
      final decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return decodedResponse;
      } else if (response.statusCode == 401) {
        throw ApiException('Session expired. Please log in again.');
      } else {
        throw ApiException(decodedResponse['message'] ?? 'Server error.');
      }
    } catch (e) {
      print('Network error: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw Exception('Network error: $e');
      }
    }
  }

  // PUT method with authentication token
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final token = await _authService.getToken();
      final fullUrl = '$baseUrl/$endpoint';
      print('PUT request to: $fullUrl');
      print('Data: $data');

      final response = await http.put(
        Uri.parse(fullUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('Status code: ${response.statusCode}');
      print('Raw response: ${response.body}');
      final decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return decodedResponse;
      } else if (response.statusCode == 401) {
        throw ApiException('Session expired. Please log in again.');
      } else {
        throw ApiException(decodedResponse['message'] ?? 'Server error.');
      }
    } catch (e) {
      print('Network error: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw Exception('Network error: $e');
      }
    }
  }

  // PATCH method with authentication token
  Future<dynamic> patch(String endpoint, dynamic data) async {
    try {
      final token = await _authService.getToken();
      final fullUrl = '$baseUrl/$endpoint';
      print('PATCH request to: $fullUrl');
      print('Data: $data');

      final response = await http.patch(
        Uri.parse(fullUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('Status code: ${response.statusCode}');
      print('Raw response: ${response.body}');
      final decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return decodedResponse;
      } else if (response.statusCode == 401) {
        throw ApiException('Session expired. Please log in again.');
      } else {
        throw ApiException(decodedResponse['message'] ?? 'Server error.');
      }
    } catch (e) {
      print('Network error: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw Exception('Network error: $e');
      }
    }
  }

  // DELETE method with authentication token
  Future<dynamic> delete(String endpoint) async {
    try {
      final token = await _authService.getToken();
      final fullUrl = '$baseUrl/$endpoint';
      print('DELETE request to: $fullUrl');

      final response = await http.delete(
        Uri.parse(fullUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Raw response: ${response.body}');
      final decodedResponse =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (response.statusCode == 200 || response.statusCode == 204) {
        return decodedResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw ApiException(decodedResponse['message'] ?? 'Server error.');
      }
    } catch (e) {
      print('Network error: $e');
      throw Exception('Network error: $e');
    }
  }
}
