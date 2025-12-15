import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isDismissible;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
    this.isDismissible = true,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    final cardColor = isRead ? Color(0xFFE8EAED) : kWhite;
    final textColor = isRead ? Color(0xFF8A8A8A) : kTextColor;

    Widget card = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        padding: const EdgeInsets.all(16),
        color: cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    notification.subject,
                    style: kBodyTitleSB.copyWith(
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getTimeAgo(notification.createdAt),
                  style: kSmallerTitleR.copyWith(
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notification.content,
              style: kSmallerTitleR.copyWith(
                color: textColor,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

    if (!isDismissible) {
      return card;
    }

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: kRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: kWhite),
      ),
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: card,
    );
  }
}
