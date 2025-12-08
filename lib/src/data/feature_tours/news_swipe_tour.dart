import 'package:flutter/material.dart';
import 'package:Annujoom/src/data/feature_tours/feature_tour_model.dart';

class NewsSwipeTour {
  static const String tourId = 'news_swipe_tour';

  static FeatureTour create({
    required GlobalKey pageViewKey,
  }) {
    return FeatureTour(
      id: tourId,
      showOnce: true,
      steps: [
        FeatureTourStep(
          id: 'swipe_intro',
          title: 'Swipe to Explore News',
          description:
              'Swipe left or right with your finger to browse through different news articles. Each swipe reveals a new story.',
          targetKey: pageViewKey,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          gestureType: GestureType.swipe,
        ),
      ],
    );
  }
}
