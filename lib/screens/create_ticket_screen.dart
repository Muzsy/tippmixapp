import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bet_slip_provider.dart';
import '../models/tip_model.dart';
import '../services/bet_slip_service.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({Key? key}) : super(key: key);

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final tips = ref.read(betSlipProvider).tips;
    double? stake = double.tryParse(_stakeController.text);

    if (tips.isEmpty) {
      setState(() {
        _errorMessage = 'Nincs kiválasztott tipp!';
        _isLoading = false;
      });
      return;
    }
    if (stake == null || stake <= 0) {
      setState(() {
        _errorMessage = 'Adj meg érvényes tétet!';
        _isLoading = false;
      });
      return;
    }

    try {
      await BetSlipService.submitTicket(
        userId: 'demo',
        tips: tips,
        stake: stake.toInt(),
      );
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Szelvény sikeresen elküldve!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hiba történt: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tips = ref.watch(betSlipProvider).tips;

    final double totalOdd = BetSlipService.calculateTotalOdd(tips);
    double? stake = double.tryParse(_stakeController.text);
    final double potentialWin = (stake != null && stake > 0)
        ? BetSlipService.calculatePotentialWin(totalOdd, stake)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szelvény létrehozása'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: tips.isEmpty
                  ? const Center(child: Text('Nincs kiválasztott tipp.'))
                  : ListView.builder(
                      itemCount: tips.length,
                      itemBuilder: (context, index) {
                        final TipModel tip = tips[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(tip.eventName),
                            subtitle: Text('Odds: ${tip.odds}'),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Tét (Ft)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Össz odds: $totalOdd'),
                Text('Várható nyeremény: ${potentialWin.toStringAsFixed(2)} Ft'),
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
                    : const Text('Szelvény leadása'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
