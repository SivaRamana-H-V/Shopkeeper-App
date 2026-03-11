import 'package:flutter/material.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';

/// A single chat message bubble.
///
/// [isSent] = true → right-aligned purple bubble (current user).
/// [isSent] = false → left-aligned dark bubble (counterparty).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isSent,
    required this.timestamp,
    this.senderName,
    this.showSenderName = false,
  });

  final String text;
  final bool isSent;
  final DateTime timestamp;
  final String? senderName;
  final bool showSenderName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: isSent ? 48 : 12,
            right: isSent ? 12 : 48,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSent ? AppTheme.bubbleSent : AppTheme.bubbleReceived,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isSent ? 18 : 4),
              bottomRight: Radius.circular(isSent ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (showSenderName && !isSent && senderName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    senderName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.amberGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    var hour = dt.hour;
    final isPm = hour >= 12;
    final amPm = isPm ? 'PM' : 'AM';

    // Convert to 12h
    hour = hour % 12;
    if (hour == 0) hour = 12;

    final h = hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $amPm';
  }
}
