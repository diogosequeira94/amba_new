import 'package:amba_new/features/settings/services/pin_service.dart';
import 'package:flutter/material.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  static const int _pinLength = 4;

  final _svc = PinService();

  // steps
  // 0 = pin atual, 1 = novo pin, 2 = confirmar
  int _step = 0;

  final List<int> _digits = [];
  String? _currentPin;
  String? _newPin;

  bool _busy = false;
  String? _error;

  String get _title {
    switch (_step) {
      case 0:
        return 'PIN atual';
      case 1:
        return 'Novo PIN';
      case 2:
        return 'Confirmar PIN';
      default:
        return 'Alterar PIN';
    }
  }

  String get _subtitle {
    switch (_step) {
      case 0:
        return 'Introduz o PIN atual para continuar.';
      case 1:
        return 'Escolhe um novo PIN de 4 dígitos.';
      case 2:
        return 'Repete o novo PIN para confirmar.';
      default:
        return '';
    }
  }

  void _addDigit(int d) {
    if (_busy) return;
    if (_digits.length >= _pinLength) return;

    setState(() {
      _error = null;
      _digits.add(d);
    });

    if (_digits.length == _pinLength) {
      _onComplete();
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

  void _clearDigits() {
    setState(() {
      _digits.clear();
    });
  }

  Future<void> _onComplete() async {
    final pin = _digits.join();

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (_step == 0) {
        final ok = await _svc.verify(pin);
        if (!mounted) return;

        if (!ok) {
          setState(() {
            _busy = false;
            _error = 'PIN atual incorreto';
          });
          _clearDigits();
          return;
        }

        _currentPin = pin;
        setState(() {
          _busy = false;
          _step = 1;
        });
        _clearDigits();
        return;
      }

      if (_step == 1) {
        _newPin = pin;
        setState(() {
          _busy = false;
          _step = 2;
        });
        _clearDigits();
        return;
      }

      if (_step == 2) {
        if (_newPin != pin) {
          setState(() {
            _busy = false;
            _error = 'Os PINs não coincidem';
            _step = 1; // volta a escolher novo PIN
          });
          _clearDigits();
          return;
        }

        // grava
        await _svc.setPin(pin);

        if (!mounted) return;
        Navigator.of(context).pop(true);
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Erro ao atualizar PIN';
      });
      _clearDigits();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Alterar PIN')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),

            const Spacer(),

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

            _PinKeyboard(
              enabled: !_busy,
              onDigit: _addDigit,
              onBackspace: _backspace,
            ),

            const SizedBox(height: 10),
          ],
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
            const Expanded(
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
          child: Center(child: Icon(icon, size: 22)),
        ),
      ),
    );
  }
}
