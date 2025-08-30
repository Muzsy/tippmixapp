class TelemetrySanitizer {
  static const _ticketIdMaxLen = 64;
  static final RegExp _allowed = RegExp(r'[^A-Za-z0-9_\-]');
  static const Set<String> _allowedStatuses = {
    'pending', 'won', 'lost', 'voided'
  };

  static String normalizeTicketId(String? id) {
    var v = (id ?? '').trim();
    if (v.isEmpty) return 'unknown';
    v = v.replaceAll(_allowed, '-');
    if (v.length > _ticketIdMaxLen) v = v.substring(0, _ticketIdMaxLen);
    return v;
  }

  static String normalizeStatus(String? status) {
    var s = (status ?? '').trim().toLowerCase();
    if (s == 'void') s = 'voided';
    if (!_allowedStatuses.contains(s)) return 'pending';
    return s;
  }

  static int safeCount(num? n, {int min = 0, int max = 100000}) {
    final v = (n ?? 0).toInt();
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  static num safeAmount(num? n, {num min = 0, num max = 1e12, int precision = 2}) {
    num v = (n ?? 0);
    if (v < min) v = min;
    if (v > max) v = max;
    // Round to the requested precision to avoid high-cardinality metrics
    final str = v.toStringAsFixed(precision);
    return num.parse(str);
  }
}

