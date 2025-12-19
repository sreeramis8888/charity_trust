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
import 'package:Annujoom/src/interfaces/main_pages/completed_campaigns_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/videos_page.dart';
import 'package:Annujoom/src/data/router/nav_router.dart';
import 'package:Annujoom/src/data/utils/launch_url.dart';
import 'package:Annujoom/src/data/services/notification_service/get_fcm.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late PageController _completedCampaignController;
  late PageController _videoController;
  late CarouselSliderController _categoryCarouselController;
  int _completedCampaignIndex = 0;
  int _videoIndex = 0;
  int _endingCampaignIndex = 0;
  bool _imagesPrecached = false;
  final _expandableFabKey = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
    _completedCampaignController =
        PageController(initialPage: _completedCampaignIndex);
    _videoController = PageController(initialPage: _videoIndex);
    _categoryCarouselController = CarouselSliderController();
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
      'assets/png/general_campaign.png',
      'assets/jpg/general_funding.jpg',
      'assets/png/zakat.png',
      'assets/jpg/orphan.jpg',
      'assets/png/widow.png',
      'assets/png/ghusal_mayyt.png',
    ];
    for (var image in categoryImages) {
      precacheImage(AssetImage(image), context);
    }
  }

  void _handleCategoryTap(BuildContext context, String category) {
    print('=== _handleCategoryTap called ===');
    print('Category: $category');

    if (category == 'General Campaign') {
      print('Navigating to Campaign with arguments: {category: $category}');
      Navigator.of(context).pushNamed(
        'Campaign',
        arguments: {'category': category},
      );
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

  void _showCallSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: kWhite,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Call Support Team',
                  style: kBodyTitleSB,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Do you want to call the Annujoom Support Team? You\'re about to make a phone call.',
              style: kBodyTitleL.copyWith(color: kSecondaryTextColor),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: primaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    buttonColor: kWhite,
                    labelColor: kTextColor,
                    sideColor: kStrokeColor,
                    buttonHeight: 48,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: primaryButton(
                    label: 'Call',
                    onPressed: () {
                      Navigator.pop(context);
                      launchPhone('+918891646431');
                    },
                    buttonColor: kPrimaryColor,
                    labelColor: kWhite,
                    buttonHeight: 48,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      floatingActionButtonLocation: ExpandableFab.location,
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

        if (isAdmin) {
          return ExpandableFab(
            type: ExpandableFabType.up,
            distance: 70,
            openButtonBuilder: DefaultFloatingActionButtonBuilder(
              child: const Icon(Icons.menu, size: 20),
              fabSize: ExpandableFabSize.regular,
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFED3C5F),
              shape: const CircleBorder(), // 👈 force round
            ),
            closeButtonBuilder: DefaultFloatingActionButtonBuilder(
              child: const Icon(Icons.close, size: 20),
              fabSize: ExpandableFabSize.regular,
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFED3C5F),
              shape: const CircleBorder(), // 👈 force round
            ),
            children: [
              FloatingActionButton(
                heroTag: null,
                shape: const CircleBorder(), // 👈 force round
                backgroundColor: const Color(0xFFED3C5F),
                onPressed: () {
                  Navigator.of(context).pushNamed('CreateUser');
                },
                child: SvgPicture.asset(
                  'assets/svg/add.svg',
                  height: 20,
                  width: 20,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              FloatingActionButton(
                heroTag: null,
                shape: const CircleBorder(), // 👈 force round
                backgroundColor: const Color(0xFFED3C5F),
                onPressed: () {
                  Navigator.of(context).pushNamed('DonationCategories');
                },
                child: SvgPicture.asset(
                  'assets/svg/donation.svg',
                  height: 20,
                  width: 20,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ],
          );
        }

        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 16),
            child: FloatingActionButton(
              heroTag: 'memberDonateButton',
              onPressed: () {
                Navigator.of(context).pushNamed('DonationCategories');
              },
              backgroundColor: const Color(0xFFED3C5F),
              child: SvgPicture.asset(
                'assets/svg/donation.svg',
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(kWhite, BlendMode.srcIn),
              ),
            ),
          ),
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
                            _showCallSupportModal(context);
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
                          'Assalamualaikkum, $userName!',
                          style: kHeadTitleSB.copyWith(
                              fontSize: 20, color: kThirdTextColor),
                        ),
                        Text(
                          "Connect, Contribute, Make a Difference",
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
                        carouselController: _categoryCarouselController,
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
                          onPageChanged: (index, reason) {
                            // Reset to beginning when reaching the end
                            if (index == 5) {
                              // 5 is the last index (0-5 = 6 items)
                              Future.delayed(const Duration(milliseconds: 800),
                                  () {
                                _categoryCarouselController.jumpToPage(0);
                              });
                            }
                          },
                        ),
                        items: [
                          {
                            'title': 'General\nCampaign',
                            'image': 'assets/png/general_campaign.png',
                            'category': 'General Campaign'
                          },
                          {
                            'title': 'General\nFunding',
                            'image': 'assets/jpg/general_funding.jpg',
                            'category': 'General Funding'
                          },
                          {
                            'title': 'Zakat',
                            'image': 'assets/png/zakat.png',
                            'category': 'Zakat'
                          },
                          {
                            'title': 'Orphan',
                            'image': 'assets/jpg/orphan.jpg',
                            'category': 'Orphan'
                          },
                          {
                            'title': 'Widow',
                            'image': 'assets/png/widow.png',
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
              if (homeData.endingCampaigns.isNotEmpty)
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
                              Navigator.of(context).pushNamed(
                                'Campaign',
                                arguments: {'category': 'All'},
                              );
                            },
                            child: Text('See All >',
                                style: kSmallTitleM.copyWith(
                                    color: kThirdTextColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 450,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 450,
                            viewportFraction: 1,
                            enableInfiniteScroll: true,
                            autoPlay: false,
                            onPageChanged: (index, reason) {
                              setState(() => _endingCampaignIndex = index);
                            },
                          ),
                          items: homeData.endingCampaigns.map((campaign) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: HomeGradientCampaignCard(
                                title: campaign.title,
                                description: campaign.description,
                                image: campaign.coverImage,
                                raised: campaign.collectedAmount.toInt(),
                                goal: campaign.targetAmount.toInt(),
                                dueDate: campaign.targetDate
                                        ?.toString()
                                        .split(' ')[0] ??
                                    '',
                                category: campaign.category,
                                onViewDetails: () {
                                  Navigator.of(context).pushNamed(
                                    'CampaignDetail',
                                    arguments: {
                                      '_id': campaign.id ?? '',
                                      'title': campaign.title,
                                      'description': campaign.description,
                                      'category': campaign.category,
                                      'date': campaign.targetDate
                                              ?.toString()
                                              .split(' ')[0] ??
                                          '',
                                      'image': campaign.coverImage,
                                      'raised':
                                          campaign.collectedAmount.toInt(),
                                      'goal': campaign.targetAmount.toInt(),
                                    },
                                  );
                                },
                                onDonate: () {},
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: PageViewDotIndicator(
                          size: Size(8, 8),
                          unselectedSize: Size(7, 7),
                          currentItem: _endingCampaignIndex,
                          count: homeData.endingCampaigns.length,
                          unselectedColor: Color(0xFFAEB9E1),
                          selectedColor: Color(0xFF0D74BC),
                        ),
                      ),
                    ],
                  ),
                ),
              if (homeData.posterPromotions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Completed Campaigns', style: kBodyTitleM),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CompletedCampaignsPage(),
                            ),
                          );
                        },
                        child: Text('See All >',
                            style:
                                kSmallTitleM.copyWith(color: kThirdTextColor)),
                      ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Latest Videos', style: kBodyTitleM),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const VideosPage(),
                            ),
                          );
                        },
                        child: Text('See All >',
                            style:
                                kSmallTitleM.copyWith(color: kThirdTextColor)),
                      ),
                    ],
                  ),
                ),
              if (homeData.videoPromotions.isNotEmpty)
                const SizedBox(height: 12),
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
