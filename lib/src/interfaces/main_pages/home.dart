import 'package:carousel_slider/carousel_slider.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/components/cards/index.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _completedCampaignIndex = 0;
  int _newsIndex = 0;
  int _videoIndex = 0;

  // Sample data - Replace with actual data from providers
  final List<Map<String, dynamic>> activeCampaigns = [
    {
      'title': 'Landslide Relief Fund',
      'description': 'Help us build homes for families displaced by the recent landslides.',
      'image': 'https://via.placeholder.com/400x200?text=Landslide+Relief',
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
      'subtitle': 'To support women affected by the landslide, Annujoom distributed sewing machines.',
      'image': 'https://via.placeholder.com/400x200?text=Sewing+Machines',
      'authorName': 'Rachel Kim',
      'authorImage': 'https://via.placeholder.com/50x50?text=Rachel',
      'timeAgo': '1h ago',
    },
    {
      'title': 'Donates Auto-Rickshaw to Landslide-Hit Family',
      'subtitle': 'Annujoom donated an auto-rickshaw to help families rebuild their lives.',
      'image': 'https://via.placeholder.com/400x200?text=Auto+Rickshaw',
      'authorName': 'John Smith',
      'authorImage': 'https://via.placeholder.com/50x50?text=John',
      'timeAgo': '3h ago',
    },
    {
      'title': 'Times of India Interview',
      'subtitle': 'Our founder shares insights on community-driven charitable initiatives.',
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
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Sunitha Raheem!',
              style: kHeadTitleM.copyWith(fontSize: 20),
            ),
            Text(
              "Let's empowering lives through kindness",
              style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== FUNDING CAMPAIGNS SECTION ==========
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Funding Campaigns',
                  style: kHeadTitleM.copyWith(fontSize: 18),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'See All',
                    style: kSmallTitleM.copyWith(color: kThirdTextColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...activeCampaigns.map((campaign) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: HomeCampaignCard(
                  title: campaign['title'],
                  description: campaign['description'],
                  image: campaign['image'],
                  raised: campaign['raised'],
                  goal: campaign['goal'],
                  dueDate: campaign['dueDate'],
                  onViewDetails: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View Details tapped')),
                    );
                  },
                  onDonate: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Donate tapped')),
                    );
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 24),

            // ========== COMPLETED CAMPAIGNS SECTION ==========
            Text(
              'Completed Campaigns',
              style: kHeadTitleM.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Together, We Made It Happen!',
              style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
            ),
            const SizedBox(height: 12),
            CarouselSlider(
              options: CarouselOptions(
                height: 280,
                viewportFraction: 0.85,
                enableInfiniteScroll: true,
                autoPlay: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _completedCampaignIndex = index;
                  });
                },
              ),
              items: completedCampaigns.map((campaign) {
                return HomeCompletedCampaignCard(
                  heading: campaign['heading'],
                  subtitle: campaign['subtitle'],
                  goal: campaign['goal'],
                  collected: campaign['collected'],
                  posterImage: campaign['posterImage'],
                  isImagePoster: campaign['isImagePoster'],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${campaign['heading']} tapped')),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _completedCampaignIndex,
                count: completedCampaigns.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: kPrimaryColor,
                  dotColor: kBorder,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========== LATEST NEWS SECTION ==========
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest News',
                  style: kHeadTitleM.copyWith(fontSize: 18),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'See All',
                    style: kSmallTitleM.copyWith(color: kThirdTextColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CarouselSlider(
              options: CarouselOptions(
                height: 220,
                viewportFraction: 0.75,
                enableInfiniteScroll: true,
                autoPlay: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _newsIndex = index;
                  });
                },
              ),
              items: newsList.map((news) {
                return HomeNewsCard(
                  title: news['title'],
                  subtitle: news['subtitle'],
                  image: news['image'],
                  authorName: news['authorName'],
                  authorImage: news['authorImage'],
                  timeAgo: news['timeAgo'],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${news['title']} tapped')),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _newsIndex,
                count: newsList.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: kPrimaryColor,
                  dotColor: kBorder,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========== FEATURED VIDEOS SECTION ==========
            Text(
              'Featured Videos',
              style: kHeadTitleM.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                viewportFraction: 0.85,
                enableInfiniteScroll: true,
                autoPlay: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _videoIndex = index;
                  });
                },
              ),
              items: videos.map((video) {
                return HomeYoutubePlayerCard(
                  videoId: video['videoId'],
                  title: video['title'],
                  thumbnail: video['thumbnail'],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${video['title']} tapped')),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _videoIndex,
                count: videos.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: kPrimaryColor,
                  dotColor: kBorder,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
