import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiService {
  Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, String>? queryParams,
      }) async {
    // Build URI
    Uri uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    dev.log('🌐 API Call: $uri');

    try {
      final response = await http.get(uri).timeout(
        ApiConstants.receiveTimeout,
      );

      dev.log('✅ Response: ${response.statusCode}');
      return _processResponse(response);
    } on SocketException catch (e) {
      dev.log('❌ SocketException: $e');
      throw Exception('No Internet Connection');
    } on TimeoutException catch (e) {
      dev.log('❌ TimeoutException: $e');
      throw Exception('Server Request Timeout');
    } on HandshakeException catch (e) {
      dev.log('❌ HandshakeException (SSL): $e');
      throw Exception('SSL Certificate Error');
    } catch (e) {
      dev.log('❌ Unknown Error: $e');
      throw Exception('Unexpected Error: $e');
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body) as Map<String, dynamic>;
      case 400:
        throw Exception('Bad Request');
      case 401:
        throw Exception('Unauthorised');
      case 404:
        throw Exception('Not Found');
      case 500:
        throw Exception('Internal Server Error');
      default:
        throw Exception('Server Error: ${response.statusCode}');
    }
  }
}