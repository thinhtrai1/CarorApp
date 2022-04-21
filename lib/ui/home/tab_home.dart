import 'dart:math';

import 'package:caror/data/data_service.dart';
import 'package:caror/entity/Product.dart';
import 'package:caror/themes/theme.dart';
import 'package:caror/themes/number.dart';
import 'package:caror/ui/product_detail/product_detail.dart';
import 'package:caror/widget/parallax.dart';
import 'package:caror/widget/shimmer_loading.dart';
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
  final _products = List<Product>.empty(growable: true);
  final _scrollController = ScrollController();
  late final _tabController = TabController(length: 5, vsync: this);
  late final _refreshIconController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this)..repeat();
  List<Product>? _favourites;

  @override
  void initState() {
    _getProducts(true);
    _scrollController.addListener(() {
      if (_isLoadMore && _scrollController.position.extentAfter < 600) {
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
        if (_favourites == null) {
          final start = Random().nextInt(response.data.length ~/ 2);
          final end = start + Random().nextInt(response.data.length - start);
          _favourites = response.data.sublist(start, end + 1);
        }
        setState(() {
          _products.addAll(response.data);
        });
      }
      _isInitial = false;
    });
  }

  _onItemPressed(Product product, {String? heroTag}) {
    Navigator.of(context).push(createRoute(ProductDetailPage(product, heroTag ?? product.id)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          CustomTabBar(
            controller: _tabController,
          ),
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContentView(_ListViewFeature(_products, _isShimmerIndex, onPressed: _onItemPressed), _scrollController, sliverChild2: _buildListViewFeature3()),
                _buildContentView(_buildListViewTrending(), _scrollController),
                _buildContentView(_ListViewFavourites(onPressed: _onItemPressed, favourites: _favourites), null),
                _buildContentView(_buildListViewNew(), _scrollController),
                _buildContentView(_buildListViewRecent(), _scrollController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildContentView(Widget sliverChild, ScrollController? controller, {Widget? sliverChild2}) {
    return Shimmer(
      linearGradient: Shimmer.shimmerGradient,
      child: CustomScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          if (!_isInitial) CommonSliverRefreshControl(_refreshIconController, onRefresh: () async => _getProducts(true)),
          sliverChild,
          if (sliverChild2 != null) sliverChild2,
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 16,
            ),
          ),
        ],
      ),
    );
  }

  int _getItemCount() => _products.length + (_isInitial || _isLoadMore ? shimmerItemCount : 0);

  bool _isShimmerIndex(int index) => index > _products.length - 1;

  _buildListViewFeature3() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _isShimmerIndex(index)
              ? const ShimmerLoading(child: _ProductShimmerItem())
              : _RecentItem(
                  _products[index],
                  onPressed: _onItemPressed,
                  offsetY: 0,
                );
        },
        childCount: _getItemCount(),
      ),
    );
  }

  _buildListViewTrending() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _isShimmerIndex(index)
              ? const ShimmerLoading(child: _TrendingShimmerItem(marginHorizontal: 16))
              : _TrendingItem(
                  _products[index],
                  onPressed: _onItemPressed,
                );
        },
        childCount: _getItemCount(),
      ),
    );
  }

  _buildListViewNew() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        staggeredTileBuilder: (i) => const StaggeredTile.fit(1),
        itemCount: _getItemCount(),
        itemBuilder: (context, index) {
          return _isShimmerIndex(index) ? const ShimmerLoading(child: _TrendingShimmerItem()) : _NewItem(_products[index]);
        },
      ),
    );
  }

  _buildListViewRecent() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _isShimmerIndex(index) ? const ShimmerLoading(child: _ProductShimmerItem()) : _RecentItem(_products[index], onPressed: _onItemPressed);
        },
        childCount: _getItemCount(),
      ),
    );
  }
}

class _ListViewFeature extends StatelessWidget {
  const _ListViewFeature(this._products, this._isShimmerIndex, {Key? key, this.onPressed}) : super(key: key);

  final List<Product> _products;
  final Function(Product, {String? heroTag})? onPressed;
  final bool Function(int) _isShimmerIndex;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: Number.getScreenWidth(context) / 2,
            child: PageView.builder(
              controller: PageController(initialPage: 500, viewportFraction: 0.7),
              itemBuilder: (context, index) {
                if (_products.isEmpty || _isShimmerIndex(index % _products.length)) {
                  return ShimmerLoading(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        color: colorShimmer,
                      ),
                    ),
                  );
                } else {
                  return _FeatureItem1(_products[index % _products.length], onPressed: onPressed);
                }
              },
            ),
          ),
          _FeatureList2(_products, _isShimmerIndex, onPressed: onPressed),
        ],
      ),
    );
  }
}

