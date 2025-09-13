import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/bet_slip_provider.dart';
import 'package:tipsterino/routes/app_route.dart';
import '../models/tip_model.dart';
import '../services/bet_slip_service.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final TextEditingController _stakeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _stakeController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final tips = ref.read(betSlipProvider).tips;
    double? stake = double.tryParse(_stakeController.text);

    if (tips.isEmpty) {
      setState(() {
        _errorMessage = loc.no_tips_selected;
        _isLoading = false;
      });
      return;
    }
    if (stake == null || stake <= 0) {
      setState(() {
        _errorMessage = loc.errorInvalidStake;
        _isLoading = false;
      });
      return;
    }

    try {
      final user = ref.watch(authProvider).user;
      if (user == null) {
        setState(() {
          _errorMessage = loc.errorNotLoggedIn;
          _isLoading = false;
        });
        return;
      }
      await BetSlipService.submitTicket(tips: tips, stake: stake.toInt());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      // Ürítsük a szelvényt sikeres beküldés után
      ref.read(betSlipProvider.notifier).clearSlip();
      // Diszkrét visszajelzés a meglévő kulccsal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.ticket_submit_success)),
      );
      // routing_integrity: név alapú visszanavigálás a Fogadások képernyőre
      context.goNamed(AppRoute.bets.name);
    } catch (e) {
      setState(() {
        _errorMessage = '${loc.ticket_submit_error} $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tips = ref.watch(betSlipProvider).tips;

    final double totalOdd = BetSlipService.calculateTotalOdd(tips);
    double? stake = double.tryParse(_stakeController.text);
    final double potentialWin = (stake != null && stake > 0)
        ? BetSlipService.calculatePotentialWin(totalOdd, stake)
        : 0.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(loc.createTicketTitle)),
      body: LayoutBuilder(builder: (context, _) {
        final inset = MediaQuery.of(context).viewInsets.bottom;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
          child: Column(
            children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: tips.isEmpty
                  ? Center(child: Text(loc.no_tips_selected))
                  : ListView.builder(
                      itemCount: tips.length,
                      itemBuilder: (context, index) {
                        final TipModel tip = tips[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(tip.eventName),
                            subtitle: Text('${loc.odds_label}: ${tip.odds}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ref
                                    .read(betSlipProvider.notifier)
                                    .removeTip(tip);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _stakeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: '${loc.stakeHint} (Ft)',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${loc.total_odds_label}: $totalOdd',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    '${loc.potential_win_label}: ${potentialWin.toStringAsFixed(2)} Ft',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        await _submitTicket();
                      },
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(loc.placeBet),
              ),
            ),
          ],
        ),
      );
    }),
    );
  }
}
