import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/proxy_config.dart';
import '../providers/proxy_provider.dart';
import '../utils/app_theme.dart';

class ProxyDialog extends ConsumerStatefulWidget {
  const ProxyDialog({super.key});

  @override
  ConsumerState<ProxyDialog> createState() => _ProxyDialogState();
}

class _ProxyDialogState extends ConsumerState<ProxyDialog> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late bool _enabled;
  bool _obscurePassword = true;
  bool _isTesting = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    final proxyConfig = ref.read(proxyProvider);
    _hostController = TextEditingController(text: proxyConfig.host);
    _portController = TextEditingController(text: proxyConfig.port.toString());
    _usernameController = TextEditingController(text: proxyConfig.username ?? '');
    _passwordController = TextEditingController(text: proxyConfig.password ?? '');
    _enabled = proxyConfig.enabled;
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveProxy() {
    final host = _hostController.text.trim();
    final portText = _portController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (_enabled && (host.isEmpty || portText.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both host and port'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final port = int.tryParse(portText) ?? 1080;

    final config = ProxyConfig(
      host: host,
      port: port,
      username: username.isEmpty ? null : username,
      password: password.isEmpty ? null : password,
      enabled: _enabled,
    );

    ref.read(proxyProvider.notifier).updateProxy(config);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _enabled ? 'Proxy enabled' : 'Proxy disabled',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.success,
      ),
    );
  }

  Future<void> _testProxy() async {
    final host = _hostController.text.trim();
    final portText = _portController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (host.isEmpty || portText.isEmpty) {
      setState(() {
        _testResult = 'Please enter both host and port';
      });
      return;
    }

    final port = int.tryParse(portText) ?? 1080;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final dio = Dio();
      
      // Configure proxy
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (uri) {
            return 'PROXY $host:$port';
          };
          if (username.isNotEmpty && password.isNotEmpty) {
            client.addProxyCredentials(
              host,
              port,
              '',
              HttpClientBasicCredentials(username, password),
            );
          }
          return client;
        },
      );

      // Test connection with a quick HTTP request
      final response = await dio.get(
        'http://httpbin.org/ip',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _testResult = 'Connection successful!';
          _isTesting = false;
        });
      } else {
        setState(() {
          _testResult = 'Connection failed: ${response.statusCode}';
          _isTesting = false;
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'Connection failed: ${e.toString().split('\n').first}';
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SOCKS5 Proxy Settings',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Configure proxy for testing',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Enable/Disable switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security_rounded,
                      color: _enabled ? AppTheme.success : theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Proxy',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _enabled ? 'Proxy is active' : 'Proxy is disabled',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _enabled,
                      onChanged: (value) => setState(() => _enabled = value),
                      activeColor: AppTheme.success,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Proxy fields
              AnimatedOpacity(
                opacity: _enabled ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    // Host
                    TextField(
                      controller: _hostController,
                      enabled: _enabled,
                      decoration: InputDecoration(
                        labelText: 'Proxy Host',
                        hintText: 'e.g., 127.0.0.1 or proxy.example.com',
                        prefixIcon: const Icon(Icons.dns_rounded, size: 20),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Port
                    TextField(
                      controller: _portController,
                      enabled: _enabled,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Proxy Port',
                        hintText: 'e.g., 1080',
                        prefixIcon: const Icon(Icons.settings_ethernet_rounded, size: 20),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Username (optional)
                    TextField(
                      controller: _usernameController,
                      enabled: _enabled,
                      decoration: const InputDecoration(
                        labelText: 'Username (Optional)',
                        hintText: 'Leave empty if no auth required',
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password (optional)
                    TextField(
                      controller: _passwordController,
                      enabled: _enabled,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password (Optional)',
                        hintText: 'Leave empty if no auth required',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Only SOCKS5 proxy is supported. Make sure your proxy server is running.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Test result display
              if (_testResult != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _testResult!.contains('successful')
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _testResult!.contains('successful')
                          ? AppTheme.success.withOpacity(0.3)
                          : AppTheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testResult!.contains('successful')
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                        color: _testResult!.contains('successful')
                            ? AppTheme.success
                            : AppTheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _testResult!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _testResult!.contains('successful')
                                ? AppTheme.success
                                : AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_testResult != null) const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isTesting ? null : _testProxy,
                      icon: _isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.network_check_rounded, size: 18),
                      label: Text(_isTesting ? 'Testing...' : 'Test'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.info,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProxy,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
