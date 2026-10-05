import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/sneaker_theme.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/product_viewer_3d.dart';
import '../widgets/size_selector.dart';
import '../widgets/thumbnail_row.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    this.product = kDummyProduct,
    this.force2DViewer = false,
  });

  final Product product;

  final bool force2DViewer;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _viewerController = ProductViewerController();
  ProductAngle _selectedAngle = ProductAngle.side;
  String? _selectedSize;
  bool _isFavorite = false;

  Product get _product => widget.product;

  @override
  void dispose() {
    _viewerController.dispose();
    super.dispose();
  }

  void _selectAngle(ProductAngle angle) {
    setState(() => _selectedAngle = angle);
    _viewerController.showAngle(angle);
  }

  void _showSnack(String message, {IconData icon = Icons.check_circle}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: kTextDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Hero viewer height scales with the phone but never dominates it.
    final viewerHeight = (media.size.width * 0.78)
        .clamp(220.0, 380.0)
        .clamp(200.0, media.size.height * 0.40);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomActionBar(
        enabled: _selectedSize != null,
        accent: kPrimaryGreen,
        onChat: () => _showSnack(
          'Opening chat with the seller…',
          icon: Icons.sms_outlined,
        ),
        onAddToCart: () => _showSnack(
          'Added ${_product.name} ($_selectedSize) to cart',
          icon: Icons.shopping_cart_checkout_rounded,
        ),
        onBuyNow: () => _showSnack(
          'Buying ${_product.name} ($_selectedSize) · ${_product.formattedPrice}',
          icon: Icons.bolt_rounded,
        ),
        onDisabledTap: () => _showSnack(
          'Please select a size first',
          icon: Icons.info_outline_rounded,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Hero(
              viewerHeight: viewerHeight,
              onBack: () => Navigator.maybePop(context),
              onMenuSelected: (value) =>
                  _showSnack(value, icon: Icons.info_outline_rounded),
              viewer: ProductViewer3D(
                modelUrl: _product.modelUrl,
                fallbackImage: _product.fallbackImage,
                controller: _viewerController,
                forceFallback: widget.force2DViewer,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ThumbnailRow(
                    angles: _product.angles,
                    selected: _selectedAngle,
                    image: _product.fallbackImage,
                    accent: kPrimaryGreen,
                    onSelected: _selectAngle,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _product.name,
                          style: jakarta(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: kTextDark,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _FavoriteButton(
                        isFavorite: _isFavorite,
                        onChanged: (value) {
                          setState(() => _isFavorite = value);
                          _showSnack(
                            value
                                ? 'Saved to favorites'
                                : 'Removed from favorites',
                            icon: value
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _product.formattedPrice,
                    style: jakarta(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(child: Text('${_product.pairsLeft} Pair Left')),
                      _InfoChip(child: Text('Sold ${_product.sold}')),
                      _InfoChip(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _product.rating.toStringAsFixed(1),
                              style: jakarta(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${_product.reviewCount} Reviews)',
                              style: jakarta(color: kTextMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF0F0F0),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Select Size',
                          style: jakarta(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: kTextDark,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            showSizeChartSheet(context, accent: kPrimaryGreen),
                        style: TextButton.styleFrom(
                          foregroundColor: kPrimaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          textStyle: jakarta(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Size chart'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            SizeSelector(
              sizes: _product.sizes,
              selected: _selectedSize,
              accent: kPrimaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              onSelected: (size) => setState(() => _selectedSize = size),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Grey rounded container with the top bar and the 3D viewer.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.viewerHeight,
    required this.viewer,
    required this.onBack,
    required this.onMenuSelected,
  });

  final double viewerHeight;
  final Widget viewer;
  final VoidCallback onBack;
  final ValueChanged<String> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: ColoredBox(
        color: kHeroGrey,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: onBack,
                    ),
                    Expanded(
                      child: Text(
                        'Sneakers Detail',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: jakarta(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: kTextDark,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'More',
                      onSelected: onMenuSelected,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'Link copied to share',
                          child: Text('Share'),
                        ),
                        PopupMenuItem(
                          value: 'Thanks, we will review this listing',
                          child: Text('Report listing'),
                        ),
                      ],
                      child: const _CircleIconButton(
                        icon: Icons.more_vert_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: viewerHeight, child: viewer),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onPressed, this.tooltip});

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Icon(icon, size: 22, color: kTextDark),
    );
    if (onPressed == null) return circle;
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onPressed, child: circle),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: kStroke),
      ),
      child: DefaultTextStyle(
        style: jakarta(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: kTextDark,
        ),
        child: child,
      ),
    );
  }
}

/// Heart that toggles filled/outlined with a small bounce.
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.isFavorite, required this.onChanged});

  final bool isFavorite;
  final ValueChanged<bool> onChanged;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.3), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.92), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.92, end: 1), weight: 30),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _controller.forward(from: 0);
    widget.onChanged(!widget.isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggle,
      tooltip: widget.isFavorite ? 'Remove from favorites' : 'Add to favorites',
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      icon: ScaleTransition(
        scale: _scale,
        child: Icon(
          widget.isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: widget.isFavorite ? const Color(0xFFE5484D) : kTextMuted,
          size: 24,
        ),
      ),
    );
  }
}
