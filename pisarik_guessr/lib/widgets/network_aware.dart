import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_service.dart';
import '../services/toast_service.dart';

mixin NetworkAwareState<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenNetwork();
    });
  }

  void _listenNetwork() {
    final network = context.read<NetworkService>();
    network.onStatusChange.listen((status) {
      if (!mounted) return;
      if (status == NetworkStatus.disconnected) {
        ToastService.showToast(context, 'Нестабильное соединение');
      }
    });
  }
}