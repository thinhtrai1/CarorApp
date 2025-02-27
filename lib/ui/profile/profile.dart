import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:caror/data/shared_preferences.dart';
import 'package:caror/entity/people.dart';
import 'package:flutter/material.dart';

import '../../data/data_service.dart';
import '../../generated/l10n.dart';
import '../../themes/number.dart';
import '../../themes/theme.dart';
import '../../widget/widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, this.people}) : super(key: key);

  final People? people;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const radius = 70.0;
    const corner = 20.0;
    final headerHeight = Number.getScreenWidth(context) * 2 / 3;
    final statusBarHeight = Number.getStatusBarHeight(context);
    final backgroundImageHeight = headerHeight + radius * 2 + corner;
    final People user = widget.people ?? People.fromUser(jsonDecode(AppPreferences.getUserInfo()));
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -radius,
            left: 0,
            right: 0,
            height: backgroundImageHeight,
            child: Container(
              color: Colors.black,
              child: _BackgroundImage(
                _scrollController,
                height: backgroundImageHeight,
                user: user,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: const SizedBox(),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: headerHeight - radius + corner),
            child: CustomPaint(
              painter: const _HeaderPaint(radius: radius, corner: corner),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: radius, left: 16, right: 16),
                          child: CommonTitleText(user.fullName),
                        ),
                      ),
                      Hero(
                        tag: 'avatar',
                        child: CircleAvatar(
                          radius: radius - 5,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: radius - 10,
                            backgroundColor: colorShimmer,
                            backgroundImage: NetworkImage(DataService.getFullUrl(user.avatar)),
                          ),
                        ),
                      ),
                      const SizedBox(width: corner + 5),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoItem(data: S.current.username, color: colorLight),
                          _InfoItem(data: S.current.email, color: colorLight),
                          _InfoItem(data: S.current.country, color: colorLight),
                          _InfoItem(data: S.current.phone, color: colorLight),
                          if (user.facebook != null)
                            _InfoItem(
                              data: S.current.facebook,
                              color: colorLight,
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoItem(data: user.username),
                              _InfoItem(data: user.email),
                              _InfoItem(data: user.country),
                              _InfoItem(data: user.phone),
                              if (user.facebook != null)
                                _InfoItem(
                                  data: user.facebook!.replaceAll('facebook', 'fb'),
                                  onPressed: () async {
                                    if (Platform.isAndroid) {
                                      AndroidIntent intent = AndroidIntent(
                                        action: 'action_view',
                                        data: 'fb://facewebmodal/f?href=https://www.${user.facebook}',
                                      );
                                      await intent.launch();
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFAAAAAA)),
                  _SuggestionListView(),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
                    child: Text(
                      S.current.community,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 8),
                      _CommunityItem(title: S.current.posts),
                      _CommunityItem(title: S.current.followers),
                      _CommunityItem(title: S.current.following),
                      _CommunityItem(title: S.current.photos),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFAAAAAA)),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
                    child: Text(
                      S.current.yours,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      _YourItem(title: S.current.notification),
                      _YourItem(title: S.current.history),
                      const SizedBox(width: 8),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      _YourItem(title: S.current.events),
                      _YourItem(title: S.current.gifts),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: statusBarHeight,
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
}

class _BackgroundImage extends StatefulWidget {
  const _BackgroundImage(
    this._scrollController, {
    required this.height,
    required this.user,
  }) : super();

  final ScrollController _scrollController;
  final double height;
  final People user;

  @override
  State<StatefulWidget> createState() => _BackgroundImageState();
}

class _BackgroundImageState extends State<_BackgroundImage> {
  double _scale = 1;
  double _translationY = 0;

  @override
  void initState() {
    widget._scrollController.addListener(() {
      if (widget._scrollController.offset < 0) {
        setState(() {
          _scale = -widget._scrollController.offset / widget.height + 1;
          _translationY = 0;
        });
      } else if (widget._scrollController.offset < widget.height - 100) {
        setState(() {
          _scale = 1;
          _translationY = -widget._scrollController.offset / 2;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, _translationY),
      child: Transform.scale(
        scale: _scale,
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          fit: BoxFit.cover,
          image: DataService.getFullUrl(widget.user.avatar),
        ),
      ),
    );
  }
}

class _SuggestionListView extends StatefulWidget {
  @override
  State<_SuggestionListView> createState() => _SuggestionListViewState();
}

class _SuggestionListViewState extends State<_SuggestionListView> {
  List<People>? _peoples;
  bool isVisible = false;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 5), () => _getPeoples());
    super.initState();
  }

  _getPeoples() {
    DataService.getPeoples().then((response) {
      if (response != null) {
        setState(() {
          _peoples = response.data;
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              isVisible = true;
            });
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        child: _peoples == null
            ? const SizedBox(width: double.infinity)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text(
                      S.current.people_you_may_know,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (c, i) {
                        return _SuggestionItem(people: _peoples![i]);
                      },
                      separatorBuilder: (c, i) => const SizedBox(width: 16),
                      itemCount: _peoples!.length,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFAAAAAA)),
                ],
              ),
      ),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  const _SuggestionItem({required this.people}) : super();

  final People people;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: colorShimmer,
          backgroundImage: NetworkImage(DataService.getFullUrl(people.avatar)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Text(
                people.fullName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                people.country,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
            Row(
              children: [
                MaterialIconButton(
                  Icons.person_add_rounded,
                  size: 20,
                  padding: 6,
                  onPressed: () {},
                ),
                MaterialIconButton(
                  Icons.chat_rounded,
                  size: 20,
                  padding: 6,
                  onPressed: () {},
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.data, this.color = Colors.black, this.onPressed});

  final String data;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return onPressed == null
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              data,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 1,
                fontSize: 16,
                color: color,
              ),
            ),
          )
        : Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  data,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          );
  }
}

class _CommunityItem extends StatelessWidget {
  const _CommunityItem({required this.title}) : super();

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          Random().nextInt(1000).toString(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          maxLines: 1,
          style: const TextStyle(
            color: colorLight,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _YourItem extends StatelessWidget {
  const _YourItem({required this.title}) : super();

  final String title;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xffececec),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Random().nextInt(1000).toString(),
              maxLines: 1,
              style: const TextStyle(
                color: colorLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderPaint extends CustomPainter {
  const _HeaderPaint({required this.radius, required this.corner}) : super();

  final double radius;
  final double corner;

  @override
  void paint(Canvas canvas, Size size) {
    final colorPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, radius - corner + 64)
      ..quadraticBezierTo(0, radius - corner, 64, radius - corner)
      ..lineTo(size.width - radius * 2 - corner * 2, radius - corner)
      ..quadraticBezierTo(size.width - radius * 2 - corner, radius - corner, size.width - radius * 2 - corner, radius)
      ..arcToPoint(
        Offset(size.width - corner, radius),
        radius: const Radius.circular(1) /** how it work? */,
        clockwise: false,
      )
      ..quadraticBezierTo(size.width - corner, radius - corner, size.width, radius - corner)
      ..lineTo(size.width, size.height)
      ..close();
    final colorPaint = Paint()..color = Colors.white;
    canvas.drawPath(colorPath, colorPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
