import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/home_bloc.dart';
import '../../widgets/product_card.dart';

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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 20, backgroundColor: AppColors.green50, child: Text('MA', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.green700))),
                    const SizedBox(width: 12),
                    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Xin chào 🌱', style: TextStyle(fontSize: 12, color: AppColors.muted)), Text('Minh Anh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink))]),
                    const Spacer(),
                    Stack(children: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: AppColors.ink)), Positioned(right: 8, top: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.terra, shape: BoxShape.circle)))]),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search, color: AppColors.muted), hintText: 'Tìm cây, chậu, phụ kiện...', fillColor: AppColors.green50)))),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: ['Trong nhà', 'Ngoài trời', 'Sen đá', 'Chậu'].map((c) => Chip(label: Text(c, style: const TextStyle(fontSize: 12)), backgroundColor: AppColors.green50)).toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())));
                }
                if (state is HomeError) {
                  return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(40), child: Center(child: Text(state.message, style: const TextStyle(color: AppColors.terra)))));
                }
                if (state is HomeLoaded) {
                  final products = state.products;
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Không có cây nào'))));
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.7),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => ProductCard(product: products[i], onTap: () => context.push('/product/${products[i].id}')),
                        childCount: products.length,
                      ),
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
}