import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class WelcomeServiceCarouselBanner extends StatefulWidget {
  final bool isMobile;

  const WelcomeServiceCarouselBanner({
    super.key,
    required this.isMobile,
  });

  @override
  State<WelcomeServiceCarouselBanner> createState() => _WelcomeServiceCarouselBannerState();
}

class _CarouselSlideData {
  final String imageUrl;
  final String badgeText;
  final IconData badgeIcon;
  final Color badgeColor;
  final String titleKey;
  final String descKey;
  final String tagText;
  final List<Color> gradientColors;

  const _CarouselSlideData({
    required this.imageUrl,
    required this.badgeText,
    required this.badgeIcon,
    required this.badgeColor,
    required this.titleKey,
    required this.descKey,
    required this.tagText,
    required this.gradientColors,
  });
}

class _WelcomeServiceCarouselBannerState extends State<WelcomeServiceCarouselBanner> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool _isUserTouching = false;

  static const List<_CarouselSlideData> _slides = [
    _CarouselSlideData(
      imageUrl: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800&auto=format&fit=crop&q=80',
      badgeText: 'TOUCHLESS • BAY 1 & 2',
      badgeIcon: Icons.bubble_chart_rounded,
      badgeColor: Color(0xFF00E5FF),
      titleKey: 'carouselSlide1Title',
      descKey: 'carouselSlide1Desc',
      tagText: 'Snow Foam',
      gradientColors: [
        Color(0xF2071328),
        Color(0xD90E2554),
        Color(0x66071328),
        Color(0x20000000),
      ],
    ),
    _CarouselSlideData(
      imageUrl: 'https://images.unsplash.com/photo-1601362840469-51e4d8d58785?w=800&auto=format&fit=crop&q=80',
      badgeText: 'POWER STEAM • CHASSIS',
      badgeIcon: Icons.speed_rounded,
      badgeColor: Color(0xFF38BDF8),
      titleKey: 'carouselSlide2Title',
      descKey: 'carouselSlide2Desc',
      tagText: 'Underbody Jet',
      gradientColors: [
        Color(0xF2081430),
        Color(0xD91E3A8A),
        Color(0x66081430),
        Color(0x20000000),
      ],
    ),
    _CarouselSlideData(
      imageUrl: 'https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=800&auto=format&fit=crop&q=80',
      badgeText: 'CERAMIC GLOSS • SHIELD',
      badgeIcon: Icons.auto_awesome_rounded,
      badgeColor: Color(0xFFFBBF24),
      titleKey: 'carouselSlide3Title',
      descKey: 'carouselSlide3Desc',
      tagText: 'Mirror Shine',
      gradientColors: [
        Color(0xF21C1407),
        Color(0xD93D2A08),
        Color(0x661C1407),
        Color(0x20000000),
      ],
    ),
    _CarouselSlideData(
      imageUrl: 'https://images.unsplash.com/photo-1552930294-6b595f4c2974?w=800&auto=format&fit=crop&q=80',
      badgeText: 'EXPRESS • 15 MIN TURNOVER',
      badgeIcon: Icons.flash_on_rounded,
      badgeColor: Color(0xFF34D399),
      titleKey: 'carouselSlide4Title',
      descKey: 'carouselSlide4Desc',
      tagText: 'Zero Wait',
      gradientColors: [
        Color(0xF2041D17),
        Color(0xD9064E3B),
        Color(0x66041D17),
        Color(0x20000000),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 3800), (_) {
      if (!_isUserTouching && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isMobile = widget.isMobile;
    final bannerHeight = isMobile ? 106.0 : 116.0;

    return Container(
      height: bannerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Rolling PageView
            GestureDetector(
              onPanDown: (_) => setState(() => _isUserTouching = true),
              onPanCancel: () => setState(() => _isUserTouching = false),
              onPanEnd: (_) => setState(() => _isUserTouching = false),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Thumbnail Image
                      Image.network(
                        slide.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: slide.gradientColors.sublist(0, 2),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),

                      // Gradient Overlay for readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: const [0.0, 0.55, 0.85, 1.0],
                            colors: slide.gradientColors,
                          ),
                        ),
                      ),

                      // Slide Content
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 14 : 18,
                          vertical: isMobile ? 8 : 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Row: Badge & Tag
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: slide.badgeColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: slide.badgeColor.withOpacity(0.55), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(slide.badgeIcon, size: 11, color: slide.badgeColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        slide.badgeText,
                                        style: TextStyle(
                                          fontSize: isMobile ? 9.5 : 10.5,
                                          fontWeight: FontWeight.w900,
                                          color: slide.badgeColor,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    slide.tagText,
                                    style: TextStyle(
                                      fontSize: isMobile ? 9 : 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Middle: Bold Title
                            Text(
                              state.tr(slide.titleKey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isMobile ? 15.5 : 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),

                            // Bottom: Subtitle Service Description
                            Text(
                              state.tr(slide.descKey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isMobile ? 10.5 : 11.5,
                                color: Colors.white.withOpacity(0.92),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Pagination Dots Overlay (Top-Right)
            Positioned(
              top: 10,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_slides.length, (idx) {
                    final isActive = idx == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: isActive ? 14 : 5,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
