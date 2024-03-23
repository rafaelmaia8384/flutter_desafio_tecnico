import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'model_file_attachment.dart';

class Repository {
  static const baseUrl = 'http://digital-aligner.ddns.net:3000';

  static Future<http.Response> register(
      String fullName, String email, String password) async {
    return await postRequest(
      '/api/v1/users',
      {
        'nome_completo': fullName,
        'email': email,
        'password': password,
      },
      headers: {
        'Content-Type': 'Application/Json',
      },
    );
  }

  static Future<http.Response> login(String email, String password) async {
    return await postRequest(
      '/login',
      {
        'email': email,
        'password': password,
      },
      headers: {
        'Content-Type': 'Application/Json',
      },
    );
  }

  static Future<http.Response> getFileUploadList(String authorization) async {
    return await getRequest(
      '/api/v1/uploads',
      headers: {
        'Content-Type': 'Application/Json',
        'Authorization': 'Bearer $authorization',
      },
    );
  }

  static Future<http.Response> getUser(
      String authorization, String userId) async {
    return await getRequest(
      '/api/v1/users/$userId',
      headers: {
        'Content-Type': 'Application/Json',
        'Authorization': 'Bearer $authorization',
      },
    );
  }

  static Future<http.Response> deleteFile(
      String authorization, String id) async {
    return await deleteRequest(
      '/api/v1/uploads/$id',
      headers: {
        'Content-Type': 'Application/Json',
        'Authorization': 'Bearer $authorization',
      },
    );
  }

  static Future<http.Response> postRequest(String query, Object body,
      {Map<String, String>? headers}) async {
    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl$query'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 60),
          );
    } catch (error) {
      log(error.toString());
      return http.Response('', 500);
    }
    return response;
  }

  static Future<http.Response> getRequest(String query,
      {Map<String, String>? headers}) async {
    http.Response response;
    try {
      response = await http
          .get(
            Uri.parse('$baseUrl$query'),
            headers: headers,
          )
          .timeout(
            const Duration(seconds: 60),
          );
    } catch (error) {
      log(error.toString());
      return http.Response('', 500);
    }
    return response;
  }

  static Future<http.Response> deleteRequest(String query,
      {Map<String, String>? headers}) async {
    http.Response response;
    try {
      response = await http
          .delete(
            Uri.parse('$baseUrl$query'),
            headers: headers,
          )
          .timeout(
            const Duration(seconds: 60),
          );
    } catch (error) {
      log(error.toString());
      return http.Response('', 500);
    }
    return response;
  }

  static Future<http.Response> sendFile(
      String authorization, FileAttachment file) async {
    http.Response response;
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/api/v1/uploads'));
      request.files.add(
        http.MultipartFile.fromBytes(
          'arquivo',
          file.fileBytes,
          filename: file.fileName,
        ),
      );
      request.headers.addAll(
        {
          'Content-Type': 'Application/Json',
          'Authorization': 'Bearer $authorization',
        },
      );
      final streamResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );
      response = await http.Response.fromStream(streamResponse);
    } catch (error) {
      log(error.toString());
      return http.Response('', 500);
    }
    return response;
  }
}
