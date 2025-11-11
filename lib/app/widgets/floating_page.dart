import 'package:flutter/material.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';

class FloatingPage extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final Widget child;
  final EdgeInsets contentPadding;
  final bool scrollable;
  final Future<void> Function()? onRefresh;

  const FloatingPage({
    super.key,
    this.title,
    this.actions,
    this.onBack,
    required this.child,
    this.contentPadding = const EdgeInsets.all(20.0),
    this.scrollable = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final container = _buildContainer(context);
    return SafeArea(
      top: true,
      bottom: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: -20.0,
            child: container,
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(BuildContext context) {
    final header =
        (title != null ||
            (actions != null && actions!.isNotEmpty) ||
            onBack != null)
        ? _FloatingAppBar(title: title, actions: actions, onBack: onBack)
        : const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.alternate.withAlpha((0.15 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: AppColors.alternate.withAlpha((0.1 * 255).round()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null ||
              onBack != null ||
              (actions != null && actions!.isNotEmpty))
            header,
          Expanded(
            child: scrollable
                ? _wrapWithRefresh(
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom:
                            MediaQuery.of(context).padding.bottom +
                            kBottomNavigationBarHeight +
                            24.0,
                      ),
                      child: Padding(padding: contentPadding, child: child),
                    ),
                  )
                : Padding(padding: contentPadding, child: child),
          ),
        ],
      ),
    );
  }

  Widget _wrapWithRefresh(Widget child) {
    if (onRefresh == null) return child;
    return RefreshIndicator(onRefresh: onRefresh!, child: child);
  }
}

class _FloatingAppBar extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const _FloatingAppBar({this.title, this.actions, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.alternate.withAlpha((0.1 * 255).round()),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Kembali',
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          Expanded(
            child: Text(
              title ?? '',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
