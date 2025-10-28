import 'dart:async';
import 'dart:io' show HttpClient;
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/ftp_link.dart';
import '../models/proxy_config.dart';

class FtpService {
  static const int _timeout = 5000; // 5 seconds timeout
  static const int _concurrentTests = 50; // Increased for better performance
  ProxyConfig? _proxyConfig;
  
  void setProxy(ProxyConfig? config) {
    _proxyConfig = config;
  }

  Dio _createDioClient() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: _timeout),
      receiveTimeout: const Duration(milliseconds: _timeout),
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) => status != null && status < 500,
    ));

    if (_proxyConfig != null && _proxyConfig!.enabled) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (uri) {
          final auth = _proxyConfig!.username != null && 
                       _proxyConfig!.username!.isNotEmpty
              ? '${_proxyConfig!.username}:${_proxyConfig!.password}@'
              : '';
          return 'PROXY $auth${_proxyConfig!.host}:${_proxyConfig!.port}';
        };
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    return dio;
  }

  Future<FtpLink> testLink(String url) async {
    final link = FtpLink(url: url, status: 'testing');
    final stopwatch = Stopwatch()..start();

    try {
      final dio = _createDioClient();
      
      // Try to download a small chunk to test speed
      final response = await dio.get(
        url,
        options: Options(
          headers: {'User-Agent': 'BDIX-FTP-Tester/2.0'},
          receiveDataWhenStatusError: true,
        ),
      );

      stopwatch.stop();
      
      // Consider success if we get any response
      link.isWorking = response.statusCode != null && 
                      (response.statusCode! >= 200 && response.statusCode! < 400 ||
                       response.statusCode == 401 || // Auth required = server is up
                       response.statusCode == 403);  // Forbidden = server is up
      
      link.responseTime = stopwatch.elapsedMilliseconds;
      link.status = link.isWorking ? 'online' : 'offline';
      
      // Calculate approximate download speed (if successful)
      if (link.isWorking && response.data != null) {
        final dataSize = response.data.toString().length;
        final timeInSeconds = stopwatch.elapsedMilliseconds / 1000;
        link.downloadSpeed = timeInSeconds > 0 
            ? (dataSize / 1024) / timeInSeconds // KB/s
            : 0;
      }
    } catch (e) {
      stopwatch.stop();
      link.isWorking = false;
      link.status = 'offline';
      link.responseTime = _timeout;
      link.errorMessage = e.toString().length > 50 
          ? '${e.toString().substring(0, 50)}...' 
          : e.toString();
    }

    return link;
  }

  Stream<List<FtpLink>> testMultipleLinksStream(List<String> urls) async* {
    final workingLinks = <FtpLink>[];
    final chunks = <List<String>>[];

    // Split URLs into chunks for concurrent testing
    for (var i = 0; i < urls.length; i += _concurrentTests) {
      chunks.add(
        urls.sublist(
            i,
            i + _concurrentTests > urls.length
                ? urls.length
                : i + _concurrentTests),
      );
    }

    // Process each chunk concurrently
    for (final chunk in chunks) {
      // Test all URLs in chunk concurrently
      final futures = chunk.map((url) => testLink(url));
      final results = await Future.wait(futures);
      
      // Add working links to the list
      workingLinks.addAll(results.where((link) => link.isWorking));

      // Yield the current list of working links
      yield List<FtpLink>.from(workingLinks);
    }
  }

  Future<bool> testHttpGet(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'BDIX-FTP-Tester/2.0'},
      ).timeout(const Duration(milliseconds: _timeout));

      return response.statusCode >= 200 && response.statusCode < 400 ||
          response.statusCode == 401;
    } catch (e) {
      return false;
    }
  }
}
