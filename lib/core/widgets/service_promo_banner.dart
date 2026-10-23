import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';

class ServicePromoBanner extends StatefulWidget {
  final VoidCallback? onBookTap;

  const ServicePromoBanner({super.key, this.onBookTap});

  @override
  State<ServicePromoBanner> createState() => _ServicePromoBannerState();
}

class _ServicePromoBannerState extends State<ServicePromoBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<_PromoItem> _promos = const [
    _PromoItem(
      title: 'Touchless Snow Foam & Wax',
      subtitle: 'Premier deep exterior care near Lake Bishoftu',
      badge: 'TOP RATED',
      icon: Icons.auto_awesome_rounded,
      gradient: [Color(0xFF007791), Color(0xFF0284C7)],
    ),
    _PromoItem(
      title: 'Doorstep Mobile Van Service',
      subtitle: 'We bring deionized water & silent power to your home',
      badge: 'AT-HOME CONVENIENCE',
      icon: Icons.rv_hookup_rounded,
      gradient: [Color(0xFF0E7490), Color(0xFF047857)],
    ),
    _PromoItem(
      title: 'Fast 25-Min Turnaround',
      subtitle: 'Dual bays with dedicated 2-washer teams per car',
      badge: 'EXPRESS QUEUE',
      icon: Icons.speed_rounded,
      gradient: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _promos.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: _promos.length,
            itemBuilder: (context, index) {
              final promo = _promos[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: promo.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: promo.gradient.first.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                promo.badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              promo.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              promo.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(promo.icon, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_promos.length, (index) {
            final isSelected = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              width: isSelected ? 20 : 6,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.cardBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PromoItem {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final List<Color> gradient;

  const _PromoItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.gradient,
  });
}
