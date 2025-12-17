import 'package:flutter/material.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/user_model.dart';
import 'package:Annujoom/src/interfaces/components/text_pill.dart';

class ReferralCard extends StatelessWidget {
  final UserModel user;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback? onViewDetails;

  const ReferralCard({
    super.key,
    required this.user,
    required this.isPending,
    required this.onTap,
    this.onViewDetails,
  });

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        return const Color(0xFF2E7D32);
      case 'rejected':
        return const Color(0xFFBB0D06);
      case 'pending':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Container(
            //   width: 50,
            //   height: 50,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: Colors.grey[300],
            //     image: user.image != null
            //         ? DecorationImage(
            //             image: NetworkImage(user.image!),
            //             fit: BoxFit.cover,
            //           )
            //         : null,
            //   ),
            //   child: user.image == null
            //       ? Icon(Icons.person, size: 24, color: Colors.grey[600])
            //       : null,
            // ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name ?? 'Unknown', style: kBodyTitleM),
                  const SizedBox(height: 4),
                  Text(user.area ?? 'Unkown Area',
                      style: kSmallTitleL.copyWith(color: kSecondaryTextColor)),
                  const SizedBox(height: 2),
                  Text(user.phone ?? 'N/A',
                      style: kSmallTitleL.copyWith(color: kSecondaryTextColor)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (onViewDetails != null)
                  GestureDetector(
                    onTap: onViewDetails,
                    child: Text(
                      'View details',
                      style: kSmallTitleM.copyWith(
                        color: kThirdTextColor,
                      ),
                    ),
                  ),
                if (onViewDetails != null) const SizedBox(height: 8),
                TextPill(
                  text: (user.status ?? 'pending').toUpperCase(),
                  color: _getStatusBgColor(user.status ?? 'pending'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
