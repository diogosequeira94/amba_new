import 'package:amba_new/services/pin_service.dart';
import 'package:flutter/material.dart';

class PinLockPage extends StatefulWidget {
  const PinLockPage({super.key});

  @override
  State<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends State<PinLockPage> {
  static const int _pinLength = 4;

  final _svc = PinService();

  final List<int> _digits = [];
  int _attempts = 0;
  bool _busy = false;
  String? _error;

  void _addDigit(int d) {
    if (_busy) return;
    if (_digits.length >= _pinLength) return;

    setState(() {
      _error = null;
      _digits.add(d);
    });

    if (_digits.length == _pinLength) {
      _verify();
    }
  }

  void _backspace() {
    if (_busy) return;
    if (_digits.isEmpty) return;

    setState(() {
      _error = null;
      _digits.removeLast();
    });
  }

  void _reset({String? error}) {
    setState(() {
      _busy = false;
      _digits.clear();
      _error = error;
    });
  }

  Future<void> _verify() async {
    if (_busy) return;

    final pin = _digits.join();

    setState(() {
      _busy = true;
      _error = null;
    });

    final ok = await _svc.verify(pin);

    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    _attempts++;

    // Feedback + reset
    _reset(error: 'PIN incorreto (${_attempts}/5)');

    if (_attempts >= 5) {
      // bloqueio simples (opcional)
      await Future.delayed(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _attempts = 0;
        _error = 'Tenta novamente';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acesso à app',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Introduz o teu PIN para continuar.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 4 círculos
              _PinDots(
                filled: _digits.length,
                total: _pinLength,
                isError: _error != null,
                isBusy: _busy,
              ),

              const SizedBox(height: 14),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _error == null
                    ? const SizedBox(height: 22)
                    : Text(
                        _error!,
                        key: ValueKey(_error),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),

              const Spacer(),

              // Teclado numérico
              _PinKeyboard(
                enabled: !_busy,
                onDigit: _addDigit,
                onBackspace: _backspace,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int filled;
  final int total;
  final bool isError;
  final bool isBusy;

  const _PinDots({
    required this.filled,
    required this.total,
    required this.isError,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i < filled;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.10),
            border: Border.all(
              width: 1.4,
              color: isError
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withOpacity(0.18),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                      color: theme.colorScheme.primary.withOpacity(0.18),
                    ),
                  ]
                : null,
          ),
          child: isBusy && active && i == filled - 1
              ? Center(
                  child: SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
              : null,
        );
      }),
    );
  }
}

class _PinKeyboard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  const _PinKeyboard({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget key(String label, {VoidCallback? onTap}) {
      return _KeyButton(
        label: label,
        enabled: enabled && onTap != null,
        onTap: onTap,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: key('1', onTap: () => onDigit(1))),
            const SizedBox(width: 10),
            Expanded(child: key('2', onTap: () => onDigit(2))),
            const SizedBox(width: 10),
            Expanded(child: key('3', onTap: () => onDigit(3))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: key('4', onTap: () => onDigit(4))),
            const SizedBox(width: 10),
            Expanded(child: key('5', onTap: () => onDigit(5))),
            const SizedBox(width: 10),
            Expanded(child: key('6', onTap: () => onDigit(6))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: key('7', onTap: () => onDigit(7))),
            const SizedBox(width: 10),
            Expanded(child: key('8', onTap: () => onDigit(8))),
            const SizedBox(width: 10),
            Expanded(child: key('9', onTap: () => onDigit(9))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _KeyButton(label: ' ', enabled: false, onTap: null),
            ),
            const SizedBox(width: 10),
            Expanded(child: key('0', onTap: () => onDigit(0))),
            const SizedBox(width: 10),
            Expanded(
              child: _IconKeyButton(
                enabled: enabled,
                icon: Icons.backspace_outlined,
                onTap: onBackspace,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'PIN de 4 dígitos',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.55),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _KeyButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 64,
      child: Material(
        color: enabled
            ? theme.colorScheme.surface
            : theme.colorScheme.surface.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconKeyButton extends StatelessWidget {
  final bool enabled;
  final IconData icon;
  final VoidCallback onTap;

  const _IconKeyButton({
    required this.enabled,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 64,
      child: Material(
        color: enabled
            ? theme.colorScheme.surface
            : theme.colorScheme.surface.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: Center(
            child: Icon(icon, size: 22, color: theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
