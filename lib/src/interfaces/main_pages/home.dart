import 'package:carousel_slider/carousel_slider.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/components/cards/index.dart';
import 'package:charity_trust/src/data/providers/home_provider.dart';
import 'package:charity_trust/src/data/services/secure_storage_service.dart';
import 'package:charity_trust/src/interfaces/components/cards/video_card.dart';
import 'package:charity_trust/src/interfaces/components/loading_indicator.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late PageController _completedCampaignController;
  late PageController _videoController;
  int _completedCampaignIndex = 0;
  int _videoIndex = 0;

  @override
  void initState() {
    super.initState();
    _completedCampaignController =
        PageController(initialPage: _completedCampaignIndex);
    _videoController = PageController(initialPage: _videoIndex);
  }

  @override
  void dispose() {
    _completedCampaignController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homePageDataProvider);

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: homeDataAsync.when(
        data: (homeData) => _buildHomeContent(context, ref, homeData),
        loading: () => Center(
          child: LoadingAnimation(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading home data'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(homePageProvider.notifier).refresh();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(
      BuildContext context, WidgetRef ref, HomePageData homeData) {
    return FutureBuilder<String?>(
      future: ref.read(secureStorageServiceProvider).getUserData().then(
            (userData) => userData?.name,
          ),
      builder: (context, snapshot) {
        final userName = snapshot.data ?? '';

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 100,
                      child: Image.asset(
                        'assets/png/annujoom_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: SvgPicture.asset(
                            'assets/svg/bell.svg',
                            height: 20,
                            width: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: SvgPicture.asset(
                            'assets/svg/call.svg',
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 8, left: 16, right: 16),
                child: AnimatedWidgetWrapper(
                  animationType: AnimationType.fadeSlideInFromBottom,
                  duration: AnimationDuration.slow,
                  curveType: AnimationCurveType.easeOut,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFFCFDBFF), Color(0xFFEFF3FF)],
                          begin: AlignmentGeometry.centerLeft,
                          stops: [.1, .7],
                          end: AlignmentGeometry.centerRight),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $userName!',
                          style: kHeadTitleSB.copyWith(
                              fontSize: 20, color: kThirdTextColor),
                        ),
                        Text(
                          "Let's empowering lives through kindness",
                          style: kSmallTitleL.copyWith(color: kThirdTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (homeData.endingCampaign != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Funding Campaigns', style: kBodyTitleM),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('Campaign');
                            },
                            child: Text('See All >',
                                style: kSmallTitleM.copyWith(
                                    color: kThirdTextColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: HomeGradientCampaignCard(
                          title: homeData.endingCampaign!.title ?? '',
                          description:
                              homeData.endingCampaign!.description ?? '',
                          image: homeData.endingCampaign!.coverImage ?? '',
                          raised: homeData.endingCampaign!.collectedAmount
                                  ?.toInt() ??
                              0,
                          goal:
                              homeData.endingCampaign!.targetAmount?.toInt() ??
                                  0,
                          dueDate: homeData.endingCampaign!.targetDate
                                  ?.toString()
                                  .split(' ')[0] ??
                              '',
                          onViewDetails: () {
                            Navigator.of(context).pushNamed(
                              'CampaignDetail',
                              arguments: {
                                '_id': homeData.endingCampaign!.id ?? '',
                                'title': homeData.endingCampaign!.title ?? '',
                                'description': homeData.endingCampaign!.description ?? '',
                                'category': homeData.endingCampaign!.category ?? '',
                                'date': homeData.endingCampaign!.targetDate?.toString().split(' ')[0] ?? '',
                                'image': homeData.endingCampaign!.coverImage ?? '',
                                'raised': homeData.endingCampaign!.collectedAmount?.toInt() ?? 0,
                                'goal': homeData.endingCampaign!.targetAmount?.toInt() ?? 0,
                              },
                            );
                          },
                          onDonate: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              if (homeData.posterPromotions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Completed Campaigns', style: kBodyTitleM),
                    ],
                  ),
                ),
              if (homeData.posterPromotions.isNotEmpty)
                const SizedBox(height: 12),
              if (homeData.posterPromotions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFCEAEA), Color(0xFFFFF9E4)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16, top: 16),
                          child: Row(
                            children: [
                              Text('Together, We Made It Happen!',
                                  style: kBodyTitleSB),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 280,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 280,
                              viewportFraction: 1,
                              enableInfiniteScroll: true,
                              autoPlay: false,
                              onPageChanged: (index, reason) {
                                setState(() => _completedCampaignIndex = index);
                              },
                            ),
                            items: homeData.posterPromotions.map((promotion) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: HomeCompletedCampaignCard(
                                  heading: promotion.title ?? '',
                                  subtitle: promotion.description ?? '',
                                  goal: 0,
                                  collected: 0,
                                  posterImage: promotion.media ?? '',
                                  isImagePoster: true,
                                  onTap: () {},
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16.0,
                          ),
                          child: Center(
                            child: PageViewDotIndicator(
                              size: Size(8, 8),
                              unselectedSize: Size(7, 7),
                              currentItem: _completedCampaignIndex,
                              count: homeData.posterPromotions.length,
                              unselectedColor: Color(0xFFAEB9E1),
                              selectedColor: Color(0xFF0D74BC),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (homeData.latestNews.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Latest News',
                              style: kHeadTitleM.copyWith(fontSize: 18)),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('News');
                            },
                            child: Text('See All >',
                                style: kSmallTitleM.copyWith(
                                    color: kThirdTextColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              if (homeData.latestNews.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                      height: 200,
                      viewportFraction: 0.55,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 600),
                      autoPlayCurve: Curves.easeInOut,
                      enlargeCenterPage: false,
                      padEnds: false,
                      initialPage: 0,
                      pauseAutoPlayOnTouch: true),
                  items: homeData.latestNews.map((news) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: HomeNewsCard(
                        title: news.title ?? '',
                        subtitle: news.subTitle ?? '',
                        image: news.media ?? '',
                        onTap: () {},
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              if (homeData.videoPromotions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Featured Videos',
                          style: kHeadTitleM.copyWith(fontSize: 18)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              if (homeData.videoPromotions.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: PageView(
                    controller: _videoController,
                    onPageChanged: (page) {
                      setState(() => _videoIndex = page);
                    },
                    children: homeData.videoPromotions.map((video) {
                      final videoId = _extractYoutubeId(video.link ?? '');
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: videoId != null
                            ? youtubeVideoCard(
                                videoId: videoId,
                                title: video.title ?? '',
                              )
                            : Center(
                                child: Text('Something went Wrong'),
                              ),
                      );
                    }).toList(),
                  ),
                ),
              if (homeData.videoPromotions.isNotEmpty)
                const SizedBox(height: 12),
              if (homeData.videoPromotions.isNotEmpty)
                Center(
                  child: PageViewDotIndicator(
                    unselectedSize: Size(8, 8),
                    size: Size(9, 9),
                    currentItem: _videoIndex,
                    count: homeData.videoPromotions.length,
                    unselectedColor: Color(0xFFAEB9E1),
                    selectedColor: Color(0xFF0D74BC),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  String? _extractYoutubeId(String url) {
    final RegExp regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}
