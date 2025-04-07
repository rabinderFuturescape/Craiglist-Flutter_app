import 'package:flutter/material.dart';

/// A responsive grid layout that adjusts the number of columns based on screen width
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsets padding;
  final int minCrossAxisCount;
  final int maxCrossAxisCount;
  final double minCrossAxisExtent;
  final double childAspectRatio;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.minCrossAxisCount = 1,
    this.maxCrossAxisCount = 4,
    this.minCrossAxisExtent = 150.0,
    this.childAspectRatio = 0.75,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the number of columns based on the available width
        final width = constraints.maxWidth;
        final crossAxisCount = _calculateCrossAxisCount(width);

        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    // Calculate how many items can fit based on the minimum extent
    int count = (width / minCrossAxisExtent).floor();
    
    // Ensure we're within the min/max range
    count = count.clamp(minCrossAxisCount, maxCrossAxisCount);
    
    return count;
  }
}
