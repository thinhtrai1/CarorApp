import 'dart:math';

import 'package:animations/animations.dart';
import 'package:caror/data/shared_preferences.dart';
import 'package:caror/resources/generated/l10n.dart';
import 'package:caror/ui/chat/chat.dart';
import 'package:caror/ui/image/image.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as e;
import 'package:share_plus/share_plus.dart';

import '../../data/data_service.dart';
import '../../entity/product.dart';
import '../../resources/number.dart';
import '../../resources/theme.dart';

class ProductDetailPage<S> extends StatefulWidget {
  const ProductDetailPage(
    this._product, {
    Key? key,
    this.heroTag,
  }) : super(key: key);

  final Product _product;
  final Object? heroTag;

  @override
  State<StatefulWidget> createState() {
    return _ProductDetailState();
  }

  static const resultCart = 'cart';
}

class _ProductDetailState extends State<ProductDetailPage> {
  late final _statusBarHeight = Number.getStatusBarHeight(context);
  final _scrollController = ScrollController();
  final _headerHeight = 280.0;
  final _commentNumber = Random().nextInt(1000);
  late String _encryptQR;

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
    _encryptQR = '{"id":"${encrypted.base64}", "iv": "${iv.base64}"}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget._product;
    final headerImage = ClipPath(
      clipper: CustomClipPath(),
      child: Image.network(
        DataService.getFullUrl(product.image),
        fit: BoxFit.cover,
        width: double.infinity,
        height: _headerHeight,
        frameBuilder: (context, child, frame, _) {
          return frame != null
              ? child
              : Image.network(
                  DataService.getFullUrl(product.thumbnail),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: _headerHeight,
                  frameBuilder: (context, child, frame, _) {
                    return frame != null
                        ? child
                        : Container(
                            width: double.infinity,
                            height: _headerHeight,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                              color: colorShimmer,
                            ),
                          );
                  },
                );
        },
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          widget.heroTag == null
              ? headerImage
              : Hero(
                  tag: widget.heroTag!,
                  flightShuttleBuilder: (a, animation, direction, fromHeroContext, toHeroContext) {
                    if (direction == HeroFlightDirection.push) {
                      return toHeroContext.widget;
                    } else {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: toHeroContext.widget,
                      );
                    }
                  },
                  child: headerImage,
                ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            controller: _scrollController,
            child: Container(
              margin: EdgeInsets.only(top: _headerHeight - 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
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
                        Text(
                          S.current.details,
                          style: const TextStyle(
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
                                child: _CustomQrImage(_encryptQR),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
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
                        Text(
                          S.current.colors,
                          style: const TextStyle(
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
                        Text(
                          S.current.reviews_and_comments,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          S.current.comments(_commentNumber),
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
                            const SelectionPopupIcon(Icons.favorite_border_rounded, padding: 16),
                            MaterialIconButton(Icons.chat_rounded, padding: 16, onPressed: () {}),
                            MaterialIconButton(Icons.share_rounded, padding: 16, onPressed: () {
                              Share.share(
                                  '${product.name}\n\n${product.description}\n\n${S.current.visit_caror_to_enjoy_now}');
                            }),
                            const Spacer(),
                            MaterialIconButton(
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
                            MaterialIconButton(
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
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
                              ),
                            ),
                            child: Text(
                              S.current.add_to_cart,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () async {
                              if (product.qty == 0) return;
                              AppPreferences.addToCart(product.id, product.qty);
                              final result = await showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return const AddToCartSuccessBottomSheet();
                                },
                              );
                              if (result == true) {
                                Navigator.pop(context, ProductDetailPage.resultCart);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Text(
                        S.current.customers_also_bought,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      MaterialIconButton(
                        Icons.arrow_forward_rounded,
                        padding: 16,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  _buildSuggestListView(product),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Text(
                        S.current.popular_in_caror,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      MaterialIconButton(
                        Icons.arrow_forward_rounded,
                        padding: 16,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  _buildSuggestListView(product),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _AvatarAnimateImage(
            _headerHeight,
            _statusBarHeight,
            _scrollController,
            widget.heroTag != null,
            product: product,
          ),
          Positioned(
            left: 8,
            top: _statusBarHeight,
            child: MaterialIconButton(
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
          padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 8),
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, 0)
      ..lineTo(0, size.height)
      ..quadraticBezierTo(0, size.height - 16, 16, size.height - 16)
      ..lineTo(size.width - 16, size.height - 16)
      ..quadraticBezierTo(size.width, size.height - 16, size.width, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CustomQrImage extends StatelessWidget {
  const _CustomQrImage(this._encryptId) : super();

  final String _encryptId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(createAnimateRoute(context, QrImagePage(encryptId: _encryptId)));
      },
      child: QrImageView(
        data: _encryptId,
        padding: EdgeInsets.zero,
        size: 80,
      ),
    );
  }
}

class _AvatarAnimateImage extends StatefulWidget {
  const _AvatarAnimateImage(
    this._headerHeight,
    this._statusHeight,
    this._scrollController,
    this._isZoomInAnimate, {
    required this.product,
  }) : super();

  final double _headerHeight;
  final double _statusHeight;
  final ScrollController _scrollController;
  final bool _isZoomInAnimate;
  final Product product;

  @override
  State<StatefulWidget> createState() => _AvatarAnimateImageState();
}

class _AvatarAnimateImageState extends State<_AvatarAnimateImage>
    with SingleTickerProviderStateMixin {
  late Animation<double> _avatarAnimation;
  late AnimationController _animationController;
  final _radius = 50.0;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _avatarAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    Future.delayed(const Duration(milliseconds: 300), () => _animationController.forward());
    widget._scrollController.addListener(() {
      if (widget._scrollController.offset < widget._headerHeight) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  late final double _width = Number.getScreenWidth(context) - _radius * 1.5 - 16 - 8;
  late final double _ratio =
      _width / (widget._headerHeight - 16 - _radius - widget._statusHeight + _radius / 2);

  @override
  Widget build(BuildContext context) {
    final offset = max(0.0, widget._scrollController.offset * 1.2);
    final left = min(_width, offset * _ratio);
    final leftPer = left / _width;
    final scale = 1 - leftPer / 2;
    final fraction = leftPer * (1 - (1 - leftPer) / 1.5);
    return Positioned(
      left: 16 + left * fraction,
      top: max(widget._statusHeight - _radius / 2, widget._headerHeight - 16 - _radius - offset),
      child: offset != 0
          ? Transform.scale(scale: scale, child: _buildCircleImage())
          : widget._isZoomInAnimate
              ? ScaleTransition(scale: _avatarAnimation, child: _buildCircleImage())
              : _buildCircleImage(),
    );
  }

  Widget _buildCircleImage() {
    return OpenContainer(
      openElevation: 0,
      openBuilder: (context, closedContainer) {
        return ChatPage(
          name: widget.product.shopName,
          thumbnail: widget.product.thumbnail,
        );
      },
      closedElevation: 0,
      closedShape: const CircleBorder(),
      closedBuilder: (context, openContainer) {
        return GestureDetector(
          onTap: openContainer,
          child: CircleAvatar(
            radius: _radius,
            backgroundImage: NetworkImage(DataService.getFullUrl(widget.product.thumbnail)),
          ),
        );
      },
    );
  }
}

class SelectionPopupIcon extends StatefulWidget {
  const SelectionPopupIcon(this.icon, {Key? key, this.padding = 20}) : super(key: key);

  final IconData icon;
  final double padding;

  @override
  State<SelectionPopupIcon> createState() => _SelectionPopupIconState();
}

class _SelectionPopupIconState extends State<SelectionPopupIcon>
    with SingleTickerProviderStateMixin {
  final selection = ['❤', '😍', '😆', '😂', '😢', '☹'];
  late final _controller =
      AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialIconButton(widget.icon, padding: widget.padding, onPressed: () {
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (c) {
          final box = context.findRenderObject() as RenderBox;
          final position = box.localToGlobal(Offset.zero);
          final width = 32.0 * selection.length;
          return Stack(
            children: [
              Positioned(
                left: max(4, position.dx - width / 3),
                width: width,
                height: 72,
                top: position.dy - 64,
                child: ListView(
                  children: List.generate(
                    selection.length,
                    (index) {
                      return SizedBox(
                        width: 32,
                        child: Stack(
                          children: [
                            PositionedTransition(
                              rect: _createTween(index),
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  selection[index],
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ],
          );
        },
      );
      _controller.forward(from: 0);
    });
  }

  Animation<RelativeRect> _createTween(int index) {
    return RelativeRectTween(
      begin: RelativeRect.fromSize(const Rect.fromLTWH(0, 40, 0, 0), const Size(32, 72)),
      end: RelativeRect.fromSize(const Rect.fromLTWH(0, 8, 32, 32), const Size(32, 72)),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(index * 0.07, 1, curve: Curves.elasticOut),
      ),
    );
  }
}

class AddToCartSuccessBottomSheet extends StatefulWidget {
  const AddToCartSuccessBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddToCartSuccessBottomSheet> createState() => _AddToCartSuccessBottomSheetState();
}

class _AddToCartSuccessBottomSheetState extends State<AddToCartSuccessBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.current.added_to_cart_successfully,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = _controller.value;
              return Transform.scale(
                scale: min(1, (value - 0.2).abs() / 0.4),
                child: CustomPaint(
                  size: const Size(60, 60),
                  painter: AddToCartSuccessIconPainter((value - 0.4).abs() / 0.6),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.current.go_to_cart,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded),
              ],
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }
}

class AddToCartSuccessIconPainter extends CustomPainter {
  const AddToCartSuccessIconPainter(this.percent);

  final double percent;

  @override
  bool shouldRepaint(AddToCartSuccessIconPainter oldDelegate) {
    return oldDelegate.percent != percent;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(15, 30)
      ..lineTo(25, 40)
      ..lineTo(45, 20);
    canvas.drawCircle(const Offset(30, 30), 30, backgroundPaint);
    canvas.drawPath(createAnimatedPath(path, percent), strokePaint);
  }
}
