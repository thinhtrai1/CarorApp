import 'dart:math';

import 'package:caror/data/data_service.dart';
import 'package:caror/data/shared_preferences.dart';
import 'package:caror/entity/product.dart';
import 'package:caror/resources/generated/l10n.dart';
import 'package:caror/resources/number.dart';
import 'package:caror/resources/theme.dart';
import 'package:caror/resources/util.dart';
import 'package:caror/widget/shimmer_loading.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CartTab extends StatefulWidget {
  const CartTab({Key? key}) : super(key: key);

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final _ids = AppPreferences.getCart().map(int.parse).toList();
  final _products = <Product>[];
  final _scrollController = ScrollController();
  final _listKey = GlobalKey<SliverAnimatedListState>();
  var _isInitial = true;
  late final _statusBarHeight = Number.getStatusBarHeight(context);
  final _inAppPurchase = InAppPurchase.instance;
  ProductDetails? _productDetails;

  @override
  void initState() {
    _getProducts();
    _initStoreInfo();
    super.initState();
  }

  Future<void> _initStoreInfo() async {
    final response = await _inAppPurchase.queryProductDetails({
      'test_product',
    });
    if (response.error != null) {
      Util.log(response.error.toString(), error: true);
      return;
    }

    _productDetails = response.productDetails.first;
  }

  _getProducts() {
    if (_ids.isEmpty) {
      setState(() {
        _isInitial = false;
      });
      return;
    }
    DataService.getProductsByIds(0, _ids.toSet().toList()).then((response) {
      if (response != null) {
        _products.addAll(response.data.map((e) => e..qty = _ids.where((id) => id == e.id).length));
      }
      setState(() {
        _isInitial = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final subtotal = _products.fold<int>(0, (prev, product) => prev + product.price * product.qty);
    final tax = subtotal * 0.1;
    final shipping = subtotal > 0 ? 75000 : 0;
    final total = subtotal + tax + shipping;
    return LayoutBuilder(
      builder: (context, constraints) {
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
                      S.current.orders_num_item(_products.length),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            _products.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      height: constraints.maxHeight - 480,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Image(
                            width: 100,
                            height: 100,
                            image: AssetImage('assets/app_icon.png'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            S.current.cart_is_empty,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildCartListView(),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
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
                    Text(
                      S.current.summary,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          S.current.subtotal,
                          style: const TextStyle(
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
                        Text(
                          S.current.tax,
                          style: const TextStyle(
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
                        Text(
                          S.current.shipping_handling,
                          style: const TextStyle(
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
                        Text(
                          S.current.total,
                          style: const TextStyle(
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
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 64, vertical: 12)),
                        ),
                        child: Text(
                          S.current.checkout,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          if (_productDetails == null) {
                            showToast(S.current.in_app_purchase_not_available);
                            return;
                          }
                          _inAppPurchase.buyConsumable(
                            purchaseParam: PurchaseParam(productDetails: _productDetails!),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
        AppPreferences.addToCart(product.id, -product.qty);
      },
      key: Key(product.id.toString()),
      background: const Row(
        children: [
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
                      MaterialIconButton(Icons.delete_rounded, padding: 8, onPressed: () {
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
                        AppPreferences.addToCart(product.id, -product.qty);
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
                      MaterialIconButton(
                        Icons.remove_circle_outline_rounded,
                        padding: 8,
                        onPressed: () {
                          AppPreferences.addToCart(product.id, -1);
                          if (product.qty > 0) setState(() => product.qty -= 1);
                        },
                      ),
                      Text(
                        product.qty.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      MaterialIconButton(
                        Icons.add_circle_outline_rounded,
                        padding: 8,
                        onPressed: () {
                          AppPreferences.addToCart(product.id, 1);
                          setState(() => product.qty += 1);
                        },
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
            ...List.generate(_ids.toSet().length, (index) => _buildShimmerItem()),
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
