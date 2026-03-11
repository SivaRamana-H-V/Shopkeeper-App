import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:math_expressions/math_expressions.dart';

/// Branded text field used throughout Pulse.
///
/// Wraps [TextFormField] with the app's input decoration theme.
class PulseTextField extends StatelessWidget {
  const PulseTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength ?? 50,
      enabled: enabled,
      autofocus: autofocus,
      textInputAction: textInputAction,
      focusNode: focusNode,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    required this.onSend,
    required this.onCreditRequest,
    this.showCreditTools = true,
  });

  final ValueChanged<String> onSend;
  final void Function(double amount, String description) onCreditRequest;
  final bool showCreditTools;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();
  bool _hasText = false;

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
          16, 8, 16, 12), // Tighter padding for better keyboard fit
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // Seamless transition
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.scaffoldBackgroundColor.withValues(alpha: 0),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Row(
        children: [
          // 1. Action Capsule
          if (widget.showCreditTools)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.royalPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () => _showCreditRequestSheet(context),
                icon: const Icon(Icons.add_rounded, size: 28),
                color: AppTheme.royalPurple,
                tooltip: 'Request Credit',
              ),
            ),

          // 2. Main Input Capsule
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: TextFormField(
                  controller: _controller,
                  onChanged: (v) =>
                      setState(() => _hasText = v.trim().isNotEmpty),
                  onFieldSubmitted: (_) => _submit(),
                  maxLines: 4,
                  minLines: 1,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(color: AppTheme.bubbleSent),
                    ),
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                        color: theme.hintColor.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 3. Dynamic Send Button
          AnimatedScale(
            scale: _hasText ? 1.0 : 0.9,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hasText
                    ? AppTheme.royalPurple
                    : theme.disabledColor.withValues(alpha: 0.1),
                boxShadow: _hasText
                    ? [
                        BoxShadow(
                          color: AppTheme.royalPurple.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: IconButton(
                onPressed: _hasText ? _submit : null,
                icon: Icon(
                  _hasText
                      ? Icons.send_rounded
                      : Icons
                          .mic_none_rounded, // Mic as placeholder looks premium
                  color: _hasText ? Colors.white : theme.disabledColor,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreditRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Required for custom rounded corners
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CreditRequestSheet(
          onSendRequest: (amount, desc) {
            widget.onCreditRequest(amount, desc);
          },
        ),
      ),
    );
  }
}

class CreditRequestSheet extends StatefulWidget {
  const CreditRequestSheet({super.key, required this.onSendRequest});
  final void Function(double amount, String description) onSendRequest;

  @override
  State<CreditRequestSheet> createState() => _CreditRequestSheetState();
}

class _CreditRequestSheetState extends State<CreditRequestSheet> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _showDescError = false;

  void _calculateResult() {
    String input = _amountController.text.trim();
    if (input.isEmpty) return;

    // Handle common user inputs
    input = input.replaceAll('x', '*').replaceAll('X', '*');
    input = input.replaceAll('%', '/100');

    try {
      final parser = ShuntingYardParser();
      final exp = parser.parse(input);
      final evaluator = RealEvaluator();
      final double eval = evaluator.evaluate(exp) as double;

      setState(() {
        _amountController.text =
            eval % 1 == 0 ? eval.toInt().toString() : eval.toStringAsFixed(2);
      });
    } catch (e) {
      debugPrint('Math Parsing Error: $e');
    }
  }

  Widget _buildMathButton(String label, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () => setState(() => _amountController.text += label),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side:
                BorderSide(color: AppTheme.royalPurple.withValues(alpha: 0.2)),
            backgroundColor: color ?? Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color != null ? Colors.white : AppTheme.royalPurple),
          ),
        ),
      ),
    );
  }

  Widget _buildArithmeticBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildMathButton('+'),
          _buildMathButton('-'),
          _buildMathButton('*'),
          _buildMathButton('/'), // Standard division is better for calculators
          _buildMathAction('=', onTap: _calculateResult),
        ],
      ),
    );
  }

  Widget _buildMathAction(String label, {required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.royalPurple,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.royalPurple.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          // 1. Large Math Input Field
          TextField(
            controller: _amountController,
            keyboardType:
                TextInputType.number, // Changed to text to allow symbols
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: AppTheme.royalPurple),
            decoration: const InputDecoration(
              hintText: '0',
              prefixText: '₹ ',
              hintStyle: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalPurple),
              prefixStyle: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalPurple),
              border: InputBorder.none,
            ),
          ),

          // 2. Arithmetic Action Bar (The "Calculator" Row)
          _buildArithmeticBar(),

          const SizedBox(height: 16),
          // 3. Description Field
          TextField(
            controller: _descController,
            onChanged: (v) {
              if (_showDescError && v.trim().isNotEmpty) {
                setState(() => _showDescError = false);
              }
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Description',
              filled: true,
              fillColor: theme.dividerColor.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              errorText: _showDescError ? 'Description is required' : null,
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.error)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.error)),
            ),
          ),

          const SizedBox(height: 24),

          // 4. Send Button
          ElevatedButton(
            onPressed: () {
              // 1. Force calculation (this converts "100+50" to "150" in the controller)
              _calculateResult();

              // 2. Now parse the clean number
              final amount = double.tryParse(_amountController.text);
              final desc = _descController.text.trim();

              if (amount != null && amount > 0 && desc.isNotEmpty) {
                widget.onSendRequest(amount, desc);
                Navigator.pop(context);
              } else {
                if (desc.isEmpty) {
                  setState(() => _showDescError = true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.royalPurple,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Send Credit Request',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
