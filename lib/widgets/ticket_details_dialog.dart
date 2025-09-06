import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../models/ticket_model.dart';
// duplicate import removed
import '../services/analytics_service.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'ticket_status_chip.dart';
import 'tip_status_chip.dart';
import '../models/tip_model.dart';

class TicketDetailsDialog extends StatelessWidget {
  final Ticket ticket;
  final List<TipModel> tips;

  const TicketDetailsDialog({
    super.key,
    required this.ticket,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateFmt = DateFormat.yMd().add_Hm();
    String shortId(String id) {
      if (id.length <= 8) return id;
      return '${id.substring(0, 4)}…${id.substring(id.length - 4)}';
    }
    final earliestTipStart = tips.isEmpty
        ? null
        : tips.map((t) => t.startTime).reduce((a, b) => a.isBefore(b) ? a : b);
    List<TipModel> sorted(List<TipModel> list) {
      final copy = [...list];
      copy.sort((a, b) => a.startTime.compareTo(b.startTime));
      return copy;
    }

    final analyticsService = AnalyticsService();
    final won = sorted(tips.where((t) => t.status == TipStatus.won).toList());
    final lost = sorted(tips.where((t) => t.status == TipStatus.lost).toList());
    final pending = sorted(tips.where((t) => t.status == TipStatus.pending).toList());

    Widget rowWidget(TipModel tip) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(tip.eventName),
              subtitle: Text('${tip.outcome} • ${tip.marketKey}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TipStatusChip(status: tip.status),
                  const SizedBox(width: 8),
                  Text('x${tip.odds.toStringAsFixed(2)}'),
                ],
              ),
              onTap: () {
                // ignore: unawaited_futures
                analyticsService.logTicketDetailsItemViewed(
                  eventId: tip.eventId,
                  outcome: tip.outcome,
                );
              },
            ),
            const Divider(height: 1),
          ],
        );

    Widget section(String title, List<TipModel> items) {
      if (items.isEmpty) return const SizedBox.shrink();
      final header = Text('$title (${items.length})');
      if (items.length < 2) {
        return Semantics(
          header: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 4),
              rowWidget(items.first),
            ],
          ),
        );
      }
      return Semantics(
        header: true,
        child: ExpansionTile(
          title: header,
          onExpansionChanged: (expanded) {
            if (expanded) {
              // ignore: unawaited_futures
              analyticsService.logTicketDetailsGroupExpanded(
                group: title.toLowerCase(),
                count: items.length,
              );
            }
            // ignore: unawaited_futures
            analyticsService.logTicketDetailsGroupToggled(
              group: title.toLowerCase(),
              expanded: expanded,
              count: items.length,
            );
          },
          children: [
            ...items.map(rowWidget),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(loc.ticket_details_title)),
          PopupMenuButton<String>(
            tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            onSelected: (value) async {
              if (value == 'copy_id') {
                await Clipboard.setData(ClipboardData(text: ticket.id));
                // Reuse existing localized success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.copy_success)),
                  );
                }
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem<String>(
                value: 'copy_id',
                child: Row(
                  children: [
                    const Icon(Icons.copy, size: 18),
                    const SizedBox(width: 8),
                    Text(loc.copy_id),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                '${loc.ticket_id} #${shortId(ticket.id)}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ]),
            const SizedBox(height: 8),
            // Meta summary row (responsive wrap)
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _MetaItem(
                  label: loc.ticket_id,
                  value: shortId(ticket.id),
                ),
                _MetaItem(
                  label: loc.ticket_stake,
                  value: ticket.stake.toStringAsFixed(0),
                ),
                _MetaItem(
                  label: loc.ticket_total_odd,
                  value: ticket.totalOdd.toStringAsFixed(2),
                ),
                _MetaItem(
                  label: loc.ticket_potential_win,
                  value: ticket.potentialWin.toStringAsFixed(2),
                ),
                _MetaItem(
                  label: loc.ticket_meta_created,
                  value: dateFmt.format(ticket.createdAt),
                ),
              ],
            ),
            if (ticket.status == TicketStatus.pending && earliestTipStart != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                Text('${loc.filtersDate}: '),
                Text(dateFmt.format(earliestTipStart)),
              ]),
            ],
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${loc.tips_label}: '),
                Text('${tips.length}'),
                const SizedBox(width: 8),
                TicketStatusChip(status: ticket.status),
              ],
            ),
            if (tips.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              section(loc.ticket_details_section_won, won),
              section(loc.ticket_details_section_lost, lost),
              section(loc.ticket_details_section_pending, pending),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.ok),
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
