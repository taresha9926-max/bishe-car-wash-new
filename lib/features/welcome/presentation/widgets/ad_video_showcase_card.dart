import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../domain/models/tiktok_ad_video.dart';

class AdVideoShowcaseCard extends StatefulWidget {
  const AdVideoShowcaseCard({super.key});

  @override
  State<AdVideoShowcaseCard> createState() => _AdVideoShowcaseCardState();
}

class _AdVideoShowcaseCardState extends State<AdVideoShowcaseCard> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 4200), (timer) {
      if (!_isUserInteracting && _pageController.hasClients) {
        final state = AppStateProvider.read(context);
        final reelsCount = state.tiktokReels.length;
        if (reelsCount > 1) {
          final nextPage = (_currentPage + 1) % reelsCount;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _launchTikTok(BuildContext context, String url) {
    final cleanUrl = UrlLauncherHelper.cleanUrl(url);
    if (cleanUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TikTok link is not configured yet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 1. Immediately trigger URL opening synchronously within the tap callback
    // to preserve transient user activation gesture on mobile WebKit (iOS Safari) and Chrome
    UrlLauncherHelper.openUrl(cleanUrl);

    // 2. Display smooth notification feedback toast to user
    final state = AppStateProvider.read(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.tr('redirectingToTikTok'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final reels = state.tiktokReels.isNotEmpty
        ? state.tiktokReels
        : [
            const TikTokAdVideo(
              id: 'fallback-1',
              title: 'BISHE Detailing Reel',
              subtitle: 'Tap to Watch on TikTok',
              tiktokUrl: 'https://vt.tiktok.com/ZSgWCxdWL/',
              thumbnailUrl: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800&auto=format&fit=crop&q=80',
            ),
          ];

    final currentReel = reels[_currentPage.clamp(0, reels.length - 1)];
    final localizedCurrentTitle = currentReel.localizedTitle(state.currentLang);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B), // Luxury deep obsidian navy
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFE2C55).withOpacity(0.35), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFE2C55).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF00F2FE).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Bar: TikTok Branding + Verified Account Badge (100% Read-only)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.music_note_rounded, size: 14, color: Color(0xFF00F2FE)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.tr('tiktokReelsTitle'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00F2FE), Color(0xFFFE2C55)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${state.tr('reelCounter')} ${_currentPage + 1} ${state.tr('ofWord')} ${reels.length}',
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                // Official TikTok Handle Pill (Read-only)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 12, color: Color(0xFF00F2FE)),
                      SizedBox(width: 4),
                      Text(
                        '@bishe_car_wash',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Auto-Rolling Swipable 16:9 Banner (Touch & Swipe Optimized)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Listener(
              onPointerDown: (_) {
                _autoScrollTimer?.cancel();
                _isUserInteracting = true;
              },
              onPointerUp: (_) {
                _isUserInteracting = false;
                _startAutoScroll();
              },
              child: MouseRegion(
                onEnter: (_) => setState(() => _isUserInteracting = true),
                onExit: (_) => setState(() => _isUserInteracting = false),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollEndNotification) {
                          final page = _pageController.page?.round();
                          if (page != null && page != _currentPage && page >= 0 && page < reels.length) {
                            setState(() {
                              _currentPage = page;
                            });
                          }
                        }
                        return false;
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: reels.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final reel = reels[index];
                          return _buildSlideCard(context, state, reel);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Bottom Slide Indicators & Direct TikTok App Button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                // Interactive Slide Dot Indicators
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(reels.length, (i) {
                    final isActive = i == _currentPage;
                    return GestureDetector(
                      onTap: () {
                        if (_pageController.hasClients) {
                          _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          width: isActive ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFFE2C55) : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    localizedCurrentTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _launchTikTok(context, currentReel.tiktokUrl),
                  icon: const Icon(Icons.music_note_rounded, size: 14),
                  label: Text(
                    state.tr('openInTikTok'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE2C55),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideCard(BuildContext context, dynamic state, TikTokAdVideo reel) {
    final title = reel.localizedTitle(state.currentLang);
    final subtitle = reel.localizedSubtitle(state.currentLang);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _launchTikTok(context, reel.tiktokUrl),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Thumbnail with Luxury Car Detailing imagery
          if (reel.thumbnailUrl.isNotEmpty)
            Image.network(
              reel.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderBackground(),
            )
          else
            _buildPlaceholderBackground(),

          // Dark Gradient Vignette for Readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.75),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Center Pulsing Play Button
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFE2C55), Color(0xFF00F2FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFE2C55).withOpacity(0.45),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.play_arrow_rounded, size: 34, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top Floating Badge
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, size: 12, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    state.tr('tapToWatchInTikTok'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Music Track & Title Overlay
          Positioned(
            bottom: 10,
            left: 12,
            right: 12,
            child: Row(
              children: [
                const Icon(Icons.graphic_eq_rounded, size: 15, color: Color(0xFF00F2FE)),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '🎵 $subtitle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.white.withOpacity(0.82),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF020617),
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.08,
            child: const Icon(Icons.local_car_wash_rounded, size: 160, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
