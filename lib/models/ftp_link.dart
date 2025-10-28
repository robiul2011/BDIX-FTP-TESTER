class FtpLink {
  final String url;
  bool isWorking;
  int responseTime;
  DateTime lastChecked;
  double downloadSpeed;
  String? errorMessage;
  String status;

  FtpLink({
    required this.url,
    this.isWorking = false,
    this.responseTime = 0,
    DateTime? lastChecked,
    this.downloadSpeed = 0.0,
    this.errorMessage,
    this.status = 'pending',
  }) : lastChecked = lastChecked ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'isWorking': isWorking,
      'responseTime': responseTime,
      'lastChecked': lastChecked.toIso8601String(),
      'downloadSpeed': downloadSpeed,
      'errorMessage': errorMessage,
      'status': status,
    };
  }

  factory FtpLink.fromJson(Map<String, dynamic> json) {
    return FtpLink(
      url: json['url'],
      isWorking: json['isWorking'] ?? false,
      responseTime: json['responseTime'] ?? 0,
      lastChecked: json['lastChecked'] != null
          ? DateTime.parse(json['lastChecked'])
          : DateTime.now(),
      downloadSpeed: json['downloadSpeed'] ?? 0.0,
      errorMessage: json['errorMessage'],
      status: json['status'] ?? 'pending',
    );
  }
}
