import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ftp_link.dart';
import '../models/proxy_config.dart';
import '../services/ftp_service.dart';

final ftpLinksProvider =
    StateNotifierProvider<FtpLinksNotifier, List<FtpLink>>((ref) {
  return FtpLinksNotifier();
});

class FtpLinksNotifier extends StateNotifier<List<FtpLink>> {
  FtpLinksNotifier() : super([]);
  List<String> _urls = [];
  final _ftpService = FtpService();

  void initializeLinks(List<String> urls) {
    _urls = List.from(urls);
    state = [];
  }

  void setProxy(ProxyConfig? config) {
    _ftpService.setProxy(config);
  }

  Stream<List<FtpLink>> testLinksStream() async* {
    // Clear the current state to start fresh
    state = [];
    yield [];

    await for (final workingLinks
        in _ftpService.testMultipleLinksStream(_urls)) {
      state = workingLinks;
      yield workingLinks;
    }
  }

  Future<void> testAllLinks() async {
    await for (final workingLinks in testLinksStream()) {
      state = workingLinks;
    }
  }

  List<FtpLink> getWorkingLinks() {
    return state.where((link) => link.isWorking).toList();
  }

  void sortByResponseTime() {
    state = [...state]
      ..sort((a, b) => a.responseTime.compareTo(b.responseTime));
  }

  void sortBySpeed() {
    state = [...state]
      ..sort((a, b) => b.downloadSpeed.compareTo(a.downloadSpeed));
  }

  void sortByUrl() {
    state = [...state]..sort((a, b) => a.url.compareTo(b.url));
  }
}