class _FeatureItem1 extends StatelessWidget {
  _FeatureItem1(this.product, {Key? key, this.onPressed}) : super(key: key);

  final Product product;
  final Function(Product, {String? heroTag})? onPressed;
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final heroTag = product.id.toString() + '-1';
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: GestureDetector(
        onTap: () => onPressed?.call(product, heroTag: heroTag),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Hero(
                tag: heroTag,
                child: _buildParallaxBackground(context),
              ),
              _buildTitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowHorizontalDelegate(
        scrollable: Scrollable.of(context)!,
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
        customTranslateY: 0.1,
      ),
      children: [
        CommonWidget.image(
          product.image,
          key: _backgroundImageKey,
          fit: BoxFit.cover,
          shimmerWidth: Number.getScreenWidth(context) * 0.7,
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0x80FFFFFF),
        padding: const EdgeInsets.all(8),
        child: Text(
          product.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FeatureList2 extends StatefulWidget {
  _FeatureList2(this._products, this._isShimmerIndex, {Key? key, this.onPressed}) : super(key: key);

  final List<Product> _products;
  final Function(Product, {String? heroTag})? onPressed;
  final bool Function(int) _isShimmerIndex;
  final _pageController = PageController(initialPage: 505, viewportFraction: 0.8);

  @override
  State<_FeatureList2> createState() => _FeatureList2State();
}

class _FeatureList2State extends State<_FeatureList2> {
  late int _currentPage;

  @override
  void initState() {
    _currentPage = widget._pageController.initialPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Number.getScreenWidth(context) / 3,
      child: PageView.builder(
        controller: widget._pageController,
        onPageChanged: (position) {
          setState(() {
            _currentPage = position;
          });
        },
        itemBuilder: (context, index) {
          if (widget._products.isEmpty || widget._isShimmerIndex(index % widget._products.length)) {
            return ShimmerLoading(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color: colorShimmer,
                ),
              ),
            );
          } else {
            return _buildFeatureItem2(index);
          }
        },
      ),
    );
  }

  _buildFeatureItem2(int index) {
    final product = widget._products[index % widget._products.length];
    final titles = product.name.split(' - ');
    final heroTag = product.id.toString() + '-2';
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => widget.onPressed?.call(product, heroTag: heroTag),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Hero(
                tag: heroTag,
                child: CommonWidget.image(
                  product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSlide(
                      offset: _currentPage == index ? const Offset(0.0, 0.0) : const Offset(0.1, 0.0),
                      duration: const Duration(milliseconds: 700),
                      child: AnimatedOpacity(
                        opacity: _currentPage == index ? 1 : 0,
                        duration: const Duration(milliseconds: 1000),
                        child: Text(
                          titles[0],
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    AnimatedSlide(
                      offset: _currentPage == index ? const Offset(0.0, 0.0) : const Offset(-0.1, 0.0),
                      duration: const Duration(milliseconds: 700),
                      child: AnimatedOpacity(
                        opacity: _currentPage == index ? 1 : 0,
                        duration: const Duration(milliseconds: 1000),
                        child: Text(
                          titles.length > 1 ? titles[1] : titles[0],
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListViewFavourites extends StatefulWidget {
  const _ListViewFavourites({Key? key, this.onPressed, required this.favourites}) : super(key: key);

  final List<Product>? favourites;
  final Function(Product)? onPressed;

  @override
  State<StatefulWidget> createState() => _ListViewFavouritesState();
}

class _ListViewFavouritesState extends State<_ListViewFavourites> {
  final listKey = GlobalKey<SliverAnimatedListState>();
  int expandedPosition = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.favourites == null) {
      return SliverList(
        delegate: SliverChildListDelegate(
          List.generate(shimmerItemCount, (index) => const ShimmerLoading(child: _ProductShimmerItem())),
        ),
      );
    } else {
      return SliverAnimatedList(
        key: listKey,
        initialItemCount: widget.favourites!.length,
        itemBuilder: (_, index, animation) {
          return _buildFavouriteItem(index, widget.favourites![index]);
        },
      );
    }
  }

  Widget _buildFavouriteItem(int index, Product item) {
    return Dismissible(
      key: Key(item.id.toString()),
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
      onDismissed: (direction) {
        if (expandedPosition == index) {
          expandedPosition = -1;
        } else if (expandedPosition > index) {
          expandedPosition -= 1;
        }
        widget.favourites!.removeAt(index);
        listKey.currentState!.removeItem(index, (_, animation) => const SizedBox());
      },
      child: Stack(
        children: [
          _RecentItem(item, onPressed: widget.onPressed, isExpanded: expandedPosition == index),
          Positioned(
            bottom: 0,
            right: 16,
            child: CommonIcon(Icons.delete_rounded, padding: 12, onPressed: () {
              expandedPosition = -1;
              widget.favourites!.removeAt(index);
              listKey.currentState!.removeItem(
                index,
                (_, animation) => SizeTransition(sizeFactor: animation, child: _buildFavouriteItem(index, item)),
                duration: const Duration(milliseconds: 200),
              );
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
      ),
    );
  }
}

class _TrendingItem extends StatelessWidget {
  _TrendingItem(this.product, {Key? key, this.onPressed}) : super(key: key);

  final Product product;
  final Function(Product)? onPressed;
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
    return GestureDetector(
      onTap: () => onPressed?.call(product),
      child: Hero(
        tag: product.id,
        child: Flow(
          delegate: ParallaxFlowVerticalDelegate(
            scrollable: Scrollable.of(context)!,
            listItemContext: context,
            backgroundImageKey: _backgroundImageKey,
          ),
          children: [
            CommonWidget.image(
              product.image,
              key: _backgroundImageKey,
              fit: BoxFit.cover,
              shimmerHeight: Number.getScreenWidth(context) * 3 / 8,
            ),
          ],
        ),
      ),
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
                fontWeight: FontWeight.w600,
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

class _RecentItem extends StatelessWidget {
  const _RecentItem(
    this.product, {
    this.onPressed,
    this.isExpanded = false,
    this.offsetY = 2,
  }) : super();

  final Product product;
  final bool isExpanded;
  final double offsetY;
  final Function(Product)? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed?.call(product),
      child: Container(
        margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: colorShadow,
              offset: Offset(0, offsetY),
              blurRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: product.id,
                  child: CommonWidget.image(
                    product.thumbnail,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name + '\n',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: isExpanded ? const EdgeInsets.only(top: 8, bottom: 16) : EdgeInsets.zero,
                          child: isExpanded
                              ? Text(
                                  product.description,
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                        ),
                        const Spacer(),
                        Text(
                          Number.priceFormat(product.price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RatingBar.builder(
                          ignoreGestures: true,
                          initialRating: product.rate,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 16,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star_rounded,
                            color: Colors.black,
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
      ),
    );
  }
}

class _NewItem extends StatelessWidget {
  const _NewItem(this.product) : super();

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: colorShadow,
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Column(
          children: [
            CommonWidget.image(
              product.thumbnail,
              fit: BoxFit.fitWidth,
              shimmerHeight: 100,
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
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: colorShimmer,
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
                        color: colorShimmer,
                      ),
                      width: double.infinity,
                      height: 16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: colorShimmer,
                      ),
                      width: 150,
                      height: 16,
                    ),
                    const Spacer(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingShimmerItem extends StatelessWidget {
  const _TrendingShimmerItem({this.marginHorizontal = 0}) : super();

  final double marginHorizontal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          margin: EdgeInsets.only(top: 8, left: marginHorizontal, right: marginHorizontal),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: colorShimmer,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8, left: marginHorizontal, right: 60),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: colorShimmer,
          ),
          height: 16,
        ),
        Container(
          margin: EdgeInsets.only(top: 4, left: marginHorizontal, right: marginHorizontal),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: colorShimmer,
          ),
          height: 16,
        ),
      ],
    );
  }
}

class CustomTabBar extends StatefulWidget {
  CustomTabBar({Key? key, required this.controller}) : super(key: key);

  final TabController controller;
  final _chips = ['Featured Items', 'Trending', 'Favourite', 'New', 'Most recent'];

  @override
  State<StatefulWidget> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: widget.controller,
      isScrollable: true,
      indicatorColor: Colors.transparent,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      tabs: _getTabs(),
    );
  }

  List<Tab> _getTabs() => List.generate(
        widget._chips.length,
        (index) => Tab(
          icon: widget.controller.index == index
              ? Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    color: Colors.black,
                  ),
                  height: 32,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget._chips[index],
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
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  height: 32,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    widget._chips[index],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF323232),
                    ),
                  ),
                ),
        ),
      );
}
