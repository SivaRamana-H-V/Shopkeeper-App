import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopkeeper_app/core/constants/app_strings.dart';
import 'package:shopkeeper_app/core/theme/app_colors.dart';
import 'package:shopkeeper_app/models/entry_model.dart';
import 'package:shopkeeper_app/web_customer/controllers/web_ledger_controller.dart';

class CustomerLedgerWebView extends ConsumerWidget {
  final String token;

  const CustomerLedgerWebView({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webStateAsync = ref.watch(webLedgerControllerProvider(token));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: webStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Header Area
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, Color(0xFF1E40AF)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            state.shopName ?? "Loading Shop...",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Welcome, ${state.customerName ?? "Customer"}",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Glassmorphism effect for Total Outstanding
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${AppStrings.totalOutstanding}: ",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "₹ ${state.totalDue.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Transaction List
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: state.entries.isEmpty
                        ? const SliverFillRemaining(
                            child: Center(child: Text(AppStrings.noEntries)),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final entry = state.entries[index];
                              return _WebEntryRow(
                                entry: entry,
                                onApprove: () => ref
                                    .read(
                                      webLedgerControllerProvider(
                                        token,
                                      ).notifier,
                                    )
                                    .approveEntry(entry.id),
                                onDispute: () => ref
                                    .read(
                                      webLedgerControllerProvider(
                                        token,
                                      ).notifier,
                                    )
                                    .disputeEntry(entry.id),
                              );
                            }, childCount: state.entries.length),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WebEntryRow extends StatefulWidget {
  final Entry entry;
  final VoidCallback onApprove;
  final VoidCallback onDispute;

  const _WebEntryRow({
    required this.entry,
    required this.onApprove,
    required this.onDispute,
  });

  @override
  State<_WebEntryRow> createState() => _WebEntryRowState();
}

class _WebEntryRowState extends State<_WebEntryRow> {
  bool _isHovered = false;

  Color _getStatusColor(EntryStatus s) {
    switch (s) {
      case EntryStatus.approved:
        return AppColors.success;
      case EntryStatus.disputed:
        return AppColors.error;
      case EntryStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusLabel(EntryStatus s) {
    switch (s) {
      case EntryStatus.approved:
        return AppStrings.statusApproved;
      case EntryStatus.disputed:
        return AppStrings.statusDisputed;
      case EntryStatus.pending:
        return AppStrings.statusPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? Colors.black.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _isHovered
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "₹ ${widget.entry.amount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.entry.createdAt.toString().split(' ')[0],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        widget.entry.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(widget.entry.status),
                      style: TextStyle(
                        color: _getStatusColor(widget.entry.status),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.entry.status == EntryStatus.pending) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onDispute,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(
                            color: AppColors.error,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          AppStrings.dispute,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          AppStrings.approve,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
