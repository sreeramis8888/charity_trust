import 'package:carousel_slider/carousel_slider.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/components/cards/index.dart';
import 'package:Annujoom/src/data/providers/home_provider.dart';
import 'package:Annujoom/src/data/providers/notifications_provider.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/interfaces/components/cards/video_card.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart';
import 'package:Annujoom/src/interfaces/onboarding/create_user.dart';
import 'package:Annujoom/src/interfaces/main_pages/campaign_pages/category_campaign_detail.dart';
import 'package:Annujoom/src/interfaces/main_pages/news_bookmark/news_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/notifications_page.dart';
import 'package:Annujoom/src/data/router/nav_router.dart';
import 'package:Annujoom/src/data/utils/launch_url.dart';
import 'package:Annujoom/src/data/services/notification_service/get_fcm.dart';
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
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    _completedCampaignController =
        PageController(initialPage: _completedCampaignIndex);
    _videoController = PageController(initialPage: _videoIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _precacheImages();
      _imagesPrecached = true;
    }
  }

  void _precacheImages() {
    final categoryImages = [
      'assets/jpg/general_campaign.jpg',
      'assets/jpg/general_funding.jpg',
      'assets/jpg/zakat.jpg',
      'assets/jpg/orphan.jpg',
      'assets/jpg/widow.jpg',
      'assets/png/ghusal_mayyt.png',
    ];
    for (var image in categoryImages) {
      precacheImage(AssetImage(image), context);
    }
  }

  void _handleCategoryTap(BuildContext context, String category) {
    if (category == 'General Campaign') {
      Navigator.of(context).pushNamed('Campaign');
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CategoryCampaignDetailPage(category: category),
        ),
      );
    }
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
      floatingActionButton: _buildFloatingActionButton(context, ref),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: ref.read(secureStorageServiceProvider).getUserData().then(
            (userData) => userData?.role,
          ),
      builder: (context, snapshot) {
        final userRole = snapshot.data ?? '';
        final isAdmin = userRole != 'member';

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isAdmin)
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFED3C5F), Color(0xFFED3C5F)],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                  shape: BoxShape.circle,
                ),
                child: FloatingActionButton(
                  heroTag: 'addUserButton',
                  onPressed: () {
                    Navigator.of(context).pushNamed('CreateUser');
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: SvgPicture.asset(
                    'assets/svg/add.svg',
                    height: 24,
                    width: 24,
                    colorFilter: ColorFilter.mode(kWhite, BlendMode.srcIn),
                  ),
                ),
              ),
            if (isAdmin) const SizedBox(height: 16),
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFED3C5F), Color(0xFFED3C5F)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                shape: BoxShape.circle,
              ),
              child: FloatingActionButton(
                heroTag: 'donateButton',
                onPressed: () {
                  Navigator.of(context).pushNamed('DonationCategories');
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: SvgPicture.asset(
                  'assets/svg/donation.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(kWhite, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        );
      },
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
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () async {
                                // Request FCM token only if not already saved
                                final secureStorage =
                                    ref.read(secureStorageServiceProvider);
                                final existingFcmToken =
                                    await secureStorage.getFcmToken();
                                if (existingFcmToken == null ||
                                    existingFcmToken.isEmpty) {
                                  await getFcmToken(context, ref);
                                }
                                final notificationsAsync =
                                    ref.read(notificationsProvider);
                                if (context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationsPage(),
                                    ),
                                  );
                                }
                              },
                              icon: SvgPicture.asset(
                                'assets/svg/bell.svg',
                                height: 20,
                                width: 20,
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final notificationsAsync =
                                    ref.watch(notificationsProvider);
                                return notificationsAsync.when(
                                  data: (state) {
                                    final unreadCount = state.notifications
                                        .where((n) => !n.isRead)
                                        .length;
                                    return unreadCount > 0
                                        ? Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: kPrimaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                unreadCount > 99
                                                    ? '99+'
                                                    : unreadCount.toString(),
                                                style: kSmallerTitleR.copyWith(
                                                  color: kWhite,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink();
                                  },
                                  loading: () => SizedBox.shrink(),
                                  error: (_, __) => SizedBox.shrink(),
                                );
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            launchPhone('+918891646431');
                          },
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 25),
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
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 120,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 120,
                          viewportFraction: 0.25,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 800),
                          enableInfiniteScroll: false,
                          initialPage: 0,
                          padEnds: false,
                        ),
                        items: [
                          {
                            'title': 'General\nCampaign',
                            'image': 'assets/jpg/general_campaign.jpg',
                            'category': 'General Campaign'
                          },
                          {
                            'title': 'General\nFunding',
                            'image': 'assets/jpg/general_funding.jpg',
                            'category': 'General Funding'
                          },
                          {
                            'title': 'Zakat',
                            'image': 'assets/jpg/zakat.jpg',
                            'category': 'Zakat'
                          },
                          {
                            'title': 'Orphan',
                            'image': 'assets/jpg/orphan.jpg',
                            'category': 'Orphan'
                          },
                          {
                            'title': 'Widow',
                            'image': 'assets/jpg/widow.jpg',
                            'category': 'Widow'
                          },
                          {
                            'title': 'Ghusl\nMayyit',
                            'image': 'assets/png/ghusal_mayyt.png',
                            'category': 'Ghusl Mayyit'
                          },
                        ].map((category) {
                          return AnimatedWidgetWrapper(
                            animationType: AnimationType.fadeScaleUp,
                            duration: AnimationDuration.normal,
                            curveType: AnimationCurveType.easeOut,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: GestureDetector(
                                onTap: () {
                                  _handleCategoryTap(
                                      context, category['category'] as String);
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          category['image'] as String,
                                          fit: BoxFit.cover,
                                          cacheWidth: 140,
                                          cacheHeight: 140,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                  Icons.image_not_supported),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        category['title'] as String,
                                        textAlign: TextAlign.center,
                                        style: kSmallTitleR.copyWith(
                                          fontSize: 10,
                                          color: kTextColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<String?>(
                future:
                    ref.read(secureStorageServiceProvider).getUserData().then(
                          (userData) => userData?.role,
                        ),
                builder: (context, snapshot) {
                  final userRole = snapshot.data ?? '';
                  final isAdmin = userRole != 'member';

                  if (!isAdmin) {
                    return SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('MyReferrals');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0xFFFFFFFF), Color(0xFFCEE8F8)],
                              begin: AlignmentGeometry.topCenter,
                              end: AlignmentGeometry.bottomCenter),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            child: Row(
                              children: [
                                // LEFT SIDE
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        homeData.referralsReceived.toString(),
                                        style: kHeadTitleSB.copyWith(
                                            fontSize: 22,
                                            color: kThirdTextColor),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Referrals Received',
                                          style: kSmallerTitleR),
                                    ],
                                  ),
                                ),

                                // CENTER DIVIDER (PERFECT CENTER)
                                Container(
                                  width: 1,
                                  height: 60,
                                  color: Color(0xFFCFDBFF),
                                ),

                                // RIGHT SIDE
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              homeData.pendingReferrals
                                                  .toString(),
                                              style: kHeadTitleSB.copyWith(
                                                  fontSize: 22,
                                                  color: kThirdTextColor),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.of(context)
                                                    .pushNamed('MyReferrals');
                                              },
                                              child: Text(
                                                'Review Now',
                                                style: kSmallerTitleM.copyWith(
                                                  color: kThirdTextColor,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Pending Approvals',
                                            style: kSmallerTitleR),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  );
                },
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
                          category: homeData.endingCampaign!.category ?? '',
                          onViewDetails: () {
                            Navigator.of(context).pushNamed(
                              'CampaignDetail',
                              arguments: {
                                '_id': homeData.endingCampaign!.id ?? '',
                                'title': homeData.endingCampaign!.title ?? '',
                                'description':
                                    homeData.endingCampaign!.description ?? '',
                                'category':
                                    homeData.endingCampaign!.category ?? '',
                                'date': homeData.endingCampaign!.targetDate
                                        ?.toString()
                                        .split(' ')[0] ??
                                    '',
                                'image':
                                    homeData.endingCampaign!.coverImage ?? '',
                                'raised': homeData
                                        .endingCampaign!.collectedAmount
                                        ?.toInt() ??
                                    0,
                                'goal': homeData.endingCampaign!.targetAmount
                                        ?.toInt() ??
                                    0,
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
                              ref
                                  .read(selectedIndexProvider.notifier)
                                  .updateIndex(2);
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
                  items: homeData.latestNews.asMap().entries.map((entry) {
                    int index = entry.key;
                    var news = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: HomeNewsCard(
                        title: news.title ?? '',
                        subtitle: news.subTitle ?? '',
                        image: news.media ?? '',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NewsDetailView(
                                news: homeData.latestNews,
                              ),
                            ),
                          );
                          Future.microtask(() {
                            ref.read(currentNewsIndexProvider.notifier).state =
                                index;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              if (homeData.videoPromotions.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: PageView(
                    controller: _videoController,
                    onPageChanged: (page) {
                      setState(() => _videoIndex = page);
                    },
                    children: homeData.videoPromotions.map((video) {
                      final videoId = extractYouTubeVideoId(video.link ?? '');
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: videoId != null
                            ? YoutubeVideoCard(
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
}
