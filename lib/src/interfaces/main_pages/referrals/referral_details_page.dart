import 'package:easy_localization/easy_localization.dart';
import 'package:Annujoom/src/interfaces/components/confirmation_dialog.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/user_model.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';

class ReferralDetailsPage extends ConsumerStatefulWidget {
  final UserModel user;
  final bool isPending;

  const ReferralDetailsPage({
    super.key,
    required this.user,
    this.isPending = false,
  });

  @override
  ConsumerState<ReferralDetailsPage> createState() =>
      _ReferralDetailsPageState();
}

class _ReferralDetailsPageState extends ConsumerState<ReferralDetailsPage> {
  bool _isProcessing = false;

  void _showApproveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'approveMembership'.tr(),
        message: 'approveMembershipConfirmation'.tr(),
        confirmButtonText: 'approve'.tr(),
        onConfirm: _handleApprove,
        cancelButtonText: 'cancel'.tr(),
      ),
    );
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kWhite,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'rejectMembership'.tr(),
                style: kHeadTitleR,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'rejectMembershipReasonPrompt'.tr(),
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'enterRejectionReasonHint'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kStrokeColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'cancel'.tr(),
                        style: kSmallerTitleL.copyWith(color: kTextColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (reasonController.text.trim().isNotEmpty) {
                          _showRejectConfirmation(reasonController.text.trim());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              content: Text('provideRejectionReasonError'.tr()),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'continue'.tr(),
                        style: kSmallerTitleL.copyWith(color: kWhite),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectConfirmation(String reason) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'confirmRejection'.tr(),
        message: 'rejectMembershipConfirmation'.tr(),
        confirmButtonText: 'reject'.tr(),
        onConfirm: () => _handleReject(reason),
        cancelButtonText: 'cancel'.tr(),
      ),
    );
  }

  Future<void> _handleApprove() async {
    setState(() => _isProcessing = true);
    final success =
        await ref.read(approveUserProvider(widget.user.id ?? '').future);
    setState(() => _isProcessing = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failedToApproveUser'.tr())),
      );
    }
  }

  Future<void> _handleReject(String reason) async {
    setState(() => _isProcessing = true);
    final success = await ref.read(
      rejectUserProvider(widget.user.id ?? '', reason).future,
    );
    setState(() => _isProcessing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('userRejectedSuccessfully'.tr())),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failedToRejectUser'.tr())),
      );
    }
  }

  String _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return '#4CAF50';
      case 'rejected':
        return '#F44336';
      case 'pending':
        return '#FF9800';
      default:
        return '#9E9E9E';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dob = widget.user.dob != null
        ? DateFormat('dd/MM/yyyy').format(widget.user.dob!)
        : 'N/A';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 18),
          ),
        ),
        title: Text(
          'referralDetails'.tr(),
          style: kBodyTitleR,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: kCardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ]),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                              image: widget.user.image != null
                                  ? DecorationImage(
                                      image: NetworkImage(widget.user.image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: widget.user.image == null
                                ? Icon(Icons.person,
                                    size: 50, color: Colors.grey[600])
                                : null,
                          ),
                          const SizedBox(height: 16),
                          if (widget.isPending)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child:  Text(
                                'pendingLabel'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color(int.parse(
                                        '0xFF${_getStatusColor(widget.user.status).substring(1)}') ??
                                    0xFF9E9E9E),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (widget.user.status?.toLowerCase() == 'pending' ? 'pendingLabel'.tr() : (widget.user.status?.toLowerCase() == 'active' ? 'active'.tr() : (widget.user.status?.toLowerCase() == 'rejected' ? 'rejectedLabel'.tr() : (widget.user.status?.toUpperCase() ?? 'unknownStatus'.tr())))),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('fullName'.tr(), widget.user.name ?? 'N/A'),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                        'mobileNumber'.tr(), widget.user.phone ?? 'N/A'),
                    const SizedBox(height: 16),
                    // _buildDetailRow(
                    //     'Email Address', widget.user.email ?? 'N/A'),
                    // const SizedBox(height: 16),
                    _buildDetailRow(
                      'address'.tr(),
                      '${widget.user.area ?? ''}, ${widget.user.district ?? ''}\n${widget.user.state ?? ''}\n${widget.user.country ?? ''}',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('dateOfBirth'.tr(), dob),
                  ],
                ),
              ),
              if (widget.isPending) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: primaryButton(
                        label: 'reject'.tr(),
                        onPressed: _isProcessing ? null : _showRejectDialog,
                        buttonColor: Colors.transparent,
                        labelColor: kTextColor,
                        sideColor: kTextColor,
                        isLoading: _isProcessing,
                        buttonHeight: 48,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: primaryButton(
                        label: 'accept'.tr(),
                        onPressed: _isProcessing ? null : _showApproveConfirmation,
                        buttonColor: const Color(0xFF009B0A),
                        isLoading: _isProcessing,
                        buttonHeight: 48,
                        fontSize: 16,
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: kSmallTitleL),
        ),
        const Text(
          ':',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value,
              style: kBodyTitleL.copyWith(color: Color(0xFF9B9B9B))),
        ),
      ],
    );
  }
}
