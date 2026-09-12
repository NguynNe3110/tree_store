import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url.dart';
import '../../../data/remote/models/responses/home_response.dart';
import '../../blocs/home_bloc.dart';
import '../../blocs/profile_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Fixed header (not SDUI)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    final user = state is ProfileLoaded ? state.user : (state is ProfileUpdated ? state.user : null);
                    final name = user?.fullName ?? '...';
                    final parts = name.trim().split(' ');
                    final initials = parts.isNotEmpty && parts.first.isNotEmpty ? (parts.length > 1 ? '${parts.first[0]}${parts.last[0]}'.toUpperCase() : parts.first[0].toUpperCase()) : '?';
                    return Row(
                      children: [
                        CircleAvatar(radius: 20, backgroundColor: AppColors.green50, child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.green700))),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Xin chào 🌱', style: TextStyle(fontSize: 12, color: AppColors.muted)), Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink))]),
                        const Spacer(),
                        Stack(children: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: AppColors.ink)), Positioned(right: 8, top: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.terra, shape: BoxShape.circle)))]),
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search, color: AppColors.muted), hintText: 'Tìm cây, chậu, phụ kiện...', fillColor: AppColors.green50, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))))),

            // SDUI blocks
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())));
                }
                if (state is HomeError) {
                  return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(40), child: Center(child: Text(state.message, style: const TextStyle(color: AppColors.terra)))));
                }
                if (state is HomeLoaded) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildBlock(state.blocks[i]),
                      childCount: state.blocks.length,
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(UiBlockResponse block) {
    switch (block.blockType) {
      case 'banner_carousel':
        return _BannerCarousel(block);
      case 'quick_actions':
        return _QuickActions(block);
      case 'flash_sale_strip':
        return _FlashSaleStrip(block);
      case 'category_tabs':
        return _CategoryTabs(block);
      case 'product_horizontal_list':
        return _ProductHorizontalList(block);
      case 'featured_hero':
        return _FeaturedHero(block);
      case 'care_tip_card':
        return _CareTipCard(block);
      case 'bundle_offer':
        return _BundleOffer(block);
      case 'testimonial':
        return _Testimonial(block);
      case 'product_grid':
        return _ProductGrid(block);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ponytail: minimal SDUI widgets matching HTML mockup structure. upgrade to dedicated widget files when sections grow complex

class _BannerCarousel extends StatelessWidget {
  final UiBlockResponse block;
  const _BannerCarousel(this.block);

  @override
  Widget build(BuildContext context) {
    final banners = (block.payload['banners'] as List<dynamic>?) ?? [];
    if (banners.isEmpty) return const SizedBox.shrink();
    final b = banners.first as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.green700, AppColors.green600]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (b['tag'] != null)
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)), child: Text(b['tag'], style: const TextStyle(fontSize: 10, color: Colors.white, fontFamily: 'monospace'))),
            Text(b['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 2),
            Text(b['subtitle'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white70)),
            if (b['cta'] != null)
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(b['cta'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.green700))),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final UiBlockResponse block;
  const _QuickActions(this.block);

  @override
  Widget build(BuildContext context) {
    final items = (block.payload['items'] as List<dynamic>?) ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: items.map((item) {
          final m = item as Map<String, dynamic>;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line2)),
                child: Column(
                  children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(m['icon'] ?? '', style: const TextStyle(fontSize: 20)))),
                    const SizedBox(height: 6),
                    Text(m['label'] ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.ink2), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FlashSaleStrip extends StatelessWidget {
  final UiBlockResponse block;
  const _FlashSaleStrip(this.block);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFDE8D0), Color(0xFFFEF3E2)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF5D0A9)),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(block.payload['title'] ?? 'Flash Sale', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.terra)),
              Text(block.payload['subtitle'] ?? '', style: const TextStyle(fontSize: 10, color: AppColors.ink2)),
            ]),
            const Spacer(),
            Row(children: [
              _clockBox(block.payload['hours']),
              _clockBox(block.payload['minutes']),
              _clockBox(block.payload['seconds']),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _clockBox(dynamic val) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3), decoration: BoxDecoration(color: AppColors.terra, borderRadius: BorderRadius.circular(4)), child: Text('${val ?? 0}'.padLeft(2, '0'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'monospace'))),
      );
}

