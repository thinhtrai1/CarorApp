import 'dart:math';

import 'package:caror/data/DataService.dart';
import 'package:caror/entity/Product.dart';
import 'package:caror/themes/Number.dart';
import 'package:caror/widget/shimmer_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../widget/widget.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  var _isInitial = true;
  var _currentPage = 0;
  var _isLoadMore = false;
  final _chips = ['Featured Items', 'Trending', 'Favourite', 'New', 'Most recent'];
  final _products = List<Product>.empty(growable: true);
  final _scrollController = ScrollController();
  late final _tabController = TabController(length: _chips.length, vsync: this);
  late final _refreshIconController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this)..repeat();
  List<Product>? _favourites;

  @override
  void initState() {
    _getProducts(true);
    _scrollController.addListener(() {
      if (_isLoadMore && _scrollController.position.extentAfter < 300) {
        _isLoadMore = false;
        _getProducts(false);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
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
        _favourites ??= List.generate(5, (index) => response.data[Random().nextInt(response.data.length)]);
        setState(() {
          _products.addAll(response.data);
        });
      }
      _isInitial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildChipListView(),
        Flexible(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildContentView(_buildListViewFeature(), _scrollController),
              _buildContentView(_buildListViewTrending(), _scrollController),
              _buildContentView(_ListViewFavourites(favourites: _favourites), null),
              _buildContentView(_buildListViewRecent(), _scrollController),
              _buildContentView(_buildListViewFeature(), _scrollController),
            ],
          ),
        ),
      ],
    );
  }

  _buildChipListView() {
    //TODO: #HOW TO scroll selected item to center
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _chips.length,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
          width: 8,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _tabController.animateTo(index);
              });
            },
            child: index == _tabController.index
                ? Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      color: Color(0xFF323232),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _chips[index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      border: Border.all(
                        color: const Color(0xFF323232),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      _chips[index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF323232),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  _buildContentView(Widget sliverChild, ScrollController? controller) {
    return Shimmer(
      linearGradient: Shimmer.shimmerGradient,
      child: CustomScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          if (!_isInitial)
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                _getProducts(true);
                await Future<void>.delayed(
                  const Duration(milliseconds: 1000),
                );
              },
              builder: (c, refreshState, pulledExtent, d, e) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned(
                      bottom: pulledExtent / 7,
                      left: 0.0,
                      right: 0.0,
                      child: refreshState == RefreshIndicatorMode.drag
                          ? Column(
                              children: [
                                const Text('Pulling to refresh...'),
                                SizedBox(height: max(0, pulledExtent / 5 - 7)),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                  child: const Icon(Icons.arrow_circle_down_rounded, key: ValueKey('icon1')),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                const Text('Refreshing...'),
                                SizedBox(height: max(0, pulledExtent / 5 - 7)),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                  child: AnimatedBuilder(
                                    animation: _refreshIconController,
                                    builder: (_, child) {
                                      return Transform.rotate(
                                        angle: _refreshIconController.value * 2 * pi,
                                        child: child,
                                      );
                                    },
                                    child: const Icon(Icons.cached_rounded, key: ValueKey('icon2')),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          sliverChild,
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 16,
            ),
          ),
        ],
      ),
    );
  }

  _getItemCount() {
    return _products.length + (_isInitial || _isLoadMore ? 5 : 0);
  }

  _buildListViewFeature() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return index > _products.length - 1 ? const ShimmerLoading(child: _ProductShimmerItem()) : _ProductItem(_products[index]);
        },
        childCount: _getItemCount(),
      ),
    );
  }

  _buildListViewTrending() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return index > _products.length - 1 ? const ShimmerLoading(child: _ProductShimmerItem()) : _ParallaxItem(_products[index]);
        },
        childCount: _getItemCount(),
      ),
    );
  }

  _buildListViewRecent() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        staggeredTileBuilder: (i) => const StaggeredTile.fit(1),
        itemCount: _getItemCount(),
        itemBuilder: (context, index) {
          return index > _products.length - 1 ? const ShimmerLoading(child: _GridShimmerItem()) : _StaggeredGridItem(_products[index]);
        },
      ),
    );
  }
}

class _ListViewFavourites extends StatefulWidget {
  const _ListViewFavourites({Key? key, required this.favourites}) : super(key: key);

  final List<Product>? favourites;

  @override
  State<StatefulWidget> createState() => _ListViewFavouritesState();
}

