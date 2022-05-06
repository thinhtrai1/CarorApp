import 'dart:math';

import 'package:caror/generated/l10n.dart';
import 'package:caror/ui/image/image.dart';
import 'package:caror/ui/product_detail/product_detail.dart';
import 'package:flutter/material.dart';

import '../../data/data_service.dart';
import '../../entity/product.dart';
import '../../themes/number.dart';
import '../../themes/theme.dart';
import '../../widget/shimmer_loading.dart';
import '../../widget/widget.dart';

class UniverseTab extends StatefulWidget {
  const UniverseTab({Key? key}) : super(key: key);

  @override
  State<UniverseTab> createState() => _UniverseTabState();
}

class _UniverseTabState extends State<UniverseTab> with SingleTickerProviderStateMixin {
  var _isInitial = true;
  var _currentPage = 0;
  var _isLoadMore = false;
  late final _statusBarHeight = Number.getStatusBarHeight(context);
  final _products = List<Product>.empty(growable: true);
  final _shortController = ScrollController();
  late final _refreshIconController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this)
    ..repeat();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      linearGradient: Shimmer.shimmerGradient,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: _statusBarHeight + 8),
            sliver: _isInitial
                ? null
                : CommonSliverRefreshControl(_refreshIconController, onRefresh: () async {
              _getProducts(true);
            }),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      S.current.shorts,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    const Spacer(),
                    Text(
                      S.current.view_all,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 8),
                _buildShortListView(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      S.current.whats_new,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    const Spacer(),
                    Text(
                      S.current.view_all,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
          _buildPostsListView(),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _getProducts(true);
    _shortController.addListener(() {
      if (_isLoadMore && _shortController.position.extentAfter < 600) {
        _isLoadMore = false;
        _getProducts(false);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _shortController.dispose();
    _refreshIconController.dispose();
    super.dispose();
  }

  _getProducts(bool isFirstPage) {
    final page = isFirstPage ? 0 : _currentPage + 1;
    DataService.getProducts(page).then((response) {
      if (response != null) {
        _currentPage = page;
        _isLoadMore = response.isLoadMore;
        if (isFirstPage) {
          _products.clear();
        }
        setState(() {
          _products.addAll(response.data);
        });
      }
      _isInitial = false;
    });
  }

  int _getItemCount() => _products.length + (_isInitial || _isLoadMore ? shimmerItemCount : 0);

  bool _isShimmerIndex(int index) => index > _products.length - 1;

  Widget _buildShortListView() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        controller: _shortController,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: _getItemCount(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return ShimmerLoading(
            isLoading: _isShimmerIndex(index),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(left: 8, right: 8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: colorShimmer,
              ),
              child: _isShimmerIndex(index)
                  ? null
                  : _ShortItem(product: _products[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostsListView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return _isShimmerIndex(index) ? _ShimmerItem() : _PostsItem(product: _products[index]);
        },
        childCount: _isInitial ? shimmerItemCount : _products.length,
      ),
    );
  }
}

class _ShortItem extends StatelessWidget {
  const _ShortItem({required this.product}) : super();
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned(
            child: CommonWidget.image(
              product.thumbnail,
              fit: BoxFit.cover,
            ),
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
          ),
          Positioned(
            top: 8,
            left: 8,
            child: CircleAvatar(
              backgroundColor: colorShimmer,
              radius: 20,
              child: CircleAvatar(
                backgroundImage: NetworkImage(DataService.getFullUrl(product.thumbnail)),
                radius: 16,
              ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Text(
              product.shopName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ShimmerItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: colorShadow,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: colorShimmer,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: colorShimmer,
                      ),
                      width: 150,
                      height: 16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: colorShimmer,
                      ),
                      width: 100,
                      height: 12,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: colorShimmer,
              ),
              width: double.infinity,
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: colorShimmer,
              ),
              width: double.infinity,
              height: 20,
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: colorShimmer,
              ),
              width: double.infinity,
              height: 200,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: colorShimmer,
                  ),
                  width: 100,
                  height: 24,
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: colorShimmer,
                  ),
                  width: 100,
                  height: 24,
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: colorShimmer,
                  ),
                  width: 100,
                  height: 24,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _PostsItem extends StatelessWidget {
  const _PostsItem({required this.product}) : super();

  final Product product;

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: colorShadow,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorShimmer,
                backgroundImage: NetworkImage(DataService.getFullUrl(product.thumbnail)),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.shopName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(product.addedAt)),
                        style: const TextStyle(
                          fontSize: 12,
                          color: colorLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.public,
                        size: 16,
                        color: colorLight,
                      )
                    ],
                  )
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _ContentImage(product: product),
          const SizedBox(height: 16),
          Row(
            children: [
              const SelectionPopupIcon(Icons.thumb_up_alt_rounded, padding: 8),
              Text(
                random.nextInt(10000).toString(),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              const Icon(Icons.comment_rounded),
              const SizedBox(width: 8),
              Text(
                S.current.comments(random.nextInt(1000)),
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.share_rounded),
              const SizedBox(width: 8),
              Text(
                S.current.share,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ContentImage extends StatelessWidget {
  const _ContentImage({required this.product}) : super();
  final Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(createAnimateRoute(context, ImagePage(data: product.image)));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CommonWidget.image(
          product.image,
          fit: BoxFit.fitWidth,
          shimmerHeight: 200,
        ),
      ),
    );
  }
}
