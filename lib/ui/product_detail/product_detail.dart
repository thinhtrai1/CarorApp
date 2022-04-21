import 'dart:math';

import 'package:caror/ui/image/image.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as e;

import '../../data/data_service.dart';
import '../../entity/Product.dart';
import '../../themes/number.dart';
import '../../themes/theme.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage(this._product, this._heroTag, {Key? key}) : super(key: key);

  final Product _product;
  final Object _heroTag;

  @override
  State<StatefulWidget> createState() {
    return _ProductDetailState();
  }
}

class _ProductDetailState extends State<ProductDetailPage> {
  late final _statusBarHeight = Number.getStatusBarHeight(context);
  final _scrollController = ScrollController();
  final _headerHeight = 280.0;
  final _commentNumber = Random().nextInt(1000);
  late String _encryptId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final key = e.Key.fromUtf8(App.ask);
    final iv = e.IV.fromLength(16);
    final encrypter = e.Encrypter(e.AES(key));
    final encrypted = encrypter.encrypt(widget._product.id.toString(), iv: iv);
    _encryptId = '{"id":"${encrypted.base64}"}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget._product;
    return Scaffold(
      body: Stack(
        children: [
          Hero(
            tag: widget._heroTag,
            flightShuttleBuilder: (a, animation, b, fromHeroContext, toHeroContext) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: toHeroContext.widget,
              );
            },
            child: Image.network(
              DataService.getFullUrl(product.image),
              fit: BoxFit.cover,
              width: double.infinity,
              height: _headerHeight,
              frameBuilder: (context, child, frame, _) {
                return frame == null
                    ? Image.network(
                        DataService.getFullUrl(product.thumbnail),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: _headerHeight,
                        frameBuilder: (context, child, frame, _) {
                          return frame == null
                              ? Container(
                                  width: double.infinity,
                                  height: _headerHeight,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(16)),
                                    color: colorShimmer,
                                  ),
                                )
                              : child;
                        },
                      )
                    : child;
              },
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _headerHeight - 16),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 40),
                            width: 100,
                            child: RatingBar.builder(
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
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: colorLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: _CustomQrImage(_encryptId),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // CommonIcon(Icons.favorite_border_rounded, onPressed: () {}),
                                Text(
                                  product.shopName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  Number.priceFormat(product.price),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Colors',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Black, White, Lambent Earth, Gray, Gold/Beige, and Silver.',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Reviews and comments',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$_commentNumber comments',
                        style: const TextStyle(
                          fontSize: 14,
                          color: colorLight,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            product.rate.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            '/5',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorLight,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CommonIcon(Icons.favorite_border_rounded, onPressed: () {}),
                          CommonIcon(Icons.share_rounded, onPressed: () {}),
                          CommonIcon(Icons.chat_rounded, onPressed: () {}),
                          const Spacer(),
                          CommonIcon(
                            Icons.remove_circle_outline_rounded,
                            padding: 16,
                            onPressed: () {
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
                          CommonIcon(
                            Icons.add_circle_outline_rounded,
                            padding: 16,
                            onPressed: () => setState(() => product.qty += 1),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 64, vertical: 12)),
                          ),
                          child: const Text(
                            'Add to cart',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Customers also bought',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          CommonIcon(Icons.arrow_forward_rounded, padding: 16, onPressed: () {}),
                        ],
                      ),
                      _buildSuggestListView(product),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Popular in Caror',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          CommonIcon(Icons.arrow_forward_rounded, padding: 16, onPressed: () {}),
                        ],
                      ),
                      _buildSuggestListView(product),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _AvatarAnimateImage(
            product.thumbnail,
            _headerHeight,
            _statusBarHeight,
            _scrollController,
          ),
          Positioned(
            left: 0,
            top: _statusBarHeight,
            child: CommonIcon(
              Icons.arrow_back_rounded,
              padding: 13,
              color: Colors.white,
              backgroundColor: const Color(0x80000000),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestListView(Product product) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 8,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(right: 16, top: 0, bottom: 8),
              width: 160,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
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
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: CommonWidget.image(
                        product.thumbnail,
                        fit: BoxFit.cover,
                        width: 160,
                      ),
                    ),
                  ),
                  //TODO #HOWTO: Fix Text's width equal to Image if fit is BoxFit.fitHeight
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      product.name,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class _CustomQrImage extends StatelessWidget {
  const _CustomQrImage(this._encryptId) : super();

  final String _encryptId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(_createRoute(context, QrImagePage(_encryptId)));
      },
      child: QrImage(
        data: _encryptId,
        padding: EdgeInsets.zero,
        size: 80,
      ),
    );
  }

  Route _createRoute(BuildContext parentContext, Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var rectAnimation = _createTween(parentContext).chain(CurveTween(curve: Curves.ease)).animate(animation);
        return Stack(
          children: [
            PositionedTransition(rect: rectAnimation, child: child),
          ],
        );
      },
    );
  }

  Tween<RelativeRect> _createTween(BuildContext context) {
    var windowSize = MediaQuery.of(context).size;
    var box = context.findRenderObject() as RenderBox;
    var rect = box.localToGlobal(Offset.zero) & box.size;
    var relativeRect = RelativeRect.fromSize(rect, windowSize);

    return RelativeRectTween(
      begin: relativeRect,
      end: RelativeRect.fill,
    );
  }
}

class _AvatarAnimateImage extends StatefulWidget {
  const _AvatarAnimateImage(
    this._thumbnail,
    this._headerHeight,
    this._statusHeight,
    this._scrollController,
  ) : super();

  final String _thumbnail;
  final double _headerHeight;
  final double _statusHeight;
  final ScrollController _scrollController;

  @override
  State<StatefulWidget> createState() => _AvatarAnimateImageState();
}

class _AvatarAnimateImageState extends State<_AvatarAnimateImage> with SingleTickerProviderStateMixin {
  late Animation<double> _avatarAnimation;
  late AnimationController _animationController;
  final _radius = 50.0;

  @override
  void initState() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _avatarAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
    widget._scrollController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  late final double _width = Number.getScreenWidth(context);
  late final double _ratio = (_width - _radius * 1.5 - 16) / (widget._headerHeight - 16 - _radius - widget._statusHeight + _radius / 2);

  @override
  Widget build(BuildContext context) {
    final offset = widget._scrollController.offset * 1.2;
    final left = min(_width - _radius * 1.5 - 16, offset * _ratio);
    final leftPer = left / (_width - _radius * 1.5 - 16);
    final scale = 1 - leftPer / 2;
    final fraction = leftPer * (1 - (1 - leftPer) / 1.5);
    return Positioned(
      left: 16 + left * fraction,
      top: max(widget._statusHeight - _radius / 2, widget._headerHeight - 16 - _radius - offset),
      child: offset == 0
          ? ScaleTransition(
              scale: _avatarAnimation,
              child: CircleAvatar(
                radius: _radius,
                backgroundImage: NetworkImage(DataService.getFullUrl(widget._thumbnail)),
              ),
            )
          : Transform.scale(
              scale: scale,
              child: CircleAvatar(
                radius: _radius,
                backgroundImage: NetworkImage(DataService.getFullUrl(widget._thumbnail)),
              ),
            ),
    );
  }
}
