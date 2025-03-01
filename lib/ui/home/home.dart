import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:caror/data/data_service.dart';
import 'package:caror/data/shared_preferences.dart';
import 'package:caror/resources/generated/l10n.dart';
import 'package:caror/resources/util.dart';
import 'package:caror/ui/home/tab_cart.dart';
import 'package:caror/ui/home/tab_chat.dart';
import 'package:caror/ui/home/tab_universe.dart';
import 'package:caror/ui/home/tab_home.dart';
import 'package:caror/ui/home/tab_setting.dart';
import 'package:flutter/material.dart';

enum LoginState { noLogin, loggingIn, loggedIn }

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.loginState = LoginState.noLogin}) : super(key: key);

  final LoginState loginState;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 5, vsync: this);
  late LoginState loginState;
  bool isSound = false;
  AudioPlayer? _audioPlayer;

  static HomePageState? of(BuildContext context) {
    return context.findAncestorStateOfType<HomePageState>();
  }

  checkSound({bool? value}) async {
    isSound = value ?? !isSound;
    if (isSound) {
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
        await _audioPlayer?.setSourceAsset('background_sound.mp3');
        _audioPlayer?.resume();
      } else {
        _audioPlayer?.resume();
      }
    } else {
      _audioPlayer?.pause();
    }
  }

  animateToTab(int index) async {
    Util.log('HomePage animateToTab $index');
    await Future.delayed(const Duration(milliseconds: 200), () {
      _tabController.animateTo(index);
    });
  }

  @override
  void dispose() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    loginState = widget.loginState;
    if (widget.loginState != LoginState.loggedIn) {
      final username = AppPreferences.getUsername();
      final password = AppPreferences.getPassword();
      if (username != null && password != null) {
        loginState = LoginState.loggingIn;
        DataService.login(username, password).then((user) {
          if (user != null) {
            AppPreferences.setAccessToken(user.token);
            AppPreferences.setUsername(username);
            AppPreferences.setPassword(password);
            AppPreferences.setUserInfo(jsonEncode(user.toJson()));
            loginState = LoginState.loggedIn;
          } else {
            loginState = LoginState.noLogin;
          }
        });
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: const [
                HomeTab(),
                UniverseTab(),
                CartTab(),
                ChatTab(),
                SettingTab(),
              ],
            ),
            Positioned(
              child: CustomPaint(
                painter: _BottomBarPaint(),
                child: _BottomBar(_tabController),
              ),
              bottom: 0,
              left: 0,
              right: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatefulWidget {
  const _BottomBar(this._tabController, {Key? key}) : super(key: key);

  final TabController _tabController;

  @override
  State<StatefulWidget> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> with SingleTickerProviderStateMixin {
  late Animation<double> _iconAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _iconAnimation = Tween<double>(begin: 0, end: 0.1).animate(_animationController);
  }

  _rotateIcon() {
    setState(() {
      _animationController.forward().then((value) => _animationController.reverse());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          const SizedBox(width: 8),
          BottomTabItem(
            position: 0,
            title: S.of(context).home,
            icon: Icons.home_rounded,
            tabController: widget._tabController,
            iconAnimation: _iconAnimation,
            onAnimateIcon: _rotateIcon,
          ),
          BottomTabItem(
            position: 1,
            title: S.current.universe,
            icon: Icons.camera_rounded,
            tabController: widget._tabController,
            iconAnimation: _iconAnimation,
            onAnimateIcon: _rotateIcon,
          ),
          BottomTabMiddleItem(
            tabController: widget._tabController,
            iconAnimation: _iconAnimation,
            onAnimateIcon: _rotateIcon,
          ),
          BottomTabItem(
            position: 3,
            title: S.current.chat,
            icon: Icons.chat_rounded,
            tabController: widget._tabController,
            iconAnimation: _iconAnimation,
            onAnimateIcon: _rotateIcon,
          ),
          BottomTabItem(
            position: 4,
            title: S.current.settings,
            icon: Icons.settings_rounded,
            tabController: widget._tabController,
            iconAnimation: _iconAnimation,
            onAnimateIcon: _rotateIcon,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class BottomTabItem extends StatelessWidget {
  const BottomTabItem({
    Key? key,
    required this.position,
    required this.title,
    required this.icon,
    required this.tabController,
    required this.iconAnimation,
    required this.onAnimateIcon,
  }) : super(key: key);

  final int position;
  final String title;
  final IconData icon;
  final TabController tabController;
  final Animation<double> iconAnimation;
  final Function onAnimateIcon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            tabController.animateTo(position);
            onAnimateIcon();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              tabController.index == position
                  ? RotationTransition(
                      turns: iconAnimation,
                      child: Icon(
                        icon,
                        color: Colors.black,
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.black,
                    ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomTabMiddleItem extends StatelessWidget {
  const BottomTabMiddleItem({
    Key? key,
    required this.tabController,
    required this.iconAnimation,
    required this.onAnimateIcon,
  }) : super(key: key);

  final TabController tabController;
  final Animation<double> iconAnimation;
  final Function onAnimateIcon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          width: 60,
          height: 50,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0xffcbcbcb),
                offset: Offset(0, 1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              onTap: () {
                tabController.animateTo(2);
                onAnimateIcon();
              },
              child: tabController.index == 2
                  ? RotationTransition(
                      turns: iconAnimation,
                      child: const Icon(
                        Icons.shopping_cart_rounded,
                        size: 32,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(
                      Icons.shopping_cart_rounded,
                      size: 32,
                      color: Colors.black,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// can use ShapeBorder
class _BottomBarPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPath = _createMainPath(Path()..moveTo(0, 10), size)..lineTo(size.width, 10);
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(shadowPath, shadowPaint);
    final colorPath = _createMainPath(Path()..moveTo(0, size.height), size)
      ..lineTo(size.width, size.height);
    final colorPaint = Paint()..color = Colors.white;
    canvas.drawPath(colorPath, colorPaint);
  }

  Path _createMainPath(Path path, Size size) {
    final centerX = size.width / 2;
    return path
      ..lineTo(0, 0)
      ..lineTo(centerX - 55, 0)
      ..quadraticBezierTo(centerX - 35, 0, centerX - 35, 20)
      ..lineTo(centerX - 35, size.height - 25)
      ..quadraticBezierTo(centerX - 35, size.height - 5, centerX - 15, size.height - 5)
      ..lineTo(centerX + 15, size.height - 5)
      ..quadraticBezierTo(centerX + 35, size.height - 5, centerX + 35, size.height - 25)
      ..lineTo(centerX + 35, 20)
      ..quadraticBezierTo(centerX + 35, 0, centerX + 55, 0)
      ..lineTo(size.width, 0);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