class _ListViewFavouritesState extends State<_ListViewFavourites> with TickerProviderStateMixin {
  final listKey = GlobalKey<SliverAnimatedListState>();
  int expandedPosition = -1;
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    reverseDuration: const Duration(milliseconds: 400),
  );

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.favourites == null;
    return SliverAnimatedList(
      key: listKey,
      initialItemCount: widget.favourites?.length ?? 5,
      itemBuilder: (_, index, animation) {
        return Stack(
          children: [
            if (isLoading) const ShimmerLoading(child: _ProductShimmerItem()),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isLoading ? 0 : 1,
              child: isLoading ? const SizedBox() : _buildFavouriteItem(index, widget.favourites![index]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFavouriteItem(int index, Product item) {
    return Stack(
      children: [
        _ProductItem(item, isExpanded: expandedPosition == index),
        Positioned(
          bottom: 0,
          right: 16,
          child: CommonIcon(Icons.delete_rounded, padding: 12, onPressed: () {
            expandedPosition = -1;
            widget.favourites!.removeAt(index);
            listKey.currentState!.removeItem(index, (_, animation) => SizeTransition(sizeFactor: animation, child: _buildFavouriteItem(index, item)));
          }),
        ),
        Positioned(
          bottom: 0,
          right: 60,
          child: AnimatedRotation(
            turns: expandedPosition == index ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: CommonIcon(Icons.expand_more_rounded, padding: 12, onPressed: () {
              setState(() {
                expandedPosition = expandedPosition == index ? -1 : index;
              });
            }),
          ),
        ),
      ],
    );
  }
}

class _ParallaxItem extends StatelessWidget {
  _ParallaxItem(this.product, {Key? key}) : super(key: key);

  final Product product;
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: AspectRatio(
        aspectRatio: 8 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _buildParallaxBackground(context),
              _buildTitleAndSubtitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: _ParallaxFlowDelegate(
        scrollable: Scrollable.of(context)!,
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        Image.network(
          product.thumbnail,
          key: _backgroundImageKey,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0xCC000000),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParallaxFlowDelegate extends FlowDelegate {
  _ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(listItemBox.size.centerLeft(Offset.zero), ancestor: scrollableBox);
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);
    final backgroundSize = (backgroundImageKey.currentContext!.findRenderObject() as RenderBox).size;
    final listItemSize = context.size;
    final childRect = verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);
    context.paintChild(
      0,
      transform: Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(_ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable || listItemContext != oldDelegate.listItemContext || backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

class _ProductItem extends StatelessWidget {
  const _ProductItem(this.product, {this.isExpanded = false}) : super();

  final Product product;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE8E8E8),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                product.thumbnail,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name + ' \n',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: isExpanded ? const EdgeInsets.only(top: 8, bottom: 16) : EdgeInsets.zero,
                        child: isExpanded
                            ? Text(
                                product.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : const SizedBox(),
                      ),
                      const Spacer(),
                      Text(
                        NumberUtil.priceFormat(product.price),
                        style: const TextStyle(
                          color: Color(0xFFFF3D3D),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      RatingBar.builder(
                        ignoreGestures: true,
                        initialRating: product.rate,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 16,
                        itemBuilder: (context, _) => Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade900,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaggeredGridItem extends StatelessWidget {
  const _StaggeredGridItem(this.product) : super();

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE8E8E8),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Column(
          children: [
            Image.network(
              product.thumbnail,
              fit: BoxFit.fitWidth,
              frameBuilder: (context, child, frame, _) {
                if (frame == null) {
                  return Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: Color(0xFFd5d5d5),
                    ),
                  );
                }
                return child;
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductShimmerItem extends StatelessWidget {
  const _ProductShimmerItem() : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Color(0xFFd5d5d5),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Color(0xFFd5d5d5),
                      ),
                      width: double.infinity,
                      height: 16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Color(0xFFd5d5d5),
                      ),
                      width: 150,
                      height: 16,
                    ),
                    const Spacer(),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Color(0xFFd5d5d5),
                      ),
                      width: 150,
                      height: 16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Color(0xFFd5d5d5),
                      ),
                      width: 100,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridShimmerItem extends StatelessWidget {
  const _GridShimmerItem() : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Color(0xFFd5d5d5),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, right: 40),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Color(0xFFd5d5d5),
          ),
          height: 16,
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Color(0xFFd5d5d5),
          ),
          height: 16,
        ),
      ],
    );
  }
}
