import 'dart:async';

import 'package:flutter/material.dart';

/// Renders the time remaining until [endsAt], recomputed from [endsAt]
/// itself on every tick — never a locally-decremented counter. A device
/// clock skew changes this widget's own displayed precision by exactly that
/// skew; it never changes when the auction room actually resolves the lot,
/// because that decision is made server-side (see the backend's
/// `resolveExpiredLots`), not by any client's countdown reaching zero.
/// Passing a new [endsAt] (e.g. after a bid resets it, or after a resume
/// recomputes it) takes effect on the very next tick with no special
/// handling needed, since every tick re-reads the widget's current
/// [endsAt] field rather than a captured value.
class AuctionCountdown extends StatefulWidget {
  final DateTime? endsAt;

  const AuctionCountdown({super.key, required this.endsAt});

  @override
  State<AuctionCountdown> createState() => _AuctionCountdownState();
}

class _AuctionCountdownState extends State<AuctionCountdown> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final endsAt = widget.endsAt;
    if (endsAt == null) {
      return const SizedBox.shrink();
    }

    final remaining = endsAt.difference(DateTime.now());
    final seconds = remaining.isNegative ? 0 : (remaining.inMilliseconds / 1000).ceil();

    return Text(
      '${seconds}s',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: seconds <= 5 ? Theme.of(context).colorScheme.error : null,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