class _CategoryTabs extends StatelessWidget {
  final UiBlockResponse block;
  const _CategoryTabs(this.block);

  @override
  Widget build(BuildContext context) {
    final cats = (block.payload['categories'] as List<dynamic>?) ?? [];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
            label: Text(cats[i] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: i == 0 ? Colors.white : AppColors.ink2)),
            backgroundColor: i == 0 ? AppColors.green700 : Colors.white,
            side: BorderSide(color: i == 0 ? AppColors.green700 : AppColors.line2),
          ),
        ),
      ),
    );
  }
}

class _ProductHorizontalList extends StatelessWidget {
  final UiBlockResponse block;
  const _ProductHorizontalList(this.block);

  @override
  Widget build(BuildContext context) {
    final products = (block.payload['products'] as List<dynamic>?) ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(children: [
            Text(block.title ?? 'Sản phẩm', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const Spacer(),
            const Text('Xem tất cả →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.green700)),
          ]),
        ),
        if (products.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Chưa có sản phẩm', style: TextStyle(fontSize: 13, color: AppColors.muted)))
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i] as Map<String, dynamic>;
                final imgUrl = resolveImageUrl(p['imageUrl'] as String?);
                return GestureDetector(
                  onTap: () => context.push('/product/${p['id']}'),
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: imgUrl.isEmpty
                                ? Container(color: AppColors.green50, child: const Center(child: Icon(Icons.local_florist, color: AppColors.green700, size: 32)))
                                : Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.green50, child: const Center(child: Icon(Icons.local_florist, color: AppColors.green700, size: 32)))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(p['price'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.green700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FeaturedHero extends StatelessWidget {
  final UiBlockResponse block;
  const _FeaturedHero(this.block);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 140, decoration: const BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.vertical(top: Radius.circular(20))), child: const Center(child: Icon(Icons.park, size: 48, color: AppColors.green700))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(block.payload['label'] ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.terra, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  Text(block.payload['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(block.payload['desc'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(block.payload['price'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.green700)),
                      const Spacer(),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: AppColors.green700, borderRadius: BorderRadius.circular(12)), child: const Text('Xem chi tiết', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareTipCard extends StatelessWidget {
  final UiBlockResponse block;
  const _CareTipCard(this.block);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC8E6C9)),
        ),
        child: Row(
          children: [
            Text(block.payload['icon'] ?? '💧', style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(block.payload['title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(block.payload['subtitle'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.ink2)),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.green700),
          ],
        ),
      ),
    );
  }
}

class _BundleOffer extends StatelessWidget {
  final UiBlockResponse block;
  const _BundleOffer(this.block);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF2D4A3E), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(block.payload['title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              Text(block.payload['subtitle'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ])),
            if (block.payload['discount'] != null)
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(block.payload['discount'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2D4A3E)))),
          ],
        ),
      ),
    );
  }
}

class _Testimonial extends StatelessWidget {
  final UiBlockResponse block;
  const _Testimonial(this.block);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text('"${block.payload['quote'] ?? ''}"', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.5)),
            const SizedBox(height: 8),
            Text(block.payload['author'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final UiBlockResponse block;
  const _ProductGrid(this.block);

  @override
  Widget build(BuildContext context) {
    final products = (block.payload['products'] as List<dynamic>?) ?? [];
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title != null)
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: Text(block.title!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.7),
            itemCount: products.length,
            itemBuilder: (_, i) {
              final p = products[i] as Map<String, dynamic>;
              final imgUrl = resolveImageUrl(p['imageUrl'] as String?);
              return GestureDetector(
                onTap: () => context.push('/product/${p['id']}'),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: imgUrl.isEmpty
                              ? Container(color: AppColors.green50, child: const Center(child: Icon(Icons.local_florist, color: AppColors.green700, size: 32)))
                              : Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.green50, child: const Center(child: Icon(Icons.local_florist, color: AppColors.green700, size: 32)))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(p['sub'] ?? '', style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                            const SizedBox(height: 8),
                            Row(children: [
                              Text(p['price'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.green700)),
                              const Spacer(),
                              Container(width: 26, height: 26, decoration: BoxDecoration(color: AppColors.green700, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, color: Colors.white, size: 16)),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}