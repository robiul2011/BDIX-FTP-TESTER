import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/proxy_config.dart';

final proxyProvider = StateNotifierProvider<ProxyNotifier, ProxyConfig>((ref) {
  return ProxyNotifier();
});

class ProxyNotifier extends StateNotifier<ProxyConfig> {
  ProxyNotifier() : super(ProxyConfig(host: '', port: 1080, enabled: false)) {
    _loadProxy();
  }

  Future<void> _loadProxy() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('proxy_enabled') ?? false;
    final host = prefs.getString('proxy_host') ?? '';
    final port = prefs.getInt('proxy_port') ?? 1080;
    final username = prefs.getString('proxy_username');
    final password = prefs.getString('proxy_password');

    state = ProxyConfig(
      host: host,
      port: port,
      username: username,
      password: password,
      enabled: enabled,
    );
  }

  Future<void> updateProxy(ProxyConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('proxy_enabled', config.enabled);
    await prefs.setString('proxy_host', config.host);
    await prefs.setInt('proxy_port', config.port);
    
    if (config.username != null) {
      await prefs.setString('proxy_username', config.username!);
    } else {
      await prefs.remove('proxy_username');
    }
    
    if (config.password != null) {
      await prefs.setString('proxy_password', config.password!);
    } else {
      await prefs.remove('proxy_password');
    }

    state = config;
  }

  Future<void> toggleProxy() async {
    final newConfig = state.copyWith(enabled: !state.enabled);
    await updateProxy(newConfig);
  }
}
