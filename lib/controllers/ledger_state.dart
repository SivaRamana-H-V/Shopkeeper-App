import 'package:shopkeeper_app/models/entry_model.dart';

class LedgerState {
  final List<Entry> entries;
  final String? customerCode;
  final double totalDue;
  final String? customerName;

  LedgerState({
    required this.entries,
    this.customerCode,
    this.totalDue = 0.0,
    this.customerName,
  });

  LedgerState copyWith({
    List<Entry>? entries,
    String? customerCode,
    double? totalDue,
    String? customerName,
  }) {
    return LedgerState(
      entries: entries ?? this.entries,
      customerCode: customerCode ?? this.customerCode,
      totalDue: totalDue ?? this.totalDue,
      customerName: customerName ?? this.customerName,
    );
  }
}
