import 'dart:math';

import 'package:caror/data/data_service.dart';
import 'package:caror/entity/Product.dart';
import 'package:caror/themes/number.dart';
import 'package:caror/themes/theme.dart';
import 'package:caror/widget/shimmer_loading.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';

class CartTab extends StatefulWidget {
  const CartTab({Key? key}) : super(key: key);

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final _products = List<Product>.empty(growable: true);
  final _scrollController = ScrollController();
  final _listKey = GlobalKey<SliverAnimatedListState>();
  var _isInitial = true;
  late final _statusBarHeight = Number.getStatusBarHeight(context);

  @override
  void initState() {
    _getProducts();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getProducts() {
    DataService.getProducts(0).then((response) {
      if (response != null) {
        final random = Random();
        final start = random.nextInt(response.data.length ~/ 2);
        final end = start + random.nextInt(response.data.length - start);
        _products.addAll(response.data.sublist(start, end + 1));
      }
      setState(() {
        _isInitial = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isInitial
        ? Shimmer(
            linearGradient: Shimmer.shimmerGradient,
            child: _buildShimmer(),
          )
        : _buildContent();
  }

  Widget _buildContent() {
    final subtotal = _products.isEmpty ? 0 : _products.map((e) => e.price * e.qty).reduce((a, b) => a + b);
    final tax = subtotal * 0.1;
    final shipping = subtotal > 0 ? 75000 : 0;
    final total = subtotal + tax + shipping;
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _statusBarHeight + 32),
                Text(
                  'Orders (${_products.length} items)',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        if (_products.isNotEmpty) _buildCartListView(),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: colorShadow,
                  offset: Offset(0, -8),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      Number.priceFormat(subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Tax',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      Number.priceFormat(tax),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Shipping & Handling',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      Number.priceFormat(shipping),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      Number.priceFormat(total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 64, vertical: 12)),
                    ),
                    child: const Text(
                      "Checkout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartListView() {
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _products.length,
      itemBuilder: (_, index, animation) {
        return _buildCartItem(index, _products[index]);
      },
    );
  }

  Widget _buildCartItem(int index, Product product) {
    return Dismissible(
      onDismissed: (_) {
        _products.removeAt(index);
        _listKey.currentState!.removeItem(index, (_, animation) => const SizedBox());
        setState(() {});
      },
      key: Key(product.id.toString()),
      background: Row(
        children: const [
          SizedBox(width: 40),
          Icon(Icons.arrow_forward_rounded),
          Icon(Icons.delete_rounded),
          Spacer(),
          Icon(Icons.delete_rounded),
          Icon(Icons.arrow_back_rounded),
          SizedBox(width: 40),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CommonWidget.image(
                product.thumbnail,
                width: 120,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name.split(' - ')[0],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.shopName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: colorLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CommonIcon(Icons.delete_rounded, padding: 8, onPressed: () {
                        _products.removeAt(index);
                        _listKey.currentState!.removeItem(
                          index,
                          (_, animation) => FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              child: _buildCartItem(index, product),
                            ),
                          ),
                          duration: const Duration(milliseconds: 200),
                        );
                        setState(() {});
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        Number.priceFormat(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      CommonIcon(Icons.remove_circle_outline_rounded, padding: 8, onPressed: () {
                        if (product.qty > 0) setState(() => product.qty -= 1);
                      }),
                      Text(
                        product.qty.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      CommonIcon(
                        Icons.add_circle_outline_rounded,
                        padding: 8,
                        onPressed: () => setState(() => product.qty += 1),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: _statusBarHeight + 32),
            Container(
              width: 160,
              height: 32,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: colorShimmer,
              ),
            ),
            const SizedBox(height: 16),
            _buildShimmerItem(),
            _buildShimmerItem(),
            _buildShimmerItem(),
            const SizedBox(height: 48),
            Container(
              width: 160,
              height: 32,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: colorShimmer,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 24,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: colorShimmer,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 24,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: colorShimmer,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  width: 120,
                  height: 32,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: colorShimmer,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 120,
                  height: 32,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: colorShimmer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 100,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              color: colorShimmer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 160,
                height: 16,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: colorShimmer,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 16,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: colorShimmer,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 120,
                height: 20,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: colorShimmer,
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
