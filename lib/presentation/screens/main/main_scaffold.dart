import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/profile/profile_screen.dart';

const double _brandHeroOverlap = 122.0;

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const BrandsScreen(),
      CartScreen(onContinueShopping: _handleContinueShopping),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          final cartCount = cartState.totalItems;
          final cartDisplay = cartCount > 99 ? '99+' : cartCount.toString();
          final cartLabel = cartCount > 0 ? 'Cart ($cartDisplay)' : 'Cart';

          return NavigationBar(
            indicatorColor: AppColors.primaryLight,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome),
                label: 'Brands',
              ),
              NavigationDestination(
                icon: _buildCartIcon(cartCount, false),
                selectedIcon: _buildCartIcon(cartCount, true),
                label: cartLabel,
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleContinueShopping() {
    setState(() => _currentIndex = 0);
  }

  Widget _buildCartIcon(int count, bool isSelected) {
    final baseIcon = Icon(
      isSelected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
      color: isSelected ? AppColors.primary : null,
    );

    if (count == 0) {
      return baseIcon;
    }

    final display = count > 99 ? '99+' : count.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        baseIcon,
        Positioned(
          right: -10,
          top: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: const BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Text(
              display,
              style: TextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  static const List<_Brand> _brands = [
    _Brand(
      name: 'Glow Atelier',
      tagline: 'Hydrate. Brighten. Glow.',
      description:
          'Advanced hydration rituals boosted with vitamin-rich complexes for dawn-to-dusk luminosity.',
      featuredProduct: 'Vitamin C Radiance Serum',
      colors: [Color(0xFFFFEBF2), Color(0xFFF8BBD0)],
      focusAreas: ['Serums', 'Moisturizers', 'Sheet Masks'],
    ),
    _Brand(
      name: 'Pure Botanics',
      tagline: 'Botanical care for calm, balanced skin.',
      description:
          'Cold-pressed plant extracts blended with adaptogens to strengthen the skin barrier naturally.',
      featuredProduct: 'Reishi Calming Elixir',
      colors: [Color(0xFFE3FCEC), Color(0xFFC5F3D3)],
      focusAreas: ['Cleansers', 'Oils', 'Essences'],
    ),
    _Brand(
      name: 'Luxe Pigments',
      tagline: 'Editorial colour payoff with skincare benefits.',
      description:
          'Velvet formulas infused with squalane for breathable, long-wear pigment that treats while it glamours.',
      featuredProduct: 'Satin Veil Lip Cloud',
      colors: [Color(0xFFF1E4FF), Color(0xFFDCC3FF)],
      focusAreas: ['Lip', 'Eye', 'Face'],
    ),
    _Brand(
      name: 'Auric Rituals',
      tagline: 'Elevated self-care for night-time renewal.',
      description:
          'Aromatherapeutic blends, silk textures and slow-beauty tools designed to replenish skin and spirit.',
      featuredProduct: 'Celestial Renewal Night Balm',
      colors: [Color(0xFFE8F2FF), Color(0xFFC7DCF9)],
      focusAreas: ['Treatments', 'Tools', 'Body'],
    ),
  ];

  static const List<_BrandStory> _stories = [
    _BrandStory(
      title: 'The Glow Atelier Morning Ritual',
      summary:
          'Layer lightweight hydrators and vitamin shots for a glass-skin finish that lasts through city commutes.',
      brands: ['Glow Atelier'],
    ),
    _BrandStory(
      title: 'Botanical Reset for Sensitive Skin',
      summary:
          'Soothe flare-ups in three steps with Pure Botanics adaptogenic duo and a humidity-friendly essence mist.',
      brands: ['Pure Botanics'],
    ),
    _BrandStory(
      title: 'Chromatic Confidence with Luxe Pigments',
      summary:
          'Build statement looks that still nourish using the pigment-care palettes crafted for diverse undertones.',
      brands: ['Luxe Pigments', 'Auric Rituals'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.getResponsiveValue(
      context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
    );
    final maxWidth = Responsive.getMaxContentWidth(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BrandHeroSection(
              horizontalPadding: horizontalPadding,
              featuredBrand: _brands.first,
            ),
            const SizedBox(height:60),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: _brandHeroOverlap + 16),
                      Text(
                        'Shop by Brand',
                        style: TextStyles.h3.copyWith(
                          fontSize: TextStyles.h3.fontSize! + 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Curated collections from the beauty labels loved by our community.',
                        style: TextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _BrandsGrid(brands: _brands),
                      const SizedBox(height: 32),
                      Text('Beauty Journals', style: TextStyles.h4),
                      const SizedBox(height: 12),
                      _BrandStories(stories: _stories),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHeroSection extends StatelessWidget {
  const _BrandHeroSection({
    required this.horizontalPadding,
    required this.featuredBrand,
  });

  final double horizontalPadding;
  final _Brand featuredBrand;

  @override
  Widget build(BuildContext context) {
    final heroHeight = Responsive.getResponsiveValue(
      context,
      mobile: 240.0,
      tablet: 280.0,
      desktop: 320.0,
    );

    return SizedBox(
      height: heroHeight + _brandHeroOverlap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: heroHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              32,
              horizontalPadding,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover Our Brands',
                  style: TextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Experience thoughtfully crafted collections, exclusive drops and beauty rituals by experts.',
                  style: TextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            left: horizontalPadding,
            right: horizontalPadding,
            top: heroHeight - _brandHeroOverlap,
            child: _FeaturedBrandCard(brand: featuredBrand),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBrandCard extends StatelessWidget {
  const _FeaturedBrandCard({required this.brand});

  final _Brand brand;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: brand.colors.first,
                  child: Text(
                    brand.name.substring(0, 1),
                    style: TextStyles.h3.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(brand.name, style: TextStyles.h4),
                      const SizedBox(height: 4),
                      Text(
                        brand.tagline,
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(brand.description, style: TextStyles.bodyMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: brand.focusAreas
                  .map(
                    (focus) => Chip(
                      backgroundColor: AppColors.accentLight,
                      label: Text(
                        focus,
                        style: TextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hero Pick',
                  style: TextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  brand.featuredProduct,
                  style: TextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_outward_rounded),
                      label: const Text('View Collection'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandsGrid extends StatelessWidget {
  const _BrandsGrid({required this.brands});

  final List<_Brand> brands;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = Responsive.isDesktop(context)
        ? 3
        : Responsive.isTablet(context)
        ? 2
        : 1;

    return GridView.builder(
      itemCount: brands.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: Responsive.getResponsiveValue(
          context,
          mobile: 1.1,
          tablet: 1.2,
          desktop: 1.35,
        ),
      ),
      itemBuilder: (context, index) => _BrandCard(brand: brands[index]),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.brand});

  final _Brand brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: brand.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              brand.name.substring(0, 1),
              style: TextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            brand.name,
            style: TextStyles.h5,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            brand.tagline,
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: brand.focusAreas
                .map(
                  (focus) => Chip(
                    label: Text(
                      focus,
                      style: TextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                brand.featuredProduct,
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandStories extends StatelessWidget {
  const _BrandStories({required this.stories});

  final List<_BrandStory> stories;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stories
          .map(
            (story) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(story.title, style: TextStyles.h5),
                  const SizedBox(height: 8),
                  Text(
                    story.summary,
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: story.brands
                        .map(
                          (brand) => Chip(
                            label: Text(brand),
                            backgroundColor: AppColors.primaryLight,
                            labelStyle: TextStyles.labelMedium.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Brand {
  const _Brand({
    required this.name,
    required this.tagline,
    required this.description,
    required this.featuredProduct,
    required this.colors,
    required this.focusAreas,
  });

  final String name;
  final String tagline;
  final String description;
  final String featuredProduct;
  final List<Color> colors;
  final List<String> focusAreas;
}

class _BrandStory {
  const _BrandStory({
    required this.title,
    required this.summary,
    required this.brands,
  });

  final String title;
  final String summary;
  final List<String> brands;
}
