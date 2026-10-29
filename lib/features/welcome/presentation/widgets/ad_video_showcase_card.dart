import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class AdVideoShowcaseCard extends StatefulWidget {
  const AdVideoShowcaseCard({super.key});

  @override
  State<AdVideoShowcaseCard> createState() => _AdVideoShowcaseCardState();
}

class _AdVideoShowcaseCardState extends State<AdVideoShowcaseCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
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

  void _showEditTikTokDialog(BuildContext context) {
    final state = AppStateProvider.read(context);
    final linkController = TextEditingController(text: state.tiktokUrl);
    final thumbController = TextEditingController(text: state.tiktokThumbnailUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.video_library_rounded, color: Color(0xFFFE2C55), size: 24),
            SizedBox(width: 10),
            Text('Configure TikTok Showcase', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the TikTok video or profile link. When customers click the ad card, they will be redirected directly to the TikTok app:',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: 'TikTok Video URL',
                  hintText: 'https://www.tiktok.com/@bishe_car_wash/video/...',
                  prefixIcon: const Icon(Icons.link_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: thumbController,
                decoration: InputDecoration(
                  labelText: 'Custom Thumbnail Image URL (Optional)',
                  hintText: 'https://example.com/thumbnail.jpg',
                  prefixIcon: const Icon(Icons.image_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.tag_rounded, size: 14),
                    label: const Text('@bishe_car_wash Profile', style: TextStyle(fontSize: 11)),
                    onPressed: () => linkController.text = 'https://www.tiktok.com/@bishe_car_wash',
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.trending_up_rounded, size: 14),
                    label: const Text('Car Wash Trending Reel', style: TextStyle(fontSize: 11)),
                    onPressed: () => linkController.text = 'https://www.tiktok.com/tag/carwash',
                  ),
                ],
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
              final newUrl = linkController.text.trim();
              if (newUrl.isNotEmpty) {
                state.setTikTokUrl(newUrl);
                state.setTikTokThumbnailUrl(thumbController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('TikTok ad video settings updated successfully!'),
                    backgroundColor: AppColors.statusReady,
                  ),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final tiktokUrl = state.tiktokUrl.isNotEmpty ? state.tiktokUrl : 'https://www.tiktok.com/@bishe_car_wash';
    final thumbnailUrl = state.tiktokThumbnailUrl;

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
          // Header Bar with TikTok Branding & Settings
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
                      'TIKTOK OFFICIAL REEL',
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
                      child: const Text(
                        'TRENDING',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                // Configure TikTok Link Button
                InkWell(
                  onTap: () => _showEditTikTokDialog(context),
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
                        Icon(Icons.edit_rounded, size: 13, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Edit Link',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 16:9 Interactive TikTok Video Card with Play Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: InkWell(
                onTap: () => _launchTikTok(context, tiktokUrl),
                borderRadius: BorderRadius.circular(18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Thumbnail or Aesthetic Gradient
                        if (thumbnailUrl.isNotEmpty)
                          Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholderBackground(),
                          )
                        else
                          _buildPlaceholderBackground(),

                        // Dark Gradient Overlay for Contrast
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),

                        // Center Pulsing TikTok Play Button
                        Center(
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isHovered ? 1.15 : _pulseAnimation.value,
                                child: Container(
                                  width: 68,
                                  height: 68,
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
                                        blurRadius: 20,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Top Badges
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
                                Icon(Icons.visibility_rounded, size: 13, color: Colors.white70),
                                SizedBox(width: 5),
                                Text(
                                  'Tap to Watch in TikTok App',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Music Track Overlay
                        Positioned(
                          bottom: 12,
                          left: 14,
                          right: 14,
                          child: Row(
                            children: [
                              const Icon(Icons.graphic_eq_rounded, size: 16, color: Color(0xFF00F2FE)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '🎵 BISHE Auto Detailing • Official Foam & Ceramic Showcase',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Call-to-Action Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BISHE Detailing on TikTok (@bishe_car_wash)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Watch our high-pressure wash, foam cannon, and polish reels directly on TikTok',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.68),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _launchTikTok(context, tiktokUrl),
                  icon: const Icon(Icons.music_note_rounded, size: 16),
                  label: const Text('Open in TikTok 🎵', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE2C55),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildPlaceholderBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF020617), // Deepest obsidian
            Color(0xFF0F172A), // Slate
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
