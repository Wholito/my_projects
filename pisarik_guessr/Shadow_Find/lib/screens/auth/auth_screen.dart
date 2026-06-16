import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../services/connectivity_service.dart';
import '../../widgets/app_brand_icon.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  late final TabController _tabs;
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();
    final checking = connectivity.isChecking;
    final blocked = connectivity.needsRetry;

    if (checking) {
      _spinController.repeat();
    } else {
      _spinController.stop();
    }

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Opacity(
                opacity: blocked ? 0.35 : 1,
                child: IgnorePointer(
                  ignoring: blocked || checking,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          const AppBrandIcon(size: 52, borderRadius: 14),
                          const SizedBox(width: 14),
                          Text(
                            'Shadow Find',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Угадай, где сделан снимок',
                        style: TextStyle(
                          fontSize: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TabBar(
                        controller: _tabs,
                        tabs: const [
                          Tab(text: 'Войти'),
                          Tab(text: 'Создать аккаунт'),
                        ],
                        labelColor: scheme.primary,
                        unselectedLabelColor: scheme.onSurfaceVariant,
                        indicatorColor: scheme.primary,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          controller: _tabs,
                          children: const [
                            _LoginForm(),
                            _RegisterForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (checking || blocked)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: blocked ? 0.55 : 0.72),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: _NetworkGatePanel(
                        connectivity: connectivity,
                        spinController: _spinController,
                        onRetry: () =>
                            context.read<ConnectivityService>().refresh(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NetworkGatePanel extends StatelessWidget {
  final ConnectivityService connectivity;
  final AnimationController spinController;
  final VoidCallback onRetry;

  const _NetworkGatePanel({
    required this.connectivity,
    required this.spinController,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final checking = connectivity.isChecking;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: spinController,
          child: Icon(
            checking ? Icons.sync : Icons.wifi_off_rounded,
            size: 56,
            color: checking ? scheme.primary : Colors.orange,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          connectivity.statusMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        if (!checking) ...[
          const SizedBox(height: 8),
          Text(
            'Вход и регистрация требуют стабильный интернет',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: scheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final online = context.watch<ConnectivityService>().isOnline;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v != null && v.contains('@') ? null : 'Введи email',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            decoration: const InputDecoration(
              labelText: 'Пароль',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            validator: (v) => v != null && v.length >= 6 ? null : 'Минимум 6 символов',
          ),
          if (auth.error != null) ...[
            const SizedBox(height: 12),
            Text(
              auth.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: auth.loading || !online
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
                      }
                    },
              child: auth.loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Войти'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _assureCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _assureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final online = context.watch<ConnectivityService>().isOnline;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Имя игрока',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => v != null && v.length >= 2 ? null : 'Введи имя',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v != null && v.contains('@') ? null : 'Введи email',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            decoration: const InputDecoration(
              labelText: 'Пароль',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            validator: (v) => v != null && v.length >= 6 ? null : 'Минимум 6 символов',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _assureCtrl,
            decoration: const InputDecoration(
              labelText: 'Повторите пароль',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            validator: (v) =>
                v != null && v == _passCtrl.text ? null : 'Пароли не совпадают',
          ),
          if (auth.error != null) ...[
            const SizedBox(height: 12),
            Text(
              auth.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: auth.loading || !online
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        await auth.signUp(
                          email: _emailCtrl.text.trim(),
                          password: _passCtrl.text,
                          displayName: _nameCtrl.text.trim(),
                        );
                      }
                    },
              child: auth.loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Создать аккаунт'),
            ),
          ),
        ],
      ),
    );
  }
}
