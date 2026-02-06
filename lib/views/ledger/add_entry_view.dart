import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopkeeper_app/controllers/ledger_controller.dart';
import 'package:shopkeeper_app/providers/toast_provider.dart';
import 'package:shopkeeper_app/core/constants/app_strings.dart';
import 'package:shopkeeper_app/core/ui/gradient_button.dart';

class AddEntryView extends ConsumerStatefulWidget {
  final String customerId;

  const AddEntryView({super.key, required this.customerId});

  @override
  ConsumerState<AddEntryView> createState() => _AddEntryViewState();
}

class _AddEntryViewState extends ConsumerState<AddEntryView> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final text = _amountController.text.trim();

    if (text.isEmpty) {
      ref.read(toastProvider.notifier).showError(AppStrings.emptyAmount);
      return;
    }

    // Sanitize: allow only numbers and decimal
    final sanitizedText = text.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(sanitizedText);

    if (amount == null) {
      ref.read(toastProvider.notifier).showError(AppStrings.invalidAmount);
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(ledgerControllerProvider(widget.customerId).notifier)
        .addEntry(amount);

    if (mounted) {
      final state = ref.read(ledgerControllerProvider(widget.customerId));
      if (!state.hasError) {
        _amountController.clear();
        Navigator.of(context).pop();
      } else {
        ref.read(toastProvider.notifier).showError("Failed to save entry");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ledgerControllerProvider(widget.customerId));
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addEntryTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: AppStrings.amount,
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const Spacer(),
              GradientButton(
                label: AppStrings.saveEntry,
                isLoading: isLoading,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
