class ProxyConfig {
  final String host;
  final int port;
  final String? username;
  final String? password;
  final bool enabled;

  ProxyConfig({
    required this.host,
    required this.port,
    this.username,
    this.password,
    this.enabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'enabled': enabled,
    };
  }

  factory ProxyConfig.fromJson(Map<String, dynamic> json) {
    return ProxyConfig(
      host: json['host'] ?? '',
      port: json['port'] ?? 1080,
      username: json['username'],
      password: json['password'],
      enabled: json['enabled'] ?? false,
    );
  }

  ProxyConfig copyWith({
    String? host,
    int? port,
    String? username,
    String? password,
    bool? enabled,
  }) {
    return ProxyConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() {
    if (!enabled) return 'Disabled';
    final auth = username != null && username!.isNotEmpty 
        ? '$username:***@' 
        : '';
    return 'socks5://$auth$host:$port';
  }
}
