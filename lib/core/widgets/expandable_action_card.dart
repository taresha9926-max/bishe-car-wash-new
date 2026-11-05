import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Modern, colorful, mobile-first Expandable Action Card.
/// Minimizes crowded screens into clean, clickable action cards that expand
/// on demand to reveal full details and controls.
class ExpandableActionCard extends StatefulWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final Widget? badge;
  final Widget child;
  final bool initiallyExpanded;
  final Color? borderColor;
  final Color? headerColor;
  final Color? iconBackgroundColor;
  final EdgeInsetsGeometry? iconPadding;
  final List<Color>? backgroundGradient;
  final ValueChanged<bool>? onExpansionChanged;

  const ExpandableActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    required this.child,
    this.initiallyExpanded = false,
    this.borderColor,
    this.headerColor,
    this.iconBackgroundColor,
    this.iconPadding,
    this.backgroundGradient,
    this.onExpansionChanged,
  });

  @override
  State<ExpandableActionCard> createState() => _ExpandableActionCardState();
}

class _ExpandableActionCardState extends State<ExpandableActionCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant ExpandableActionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded &&
        widget.initiallyExpanded != _isExpanded) {
      _toggleExpansion();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = widget.borderColor ?? AppColors.cardBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? (widget.borderColor ?? AppColors.primary).withOpacity(0.55)
              : effectiveBorderColor,
          width: _isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isExpanded
                    ? (widget.borderColor ?? AppColors.primary)
                    : Colors.black)
                .withOpacity(_isExpanded ? 0.08 : 0.025),
            blurRadius: _isExpanded ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clickable Header Button
            Material(
              color: widget.headerColor ?? Colors.transparent,
              child: InkWell(
                onTap: _toggleExpansion,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Vibrant Leading Icon
                      Container(
                        padding: widget.iconPadding ?? const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: widget.iconBackgroundColor ??
                              AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: widget.icon,
                      ),
                      const SizedBox(width: 12),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (widget.subtitle != null &&
                                widget.subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Trailing Badge (if provided)
                      if (widget.badge != null) ...[
                        widget.badge!,
                        const SizedBox(width: 8),
                      ],

                      // Smooth Animated Rotating Chevron
                      RotationTransition(
                        turns: _iconTurns,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _isExpanded
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: _isExpanded
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animated Expandable Content Body
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1, color: AppColors.cardBorder),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: widget.child,
                  ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    );
  }
}
