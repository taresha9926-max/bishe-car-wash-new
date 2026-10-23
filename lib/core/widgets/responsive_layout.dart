import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double maxContentWidth;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.maxContentWidth = 1100,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 650 && MediaQuery.sizeOf(context).width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget content;
        if (constraints.maxWidth >= 1024) {
          content = desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 650) {
          content = tablet ?? mobile;
        } else {
          content = mobile;
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: content,
          ),
        );
      },
    );
  }
}
