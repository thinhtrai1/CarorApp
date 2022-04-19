import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/data_service.dart';
import '../../entity/Product.dart';
import '../../themes/number.dart';
import '../../themes/theme.dart';
import '../../widget/shimmer_loading.dart';
import '../../widget/widget.dart';

class ForumTab extends StatefulWidget {
  const ForumTab({Key? key}) : super(key: key);

  @override
  State<ForumTab> createState() => _ForumTabState();
}

class _ForumTabState extends State<ForumTab> with SingleTickerProviderStateMixin {
  var _isInitial = true;
  var _currentPage = 0;
  var _isLoadMore = false;
  late final _statusBarHeight = Number.getStatusBarHeight(context);
  final _products = List<Product>.empty(growable: true);
  final _shortController = ScrollController();
  final _scrollController = ScrollController();
  late final _refreshIconController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this)..repeat();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      linearGradient: Shimmer.shimmerGradient,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          //TODO #HOWTO: Add Widget above CommonSliverRefreshControl
          if (!_isInitial)
            CommonSliverRefreshControl(_refreshIconController, onRefresh: () async {
              _getProducts(true);
            }),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _statusBarHeight + 16),
                Row(
                  children: const [
                    SizedBox(width: 16),
                    Text(
                      'Shorts',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    Spacer(),
                    Text(
                      'View all',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 8),
                _buildShortListView(),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    SizedBox(width: 16),
                    Text(
                      'What\'s New',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    Spacer(),
                    Text(
                      'View all',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
          _buildPostsListView(),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
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
    _scrollController.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned(
                            child: CommonWidget.image(
                              _products[index].thumbnail,
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
                                backgroundImage: NetworkImage(DataService.getFullUrl(_products[index].thumbnail)),
                                radius: 16,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 8,
                            child: Text(
                              _products[index].shopName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
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
          return _isShimmerIndex(index) ? _buildPostsShimmerItem() : _buildPostsItem(_products[index]);
        },
        childCount: _getItemCount(),
      ),
    );
  }

  Widget _buildPostsShimmerItem() {
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

  Widget _buildPostsItem(Product product) {
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
                      color: colorDark,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CommonWidget.image(
              product.image,
              fit: BoxFit.fitWidth,
              shimmerHeight: 200,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_rounded),
              const SizedBox(width: 8),
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
                random.nextInt(1000).toString() + ' Comments',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.share_rounded),
              const SizedBox(width: 8),
              const Text(
                'Share',
                style: TextStyle(
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
