import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_service.dart';

class NetworkStatusBanner extends StatefulWidget {
  const NetworkStatusBanner({super.key, required this.child});
  final Widget child;

  @override
  State<NetworkStatusBanner> createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения статуса сети
    context.read<NetworkService>().addListener(_onNetworkChange);
  }

  @override
  void dispose() {
    context.read<NetworkService>().removeListener(_onNetworkChange);
    super.dispose();
  }

  void _onNetworkChange() {
    final status = context.read<NetworkService>().status;
    // При восстановлении сети сбрасываем флаг закрытия
    if (status == NetworkStatus.connected) {
      if (mounted) setState(() => _dismissed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, network, _) {
        final status = network.status;
        final isVisible = !_dismissed && status != NetworkStatus.connected;
        if (!isVisible) return widget.child;

        return Stack(
          children: [
            widget.child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Material(
                  elevation: 2,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  color: status == NetworkStatus.disconnected
                      ? Colors.red.shade800
                      : Colors.orange.shade800,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          status == NetworkStatus.disconnected
                              ? Icons.wifi_off
                              : Icons.signal_wifi_bad,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            status == NetworkStatus.disconnected
                                ? 'Нет интернета'
                                : 'Медленное соединение',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _dismissed = true),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}