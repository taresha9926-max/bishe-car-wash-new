import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Redirecting to TikTok app... 🎵',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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

    UrlLauncherHelper.openUrl(url);
  }

  void _showManageReelsDialog(BuildContext context) {
    final state = AppStateProvider.read(context);
    final reels = List<TikTokAdVideo>.from(state.tiktokReels);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.video_library_rounded, color: Color(0xFFFE2C55), size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Super Admin: TikTok Rolling Reels',
                    style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580, maxHeight: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage the commercial TikTok video links & preview thumbnails displayed on the Welcome Screen rolling banner (at least 4 reels recommended):',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: reels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final reel = reels[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.black12,
                                  child: reel.thumbnailUrl.isNotEmpty
                                      ? Image.network(
                                          reel.thumbnailUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.grey),
                                        )
                                      : const Icon(Icons.music_note, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${index + 1}. ${reel.title}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      reel.tiktokUrl,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFFFE2C55)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                                tooltip: 'Edit Reel',
                                onPressed: () => _editSingleReelDialog(context, reel, (updated) {
                                  setDialogState(() {
                                    reels[index] = updated;
                                  });
                                }),
                              ),
                              if (reels.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                  tooltip: 'Delete Reel',
                                  onPressed: () {
                                    setDialogState(() {
                                      reels.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final newReel = TikTokAdVideo(
                        id: 'reel-${DateTime.now().millisecondsSinceEpoch}',
                        title: 'New Detailing Reel #${reels.length + 1}',
                        subtitle: 'Watch on TikTok',
                        tiktokUrl: 'https://www.tiktok.com/@bishe_car_wash',
                        thumbnailUrl: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800&auto=format&fit=crop&q=80',
                      );
                      _editSingleReelDialog(context, newReel, (created) {
                        setDialogState(() {
                          reels.add(created);
                        });
                      });
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Another TikTok Reel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE2C55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  state.setTikTokReels(reels);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('TikTok rolling reels updated successfully!'),
                      backgroundColor: AppColors.statusReady,
                    ),
                  );
                },
                child: const Text('Save All Reels'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editSingleReelDialog(BuildContext context, TikTokAdVideo reel, void Function(TikTokAdVideo) onSaved) {
    final titleCtrl = TextEditingController(text: reel.title);
    final subCtrl = TextEditingController(text: reel.subtitle);
    final linkCtrl = TextEditingController(text: reel.tiktokUrl);
    final thumbCtrl = TextEditingController(text: reel.thumbnailUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Edit TikTok Reel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title / Highlight', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subCtrl,
                  decoration: const InputDecoration(labelText: 'Subtitle / Description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: linkCtrl,
                  decoration: const InputDecoration(
                    labelText: 'TikTok Video Link',
                    hintText: 'https://www.tiktok.com/@bishe_car_wash/video/...',
                    prefixIcon: Icon(Icons.link_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: thumbCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Thumbnail Image URL',
                    hintText: 'https://images.unsplash.com/...',
                    prefixIcon: Icon(Icons.image_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFE2C55), foregroundColor: Colors.white),
            onPressed: () {
              if (linkCtrl.text.trim().isNotEmpty) {
                onSaved(
                  reel.copyWith(
                    title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : reel.title,
                    subtitle: subCtrl.text.trim().isNotEmpty ? subCtrl.text.trim() : reel.subtitle,
                    tiktokUrl: linkCtrl.text.trim(),
                    thumbnailUrl: thumbCtrl.text.trim(),
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Reel'),
          ),
        ],
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
              tiktokUrl: 'https://www.tiktok.com/@bishe_car_wash',
              thumbnailUrl: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800&auto=format&fit=crop&q=80',
            ),
          ];

    final currentReel = reels[_currentPage.clamp(0, reels.length - 1)];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Luxury dark slate
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFE2C55).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFE2C55).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF00F2FE).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with TikTok Branding & Super Admin Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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
                    const Text(
                      'OFFICIAL TIKTOK REELS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00F2FE), Color(0xFFFE2C55)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'REEL ${_currentPage + 1} OF ${reels.length}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                // Super Admin Edit Reels Button
                InkWell(
                  onTap: () => _showManageReelsDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded, size: 13, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Manage Reels',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Auto-Rolling Swipable 16:9 Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isUserInteracting = true),
              onExit: (_) => setState(() => _isUserInteracting = false),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
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
                      return _buildSlideCard(context, reel);
                    },
                  ),
                ),
              ),
            ),
          ),

          // Bottom Slide Indicators & Direct TikTok App Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                // Slide Dot Indicators
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(reels.length, (i) {
                    final isActive = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: isActive ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFFE2C55) : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currentReel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _launchTikTok(context, currentReel.tiktokUrl),
                  icon: const Icon(Icons.music_note_rounded, size: 15),
                  label: const Text('Open in TikTok 🎵', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE2C55),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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

  Widget _buildSlideCard(BuildContext context, TikTokAdVideo reel) {
    return InkWell(
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
                  Colors.black.withOpacity(0.72),
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
                    width: 64,
                    height: 64,
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
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.play_arrow_rounded, size: 38, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 13, color: Colors.white70),
                  SizedBox(width: 5),
                  Text(
                    'Tap to Watch in TikTok App',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Music Track & Title Overlay
          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: Row(
              children: [
                const Icon(Icons.graphic_eq_rounded, size: 16, color: Color(0xFF00F2FE)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reel.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '🎵 ${reel.subtitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
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
            child: const Icon(Icons.local_car_wash_rounded, size: 180, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
