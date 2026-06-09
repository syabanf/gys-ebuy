import 'package:intl/intl.dart';

NumberFormat? _idrFormat;
DateFormat? _dateFormat;
DateFormat? _dateTimeFormat;

String formatIDR(num amount) {
  _idrFormat ??= NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return _idrFormat!.format(amount);
}

String formatDate(DateTime date) {
  _dateFormat ??= DateFormat('d MMM y', 'id_ID');
  return _dateFormat!.format(date);
}

String formatDateTime(DateTime date) {
  _dateTimeFormat ??= DateFormat('d MMM y · HH:mm', 'id_ID');
  return _dateTimeFormat!.format(date);
}

class OrderStatusInfo {
  static const Map<String, String> labels = {
    'draft': 'Draft',
    'pending_payment': 'Menunggu Pembayaran',
    'paid': 'Sudah Dibayar',
    'accepted_by_distributor': 'Diterima Distributor',
    'in_fulfillment': 'Dalam Proses',
    'shipped': 'Dikirim',
    'delivered': 'Terkirim',
    'completed': 'Selesai',
    'cancelled': 'Dibatalkan',
  };

  static String label(String status) => labels[status] ?? status;
}
