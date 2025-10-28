import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/ftp_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/proxy_provider.dart';
import '../utils/ftp_links.dart';
import '../utils/app_theme.dart';
import '../widgets/server_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/proxy_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isTesting = false;
  bool _isPaused = false;
  int _totalTested = 0;
  int _totalLinks = 0;
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize heartbeat animation - slower and more realistic
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Slower: 2 seconds per cycle
      vsync: this,
    )..repeat();
    
    // Realistic heartbeat: lub-dub pattern with pause
    _heartbeatAnimation = TweenSequence<double>([
      // First beat (lub)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 8,
      ),
      // Short pause
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 5,
      ),
      // Second beat (dub)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 6,
      ),
      // Long pause (rest period)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 67,
      ),
    ]).animate(_heartbeatController);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(ftpLinksProvider.notifier).initializeLinks(FtpLinks.links);
      }
    });
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    super.dispose();
  }

  Future<void> _startTesting() async {
    setState(() {
      _isTesting = true;
      _isPaused = false;
      _totalTested = 0;
      _totalLinks = FtpLinks.links.length;
    });

    // Set proxy configuration
    final proxyConfig = ref.read(proxyProvider);
    ref.read(ftpLinksProvider.notifier).setProxy(proxyConfig);

    final stream = ref.read(ftpLinksProvider.notifier).testLinksStream();
    await for (final _ in stream) {
      if (mounted && !_isPaused) {
        setState(() {
          _totalTested += 50;
          if (_totalTested > _totalLinks) _totalTested = _totalLinks;
        });
      }
    }

    if (mounted) {
      setState(() => _isTesting = false);
    }
  }

  void _stopTesting() {
    setState(() {
      _isPaused = true;
      _isTesting = false;
    });
  }

  void _restartTesting() {
    ref.read(ftpLinksProvider.notifier).initializeLinks(FtpLinks.links);
    _startTesting();
  }

  void _showProxyDialog() {
    showDialog(
      context: context,
      builder: (context) => const ProxyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final links = ref.watch(ftpLinksProvider);
    final theme = Theme.of(context);
    final proxyConfig = ref.watch(proxyProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface.withOpacity(0.7),
                    theme.colorScheme.surface.withOpacity(0.5),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          // Proxy status indicator
          if (proxyConfig.enabled)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.security, size: 16, color: AppTheme.success),
                    const SizedBox(width: 4),
                    Text(
                      'SOCKS5',
                      style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Proxy settings button
          IconButton(
            icon: const Icon(Icons.vpn_lock_rounded),
            onPressed: _showProxyDialog,
            tooltip: 'SOCKS5 Proxy Settings',
          ),
          
          // Theme toggle
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.dark
                ? [
                    const Color(0xFF0f172a),
                    const Color(0xFF1e293b),
                    const Color(0xFF334155),
                  ]
                : [
                    const Color(0xFFe0e7ff),
                    const Color(0xFFddd6fe),
                    const Color(0xFFfce7f3),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Stats Section with glassmorphism
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        icon: Icons.check_circle_rounded,
                        title: 'Online',
                        value: '${links.length}',
                        color: AppTheme.success,
                        gradient: const LinearGradient(
                          colors: [AppTheme.success, Color(0xFF059669)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        icon: Icons.analytics_rounded,
                        title: 'Tested',
                        value: '$_totalTested',
                        color: AppTheme.info,
                        gradient: const LinearGradient(
                          colors: [AppTheme.info, Color(0xFF2563eb)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        icon: Icons.percent_rounded,
                        title: 'Success',
                        value: _totalLinks > 0
                            ? '${((links.length / _totalLinks) * 100).toStringAsFixed(1)}%'
                            : '0%',
                        color: AppTheme.warning,
                        gradient: const LinearGradient(
                          colors: [AppTheme.warning, Color(0xFFd97706)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Progress indicator with glassmorphism
              if (_isTesting)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _totalTested / _totalLinks,
                                minHeight: 8,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Testing servers... ${((_totalTested / _totalLinks) * 100).toStringAsFixed(0)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Server list (removed animations)
              Expanded(
                child: links.isEmpty && !_isTesting
                    ? Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cloud_off_rounded,
                                    size: 64,
                                    color: theme.colorScheme.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No servers found',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Click Start to begin testing',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: links.length,
                        itemBuilder: (context, index) {
                          final link = links[index];
                          return ServerCard(link: link, index: index);
                        },
                      ),
              ),
              
              // Footer with animated heartbeat
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.secondary,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'Built with',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedBuilder(
                            animation: _heartbeatAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _heartbeatAnimation.value,
                                child: Text(
                                  '❤️',
                                  style: TextStyle(
                                    fontSize: 13,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFFEF4444).withOpacity(0.6),
                                        blurRadius: _heartbeatAnimation.value * 3,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.secondary,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'by',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.secondary,
                                AppTheme.tertiary,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'ErrorX',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildControlButton(theme),
    );
  }

  Widget _buildControlButton(ThemeData theme) {
    if (_isTesting) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stop button
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _stopTesting,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stop_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Stop',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_totalTested > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Restart button
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.8),
                      AppTheme.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _restartTesting,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restart_alt_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Restart',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.success.withOpacity(0.8),
                  AppTheme.tertiary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _startTesting,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
