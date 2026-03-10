import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// A compact inline message-compose text field with a send button.
class ChatInputField extends StatefulWidget {
  const ChatInputField({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                onChanged: (v) =>
                    setState(() => _hasText = v.trim().isNotEmpty),
                onFieldSubmitted: (_) => _submit(),
                textInputAction: TextInputAction.send,
                style: theme.textTheme.bodyLarge,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Message…',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _hasText ? _submit : null,
                icon: const Icon(Icons.send_rounded),
                color: theme.colorScheme.primary,
                style: IconButton.styleFrom(
                  backgroundColor: _hasText
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
