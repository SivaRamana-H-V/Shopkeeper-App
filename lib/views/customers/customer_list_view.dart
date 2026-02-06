import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper_app/controllers/customer_controller.dart';
import 'package:shopkeeper_app/models/customer_model.dart';
import 'package:shopkeeper_app/providers/toast_provider.dart';
import 'package:shopkeeper_app/core/constants/app_strings.dart';
import 'package:shopkeeper_app/core/router/app_routes.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:shopkeeper_app/core/theme/app_colors.dart';

class CustomerListView extends ConsumerWidget {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.customersTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push(AppRoutes.addCustomer);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(customerControllerProvider);
            },
            child: Consumer(
              builder: (context, ref, child) {
                final customersAsync = ref.watch(customerControllerProvider);

                // Listen for errors
                ref.listen<AsyncValue<List<Customer>>>(
                  customerControllerProvider,
                  (previous, next) {
                    if (next.hasError && !next.isLoading) {
                      ref
                          .read(toastProvider.notifier)
                          .showError(AppStrings.toastFetchFailed);
                    }
                  },
                );

                return customersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => const Center(
                    child: Text(AppStrings.emptyCustomerList),
                  ), // Show empty/error state as requested
                  data: (customers) {
                    final totalOutstanding = customers.fold<double>(
                      0,
                      (sum, item) => sum + (item.totalDue ?? 0),
                    );
                    return Column(
                      children: [
                        // Summary Data Card
                        Card(
                          color: AppColors.primary,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryItem(
                                  context,
                                  AppStrings.totalCustomers,
                                  customers.length.toString(),
                                  Colors.white,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white24,
                                ),
                                _buildSummaryItem(
                                  context,
                                  AppStrings.totalOutstanding,
                                  "₹ ${totalOutstanding.toStringAsFixed(0)}",
                                  Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Search Field
                        TextField(
                          decoration: const InputDecoration(
                            hintText: AppStrings.searchHint,
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // List
                        Expanded(
                          child: customers.isEmpty
                              ? const Center(
                                  child: Text(AppStrings.emptyCustomerList),
                                )
                              : ListView.separated(
                                  itemCount: customers.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final customer = customers[index];
                                    return _CustomerCard(
                                      name: customer.name,
                                      amount:
                                          "₹ ${(customer.totalDue ?? 0).toStringAsFixed(0)}",
                                      onTap: () {
                                        context.push(
                                          AppRoutes.ledgerDetail(customer.id),
                                        );
                                      },
                                      onShare: () => _shareCustomerLink(
                                        context,
                                        ref,
                                        customer,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _normalizePhone(String phone) {
    // Task A: Remove spaces and dashes
    String cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');

    // Ensure country code exists. If no country code, prefix with default '+91'
    if (cleaned.isNotEmpty && !cleaned.startsWith('+')) {
      cleaned = "+91$cleaned";
    }

    // Task B: format for wa.me/{phone} (remove the '+' for the URL)
    return cleaned.replaceFirst('+', '');
  }

  void _shareCustomerLink(
    BuildContext context,
    WidgetRef ref,
    Customer customer,
  ) {
    String baseUrl = "";
    if (kIsWeb) {
      baseUrl = Uri.base.origin;
    } else {
      // For mobile, default web URL
      baseUrl = AppStrings.baseUrl;
    }

    final link = "$baseUrl/#${AppRoutes.customerWebPath(customer.token!)}";
    final normalizedPhone = customer.phone.isNotEmpty
        ? _normalizePhone(customer.phone)
        : null;

    _launchWhatsApp(ref, link, normalizedPhone);
  }

  Future<void> _launchWhatsApp(
    WidgetRef ref,
    String link,
    String? phone,
  ) async {
    // Task B: Build WhatsApp URL
    final message = "Hi, this is your ledger link:\n$link";
    final encodedMessage = Uri.encodeComponent(message);

    Uri whatsappUrl;
    if (phone != null && phone.isNotEmpty) {
      // Targeted chat
      whatsappUrl = Uri.parse("https://wa.me/$phone?text=$encodedMessage");
    } else {
      // Task D: Fallback if no phone
      whatsappUrl = Uri.parse("https://wa.me/?text=$encodedMessage");
    }

    try {
      bool launched = false;
      if (kIsWeb) {
        launched = await launchUrl(
          whatsappUrl,
          mode: LaunchMode.platformDefault,
        );
      } else {
        launched = await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );
      }

      // Task C: Fallback behavior if launch fails
      if (!launched) {
        _fallbackToClipboard(ref, link);
      }
    } catch (e) {
      _fallbackToClipboard(ref, link);
    }
  }

  void _fallbackToClipboard(WidgetRef ref, String link) {
    _copyToClipboard(ref, link);
    ref.read(toastProvider.notifier).showSuccess(AppStrings.linkCopied);
  }

  void _copyToClipboard(WidgetRef ref, String link) {
    Clipboard.setData(ClipboardData(text: link)).then((_) {
      // Base logic for copying
    });
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final String name;
  final String amount;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const _CustomerCard({
    required this.name,
    required this.amount,
    required this.onTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            name[0],
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),

            Text(
              amount,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        subtitle: Text(
          AppStrings.totalDue,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.share, size: 26, color: AppColors.primary),
          onPressed: onShare,
        ),
      ),
    );
  }
}
