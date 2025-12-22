import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:Annujoom/src/data/utils/date_formatter.dart';
import 'package:Annujoom/src/interfaces/components/cards/campaing_card.dart';
import 'package:Annujoom/src/interfaces/components/cards/transaction_card.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/choice_chip_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:Annujoom/src/data/providers/campaigns_provider.dart';
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/interfaces/components/confirmation_dialog.dart';
import 'package:Annujoom/src/interfaces/main_pages/campaign_pages/add_campaign.dart';
import 'package:Annujoom/src/data/models/campaign_model.dart';

class CampaignPage extends ConsumerStatefulWidget {
  const CampaignPage({super.key});

  @override
  ConsumerState<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends ConsumerState<CampaignPage>
    with TickerProviderStateMixin {
  late TabController _controller;
  late ScrollController _generalCampaignsController;
  late ScrollController _userTransactionsController;
  late ScrollController _memberTransactionsController;
  late ScrollController _createdCampaignsController;
  late ScrollController _joinedCampaignsController;
  late ScrollController _approvalsController;
  late TextEditingController _searchController;
  bool _isPresident = false;
  bool _categoryInitialized = false;

  @override
  void initState() {
    super.initState();
    print('=== CampaignPage initState called ===');
    _controller = TabController(length: 3, vsync: this);
    _generalCampaignsController = ScrollController();
    _userTransactionsController = ScrollController();
    _memberTransactionsController = ScrollController();
    _createdCampaignsController = ScrollController();
    _joinedCampaignsController = ScrollController();
    _approvalsController = ScrollController();
    _searchController = TextEditingController();

    _setupScrollController(
      _generalCampaignsController,
      () => ref.read(generalCampaignsProvider.notifier).loadNextPage(),
    );
    _setupScrollController(
      _userTransactionsController,
      () => ref.read(participatedCampaignsProvider.notifier).loadNextPage(),
    );
    _setupScrollController(
      _memberTransactionsController,
      () => ref.read(memberDonationsProvider.notifier).loadNextPage(),
    );
    _setupScrollController(
      _createdCampaignsController,
      () => ref.read(createdCampaignsProvider.notifier).loadNextPage(),
    );
    _setupScrollController(
      _joinedCampaignsController,
      () => ref.read(participatedCampaignsProvider.notifier).loadNextPage(),
    );
    _setupScrollController(
      _approvalsController,
      () => ref.read(pendingApprovalCampaignsProvider.notifier).loadNextPage(),
    );
    _loadUserRole();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('=== didChangeDependencies called ===');
    print('_categoryInitialized: $_categoryInitialized');

    if (!_categoryInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      print('Route arguments: $args');

      if (args is Map && args.containsKey('category')) {
        final category = args['category'] as String;
        print('Setting category to: $category');
        // Use microtask to ensure the provider is updated after the first build
        // starts watching it, which prevents immediate auto-disposal
        Future.microtask(() {
          if (mounted) {
            print('Executing scheduled category initialization: $category');
            ref
                .read(campaignCategoryFilterProvider.notifier)
                .setCategory(category);
          }
        });
        _categoryInitialized = true;
        print('Category initialization scheduled for: $category');
      } else {
        print('No category in arguments or args is null/not a map');
        _categoryInitialized =
            true; // Mark as initialized anyway to avoid re-checking
      }
    } else {
      print('Category already initialized, skipping');
    }
  }

  void _setupScrollController(
    ScrollController controller,
    VoidCallback onEndReached,
  ) {
    controller.addListener(() {
      if (!controller.hasClients) return;
      final position = controller.position;
      if (position.pixels >= position.maxScrollExtent - 500) {
        onEndReached();
      }
    });
  }

  Future<void> _loadUserRole() async {
    final userRole = GlobalVariables.getUserRole();
    if (mounted) {
      setState(() {
        _isPresident = userRole == 'president';
        final tabCount = _isPresident ? 4 : 3;
        if (_controller.length != tabCount) {
          _controller.dispose();
          _controller = TabController(length: tabCount, vsync: this);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _generalCampaignsController.dispose();
    _userTransactionsController.dispose();
    _memberTransactionsController.dispose();
    _createdCampaignsController.dispose();
    _joinedCampaignsController.dispose();
    _approvalsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secureStorage = ref.watch(secureStorageServiceProvider);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: kTextColor,
                  size: 20,
                ),
              )
            : null,
        backgroundColor: kWhite,
        elevation: 0,
        title: Text("Campaign", style: kBodyTitleM),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Builder(
                builder: (context) {
                  final userRole = GlobalVariables.getUserRole();
                  final isAdmin = userRole != 'member';
                  if (!isAdmin) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddCampaignPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add,
                          color: kPrimaryColor,
                          size: 24,
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: kBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: kSmallTitleR,
              controller: _controller,
              labelColor: kPrimaryColor,
              unselectedLabelColor: kSecondaryTextColor,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: kPrimaryColor,
                  width: 3,
                ),
                insets: EdgeInsets.zero,
              ),
              tabs: [
                Tab(
                  child: _buildMarqueeTab("Campaign"),
                ),
                Tab(child: _buildMarqueeTab("Transactions")),
                Tab(child: _buildMarqueeTab("My Campaigns")),
                if (_isPresident) Tab(child: _buildMarqueeTab("Approvals")),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          _generalCampaignTab(),
          _yourTransactionsTab(),
          _myCampaignsTab(),
          if (_isPresident) _approvalsTab(),
        ],
      ),
    );
  }

  Widget _buildMarqueeTab(String text) {
    return Marquee(
      text: text,
      style: kSmallTitleR,
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      blankSpace: 50.0,
      velocity: 30.0,
      pauseAfterRound: Duration(seconds: 2),
      startPadding: 0.0,
      accelerationDuration: Duration(seconds: 1),
      accelerationCurve: Curves.linear,
      decelerationDuration: Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }

  // ---------------- TAB 1 ---------------- //
  Widget _generalCampaignTab() {
    final campaignsState = ref.watch(generalCampaignsProvider);
    final selectedCategory = ref.watch(campaignCategoryFilterProvider);
      final preferredLanguage =
                        GlobalVariables.getPreferredLanguage();
    print('=== _generalCampaignTab rebuild ===');
    print('selectedCategory from provider: $selectedCategory');

    return Column(
      children: [
        ChoiceChipFilter(
          options: const [
            'All',
            'General Campaign',
            'General Funding',
            'Zakat',
            'Orphan',
            'Widow',
            'Ghusl Mayyit',
          ],
          selectedOption: selectedCategory,
          onSelectionChanged: (selected) {
            print('Filter changed to: $selected');
            ref
                .read(campaignCategoryFilterProvider.notifier)
                .setCategory(selected == 'All' ? '' : selected);
          },
          isScrollable: true,
        ),
        Expanded(
          child: campaignsState.when(
            data: (paginationState) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                controller: _generalCampaignsController,
                itemCount: paginationState.campaigns.length,
                itemBuilder: (context, index) {
                  final campaign = paginationState.campaigns[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: index * 50,
                      child: CampaignCard(
                        id: campaign.id ?? '',
                        description: campaign.getDescription(preferredLanguage) ?? '',
                        title: campaign.getTitle(preferredLanguage) ?? '',
                        category: campaign.category ?? '',
                        date: formatDate(campaign.targetDate) ?? '',
                        image: campaign.coverImage ?? '',
                        raised: campaign.collectedAmount?.toInt() ?? 0,
                        goal: campaign.targetAmount?.toInt() ?? 0,
                        onDetails: () {
                          Navigator.of(context).pushNamed(
                            'CampaignDetail',
                            arguments: {
                              '_id': campaign.id ?? '',
                              'title': campaign.title ?? '',
                              'description': campaign.description ?? '',
                              'category': campaign.category ?? '',
                              'date': formatDate(campaign.targetDate) ?? '',
                              'image': campaign.coverImage ?? '',
                              'raised': campaign.collectedAmount?.toInt() ?? 0,
                              'goal': campaign.targetAmount?.toInt() ?? 0,
                            },
                          );
                        },
                        onDonate: () {},
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: LoadingAnimation()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(generalCampaignsProvider.notifier).refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- TAB 2 ---------------- //
  Widget _yourTransactionsTab() {
    final secureStorage = ref.watch(secureStorageServiceProvider);
    final currentFilter = ref.watch(transactionsFilterProvider);
    final userRole = GlobalVariables.getUserRole();
    final isNonMember = userRole != 'member';

    return Column(
      children: [
        if (isNonMember)
              FutureBuilder<String?>(
                future: secureStorage.getUserData().then((user) => user?.name),
                builder: (context, nameSnapshot) {
                  final userName = nameSnapshot.data ?? 'User';
                  return ChoiceChipFilter(
                    options: [userName, 'Member Transactions'],
                    selectedOption:
                        currentFilter ? 'Member Transactions' : userName,
                    onSelectionChanged: (selected) {
                      ref
                          .read(transactionsFilterProvider.notifier)
                          .setFilter(selected == 'Member Transactions');
                    },
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    // 🔍 Search field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          ref
                              .read(transactionSearchProvider.notifier)
                              .setSearch(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: kSmallTitleL.copyWith(color: kGrey),
                          prefixIcon: const Icon(Icons.search, color: kGrey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    // │ Vertical divider
                    Container(
                      height: 24,
                      width: 1,
                      color: kBorder,
                    ),

                    // 🎛 Filter icon
                    GestureDetector(
                      onTap: () => _showFilterBottomSheet(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(Icons.tune, color: kGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: currentFilter
                  ? _buildMemberTransactionsView()
                  : _buildUserTransactionsView(),
            ),
          ],
        );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    final currentDates = ref.read(transactionDateFilterProvider);
    if (currentDates['start_date'] != null) {
      final date = DateTime.parse(currentDates['start_date']!);
      startDateController.text =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }
    if (currentDates['end_date'] != null) {
      final date = DateTime.parse(currentDates['end_date']!);
      endDateController.text =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Filter', style: kBodyTitleSB),
              const SizedBox(height: 24),
              Text('Start Date', style: kSmallTitleM),
              const SizedBox(height: 8),
              InputField(
                type: CustomFieldType.date,
                hint: 'dd/mm/yyyy',
                controller: startDateController,
              ),
              const SizedBox(height: 20),
              Text('End Date', style: kSmallTitleM),
              const SizedBox(height: 8),
              InputField(
                type: CustomFieldType.date,
                hint: 'dd/mm/yyyy',
                controller: endDateController,
              ),
              const SizedBox(height: 32),
              primaryButton(
                label: 'Apply',
                onPressed: () {
                  String? formattedStart;
                  String? formattedEnd;

                  if (startDateController.text.isNotEmpty) {
                    final parts = startDateController.text.split('/');
                    formattedStart = "${parts[2]}-${parts[1]}-${parts[0]}";
                  }
                  if (endDateController.text.isNotEmpty) {
                    final parts = endDateController.text.split('/');
                    formattedEnd = "${parts[2]}-${parts[1]}-${parts[0]}";
                  }

                  ref
                      .read(transactionDateFilterProvider.notifier)
                      .setDates(formattedStart, formattedEnd);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
              if (currentDates['start_date'] != null ||
                  currentDates['end_date'] != null)
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(transactionDateFilterProvider.notifier).clear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear Filters',
                      style: kSmallTitleM.copyWith(color: Colors.red),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserTransactionsView() {
    final participatedState = ref.watch(participatedCampaignsProvider);

    return participatedState.when(
      data: (paginationState) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          controller: _userTransactionsController,
          itemCount: paginationState.donations.length,
          itemBuilder: (context, index) {
            final donation = paginationState.donations[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: index * 50,
                child: TransactionCard(
                  id: donation.paymentId ?? '',
                  type: donation.campaign?.category ?? '',
                  amount: donation.amount?.toString() ?? '-',
                  status: donation.status ?? '',
                  date: formatDate(donation.createdAt) ?? '',
                  receipt: donation.receipt ?? '',
                  donorName: donation.user_name ?? '',
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(participatedCampaignsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTransactionsView() {
    final memberDonationsState = ref.watch(memberDonationsProvider);

    return memberDonationsState.when(
      data: (paginationState) {
        if (paginationState.donations.isEmpty) {
          return Center(
            child: Text(
              'No member transactions',
              style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          controller: _memberTransactionsController,
          itemCount: paginationState.donations.length,
          itemBuilder: (context, index) {
            final donation = paginationState.donations[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: index * 50,
                child: TransactionCard(
                  id: donation.paymentId ?? '',
                  type: donation.campaign?.category ?? '',
                  amount: donation.amount?.toString() ?? '-',
                  status: donation.status ?? '',
                  date: formatDate(donation.createdAt) ?? '',
                  receipt: donation.receipt ?? '',
                  donorName: donation.user_name ?? '',
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(memberDonationsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TAB 3 ---------------- //
  Widget _myCampaignsTab() {
    final secureStorage = ref.watch(secureStorageServiceProvider);
    final currentFilter = ref.watch(myCampaignsFilterProvider);
    final userRole = GlobalVariables.getUserRole();
    final isNonMember = userRole != 'member';

    return Column(
      children: [
        if (isNonMember)
              ChoiceChipFilter(
                options: const ['Joined', 'Created'],
                selectedOption: currentFilter ? 'Created' : 'Joined',
                onSelectionChanged: (selected) {
                  ref
                      .read(myCampaignsFilterProvider.notifier)
                      .setFilter(selected == 'Created');
                },
              ),
            Expanded(
              child: currentFilter
                  ? _buildCreatedCampaignsView()
                  : _buildJoinedCampaignsView(),
            ),
          ],
        );
  }

  Widget _buildCreatedCampaignsView() {
    final campaignsState = ref.watch(createdCampaignsProvider);
      final preferredLanguage =
                        GlobalVariables.getPreferredLanguage();
    return campaignsState.when(
      data: (paginationState) {
        if (paginationState.campaigns.isEmpty) {
          return Center(
            child: Text(
              'No created campaigns',
              style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          controller: _createdCampaignsController,
          itemCount: paginationState.campaigns.length,
          itemBuilder: (context, index) {
            final campaign = paginationState.campaigns[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: index * 50,
                child: CampaignCard(
                  id: campaign.id ?? '',
                  description: campaign.getDescription(preferredLanguage) ?? '',
                  title: campaign.getTitle(preferredLanguage) ?? '',
                  category: campaign.category ?? '',
                  date: formatDate(campaign.targetDate) ?? '',
                  image: campaign.coverImage ?? '',
                  raised: campaign.collectedAmount?.toInt() ?? 0,
                  goal: campaign.targetAmount?.toInt() ?? 0,
                  onDetails: () {
                    Navigator.of(context).pushNamed(
                      'CampaignDetail',
                      arguments: {
                        '_id': campaign.id ?? '',
                        'title': campaign.title ?? '',
                        'description': campaign.description ?? '',
                        'category': campaign.category ?? '',
                        'date': formatDate(campaign.targetDate) ?? '',
                        'image': campaign.coverImage ?? '',
                        'raised': campaign.collectedAmount?.toInt() ?? 0,
                        'goal': campaign.targetAmount?.toInt() ?? 0,
                      },
                    );
                  },
                  isMyCampaign: true,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(createdCampaignsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinedCampaignsView() {
    final donationsState = ref.watch(participatedCampaignsProvider);
      final preferredLanguage =
                        GlobalVariables.getPreferredLanguage();
    return donationsState.when(
      data: (paginationState) {
        final campaigns = paginationState.donations
            .map((donation) => donation.campaign)
            .whereType<CampaignModel>()
            .toList();

        if (campaigns.isEmpty) {
          return Center(
            child: Text(
              'No joined campaigns',
              style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          controller: _joinedCampaignsController,
          itemCount: campaigns.length,
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: index * 50,
                child: CampaignCard(
                  id: campaign.id ?? '',
                  description: campaign.getDescription(preferredLanguage) ?? '',
                  title: campaign.getTitle(preferredLanguage) ?? '',
                  category: campaign.category ?? '',
                  date: formatDate(campaign.targetDate) ?? '',
                  image: campaign.coverImage ?? '',
                  raised: campaign.collectedAmount?.toInt() ?? 0,
                  goal: campaign.targetAmount?.toInt() ?? 0,
                  onDetails: () {
                    Navigator.of(context).pushNamed(
                      'CampaignDetail',
                      arguments: {
                        '_id': campaign.id ?? '',
                        'title': campaign.title ?? '',
                        'description': campaign.description ?? '',
                        'category': campaign.category ?? '',
                        'date': formatDate(campaign.targetDate) ?? '',
                        'image': campaign.coverImage ?? '',
                        'raised': campaign.collectedAmount?.toInt() ?? 0,
                        'goal': campaign.targetAmount?.toInt() ?? 0,
                      },
                    );
                  },
                  isMyCampaign: true,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(participatedCampaignsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TAB 4 (APPROVALS) ---------------- //
  Widget _approvalsTab() {
    final approvalsState = ref.watch(pendingApprovalCampaignsProvider);
      final preferredLanguage =
                        GlobalVariables.getPreferredLanguage();
    return approvalsState.when(
      data: (paginationState) {
        if (paginationState.campaigns.isEmpty) {
          return const Center(
            child: Text('No campaigns pending approval'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          controller: _approvalsController,
          itemCount: paginationState.campaigns.length,
          itemBuilder: (context, index) {
            final campaign = paginationState.campaigns[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: index * 50,
                child: CampaignCard(
                  id: campaign.id ?? '',
                  description: campaign.getDescription(preferredLanguage) ?? '',
                  title: campaign.getTitle(preferredLanguage) ?? '',
                  category: campaign.category ?? '',
                  date: formatDate(campaign.targetDate) ?? '',
                  startDate: formatDate(campaign.startDate),
                  image: campaign.coverImage ?? '',
                  raised: campaign.collectedAmount?.toInt() ?? 0,
                  goal: campaign.targetAmount?.toInt() ?? 0,
                  onDetails: () {},
                  isApprovalCard: true,
                  onApprove: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Approve Campaign',
                        message:
                            'Are you sure you want to approve "${campaign.title}"?',
                        confirmButtonText: 'Approve',
                        onConfirm: () async {
                          final approved = await ref
                              .read(pendingApprovalCampaignsProvider.notifier)
                              .approveCampaign(campaign.id ?? '');
                          if (approved) {
                            SnackbarService().showSnackBar(
                              'Campaign approved successfully',
                              type: SnackbarType.success,
                            );
                          }
                        },
                        cancelButtonText: 'Cancel',
                      ),
                    );
                  },
                  onReject: () {
                    _showRejectDialog(
                        context, campaign.id ?? '', campaign.getTitle(preferredLanguage) ?? '');
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(pendingApprovalCampaignsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(
      BuildContext context, String campaignId, String campaignTitle) {
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
                'Reject Campaign',
                style: kHeadTitleR,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to reject "$campaignTitle"?',
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Enter rejection reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 28),
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
                        'Cancel',
                        style: kSmallerTitleL.copyWith(color: kTextColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final rejected = await ref
                            .read(pendingApprovalCampaignsProvider.notifier)
                            .rejectCampaign(campaignId, reasonController.text);
                        if (rejected) {
                          SnackbarService().showSnackBar(
                            'Campaign rejected successfully',
                            type: SnackbarType.success,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Reject',
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
}
