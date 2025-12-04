import 'package:carousel_slider/carousel_slider.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/components/cards/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  // Sample data - Replace with actual data from providers
  final List<Map<String, dynamic>> activeCampaigns = [
    {
      'title': 'Landslide Relief Fund',
      'description':
          'Help us build homes for families displaced by the recent landslides.',
      'image': 'https://picsum.photos/id/237/200/300',
      'raised': 2500,
      'goal': 250000,
      'dueDate': '02 JAN 2023',
    },
  ];

  final List<Map<String, dynamic>> completedCampaigns = [
    {
      'heading': 'Medical Camp for Remote Villages',
      'subtitle': 'Successfully Completed on 02 Jan 2023',
      'goal': '₹50,000',
      'collected': '₹52,300',
      'posterImage': 'https://via.placeholder.com/400x280?text=Medical+Camp',
      'isImagePoster': true,
    },
    {
      'heading': 'Education Initiative for Underprivileged',
      'subtitle': 'Successfully Completed on 15 Dec 2022',
      'goal': '₹1,00,000',
      'collected': '₹1,25,500',
      'posterImage': 'https://via.placeholder.com/400x280?text=Education',
      'isImagePoster': true,
    },
    {
      'heading': 'Clean Water Project',
      'subtitle': 'Successfully Completed on 10 Nov 2022',
      'goal': '₹75,000',
      'collected': '₹80,000',
      'posterImage': 'https://via.placeholder.com/400x280?text=Water+Project',
      'isImagePoster': true,
    },
  ];

  final List<Map<String, dynamic>> newsList = [
    {
      'title': 'Sewing Machines Distributed to Empower Women',
      'subtitle':
          'To support women affected by the landslide, Annujoom distributed sewing machines.',
      'image': 'https://via.placeholder.com/400x200?text=Sewing+Machines',
      'authorName': 'Rachel Kim',
      'authorImage': 'https://via.placeholder.com/50x50?text=Rachel',
      'timeAgo': '1h ago',
    },
    {
      'title': 'Donates Auto-Rickshaw to Landslide-Hit Family',
      'subtitle':
          'Annujoom donated an auto-rickshaw to help families rebuild their lives.',
      'image': 'https://via.placeholder.com/400x200?text=Auto+Rickshaw',
      'authorName': 'John Smith',
      'authorImage': 'https://via.placeholder.com/50x50?text=John',
      'timeAgo': '3h ago',
    },
    {
      'title': 'Times of India Interview',
      'subtitle':
          'Our founder shares insights on community-driven charitable initiatives.',
      'image': 'https://via.placeholder.com/400x200?text=Interview',
      'authorName': 'Media Team',
      'authorImage': 'https://via.placeholder.com/50x50?text=Media',
      'timeAgo': '5h ago',
    },
  ];

  final List<Map<String, dynamic>> videos = [
    {
      'videoId': 'dQw4w9WgXcQ',
      'title': 'Charity Trust Impact: How Your Donations Change Lives',
      'thumbnail': 'https://via.placeholder.com/400x200?text=Video+1',
    },
    {
      'videoId': 'jNQXAC9IVRw',
      'title': 'Behind the Scenes: Our Latest Campaign',
      'thumbnail': 'https://via.placeholder.com/400x200?text=Video+2',
    },
    {
      'videoId': 'dQw4w9WgXcQ',
      'title': 'Testimonials from Beneficiaries',
      'thumbnail': 'https://via.placeholder.com/400x200?text=Video+3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhite,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        'Hello, Sunitha Raheem!',
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
                          onTap: () {},
                          child: Text('See All >',
                              style: kSmallTitleM.copyWith(
                                  color: kThirdTextColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...activeCampaigns.map((campaign) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: HomeGradientCampaignCard(
                          title: campaign['title'],
                          description: campaign['description'],
                          image: campaign['image'],
                          raised: campaign['raised'],
                          goal: campaign['goal'],
                          dueDate: campaign['dueDate'],
                          onViewDetails: () {},
                          onDonate: () {},
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Completed Campaigns', style: kBodyTitleM),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
                          items: completedCampaigns.map((campaign) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: HomeCompletedCampaignCard(
                                heading: campaign['heading'],
                                subtitle: campaign['subtitle'],
                                goal: campaign['goal'],
                                collected: campaign['collected'],
                                posterImage: campaign['posterImage'],
                                isImagePoster: campaign['isImagePoster'],
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
                            count: completedCampaigns.length,
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
                          onTap: () {},
                          child: Text('See All',
                              style: kSmallTitleM.copyWith(
                                  color: kThirdTextColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              CarouselSlider(
                options: CarouselOptions(
                  height: 220,
                  viewportFraction: 0.75,
                  enableInfiniteScroll: true,
                  autoPlay: false,
                ),
                items: newsList.map((news) {
                  return HomeNewsCard(
                    title: news['title'],
                    subtitle: news['subtitle'],
                    image: news['image'],
                    authorName: news['authorName'],
                    authorImage: news['authorImage'],
                    timeAgo: news['timeAgo'],
                    onTap: () {},
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // --------------------- FEATURED VIDEOS ---------------------
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

              SizedBox(
                height: 200,
                child: PageView(
                  controller: _videoController,
                  onPageChanged: (page) {
                    setState(() => _videoIndex = page);
                  },
                  children: videos.map((video) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: HomeYoutubePlayerCard(
                        videoId: video['videoId'],
                        title: video['title'],
                        thumbnail: video['thumbnail'],
                        onTap: () {},
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: PageViewDotIndicator(
                  unselectedSize: Size(8, 8),
                  size: Size(9, 9),
                  currentItem: _videoIndex,
                  count: videos.length,
                  unselectedColor: Color(0xFFAEB9E1),
                  selectedColor: Color(0xFF0D74BC),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ));
  }
}
