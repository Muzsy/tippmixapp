import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../../services/coin_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tile showing the daily bonus status and allowing the user to claim it.
class HomeTileDailyBonus extends ConsumerStatefulWidget {
  final CoinService? coinService;
  const HomeTileDailyBonus({super.key, this.coinService});

  @override
  ConsumerState<HomeTileDailyBonus> createState() => _HomeTileDailyBonusState();
}

class _HomeTileDailyBonusState extends ConsumerState<HomeTileDailyBonus> {
  bool? _claimed;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final service =
          widget.coinService ??
          CoinService(firestore: FirebaseFirestore.instance);
      final claimed = await service.hasClaimedToday();
      if (mounted) {
        setState(() {
          _claimed = claimed;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _claimed = false);
      }
    }
  }

  Future<void> _claim() async {
    setState(() => _loading = true);
    final service =
        widget.coinService ??
        CoinService(firestore: FirebaseFirestore.instance);
    await service.claimDailyBonus();
    if (mounted) {
      setState(() {
        _claimed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_claimed == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: InkWell(
        onTap: _claimed! || _loading ? null : _claim,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.card_giftcard, size: 48),
              const SizedBox(height: 8),
              Text(
                loc.home_tile_daily_bonus_title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_claimed!)
                Text(loc.home_tile_daily_bonus_claimed)
              else if (_loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _claim,
                  child: Text(loc.home_tile_daily_bonus_collect),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
