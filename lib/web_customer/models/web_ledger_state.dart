import 'package:shopkeeper_app/models/entry_model.dart';

class WebLedgerState {
  final String? customerName;
  final String? shopName;
  final List<Entry> entries;
  final double totalDue;

  WebLedgerState({
    this.customerName,
    this.shopName,
    this.entries = const [],
    this.totalDue = 0,
  });

  WebLedgerState copyWith({
    String? customerName,
    String? shopName,
    List<Entry>? entries,
    double? totalDue,
  }) {
    return WebLedgerState(
      customerName: customerName ?? this.customerName,
      shopName: shopName ?? this.shopName,
      entries: entries ?? this.entries,
      totalDue: totalDue ?? this.totalDue,
    );
  }
}
