import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/promotions_model.dart';
import 'package:Annujoom/src/data/providers/promotions_provider.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/cards/index.dart';

class CompletedCampaignsPage extends ConsumerWidget {
  const CompletedCampaignsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsAsync = ref.watch(
      promotionsListProvider(),
    );
      final preferredLanguage =
                        GlobalVariables.getPreferredLanguage();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Completed Campaigns',
          style: kHeadTitleSB.copyWith(fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: promotionsAsync.when(
        data: (data) {
          final promotions = _parsePromotions(data);
          if (promotions.isEmpty) {
            return Center(
              child: Text(
                'No completed campaigns',
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promotion = promotions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: HomeCompletedCampaignCard(
                  heading: promotion.getTitle(preferredLanguage) ?? '',
                  subtitle: promotion.getDescription(preferredLanguage) ?? '',
                  goal: 0,
                  collected: 0,
                  posterImage: promotion.media ?? '',
                  isImagePoster: true,
                  onTap: () {},
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: LoadingAnimation(),
        ),
        error: (error, stackTrace) => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading campaigns',
                  style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(promotionsListProvider().notifier).refresh();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Promotions> _parsePromotions(Map<String, dynamic> data) {
    try {
      final promotionsList = data['data'] as List?;
      if (promotionsList == null) return [];
      return promotionsList
          .map((item) => Promotions.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
