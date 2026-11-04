import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';

/// A modern, colorful expandable card designed for mobile-first views.
/// Allows bulky screen sections to be collapsed or expanded with smooth animations,
/// vibrant gradient headers, and clear visual hierarchy.
class ModernExpandableCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final String? badgeText;
  final Color? badgeColor;
  final Widget child;
  final bool initiallyExpanded;
  final Widget? headerAction;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ModernExpandableCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.gradientColors = const [AppColors.primary, AppColors.secondary],
    this.badgeText,
    this.badgeColor,
    required this.child,
    this.initiallyExpanded = false,
    this.headerAction,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 14),
  });

  @override
  State<ModernExpandableCard> createState() => _ModernExpandableCardState();
}

class _ModernExpandableCardState extends State<ModernExpandableCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _iconTurns = _controller.drive(
      Tween<double>(begin: 0.0, end: 0.5).chain(
        CurveTween(curve: Curves.easeInOutCubic),
      ),
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.gradientColors.first.withValues(alpha: _isExpanded ? 0.40 : 0.22),
          width: _isExpanded ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors.first.withValues(alpha: _isExpanded ? 0.10 : 0.05),
            blurRadius: _isExpanded ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Always visible, tap to expand/collapse)
          InkWell(
            onTap: _toggleExpand,
            splashColor: widget.gradientColors.first.withValues(alpha: 0.1),
            highlightColor: widget.gradientColors.first.withValues(alpha: 0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: widget.gradientColors.first.withValues(alpha: _isExpanded ? 0.07 : 0.025),
                border: Border(
                  bottom: BorderSide(
                    color: _isExpanded
                        ? widget.gradientColors.first.withValues(alpha: 0.2)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Gradient Icon Container
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: widget.gradientColors.first.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (widget.badgeText != null) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (widget.badgeColor ?? widget.gradientColors.first)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: (widget.badgeColor ?? widget.gradientColors.first)
                                          .withValues(alpha: 0.25),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    widget.badgeText!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: widget.badgeColor ?? widget.gradientColors.first,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (widget.headerAction != null) ...[
                    widget.headerAction!,
                    const SizedBox(width: 6),
                  ],

                  // Animated Chevron
                  RotationTransition(
                    turns: _iconTurns,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.expand_more_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated Expandable Content Body
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }
}
