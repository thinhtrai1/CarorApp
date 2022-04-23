import 'dart:math';

import 'package:caror/data/data_service.dart';
import 'package:caror/themes/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonWidget {
  static Image image(
    String path, {
    Key? key,
    BoxFit? fit,
    double? width,
    double? height,
    double? shimmerWidth,
    double? shimmerHeight,
    double shimmerRadius = 8,
  }) {
    return Image.network(
      DataService.getFullUrl(path),
      key: key,
      fit: fit,
      width: width,
      height: height,
      frameBuilder: (context, child, frame, _) {
        return frame == null
            ? Container(
                width: width ?? shimmerWidth,
                height: height ?? shimmerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(shimmerRadius)),
                  color: colorShimmer,
                ),
              )
            : child;
      },
    );
  }
}

Widget buildMaterialIcon(
  IconData icon, {
  Key? key,
  double padding = 20,
  Color color = Colors.black,
  Color backgroundColor = Colors.transparent,
  GestureTapCallback? onPressed,
}) {
  return Material(
    key: key,
    color: backgroundColor,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Icon(icon, color: color),
      ),
    ),
  );
}

class CommonSliverRefreshControl extends CupertinoSliverRefreshControl {
  CommonSliverRefreshControl(AnimationController animationIconController, {Key? key, Future<void> Function()? onRefresh})
      : super(
          key: key,
          onRefresh: () async {
            onRefresh?.call();
            await Future<void>.delayed(
              const Duration(milliseconds: 1000),
            );
          },
          builder: (c, refreshState, pulledExtent, d, e) {
            return Stack(
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
                                animation: animationIconController,
                                builder: (_, child) {
                                  return Transform.rotate(
                                    angle: animationIconController.value * 2 * pi,
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
        );
}

class CommonBackgroundContainer extends Stack {
  CommonBackgroundContainer({Key? key, Widget? child, Color? color, EdgeInsetsGeometry? padding, double headerHeight = 160})
      : super(
          key: key,
          children: [
            SizedBox(
              width: double.infinity,
              height: headerHeight + 64,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.black),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: headerHeight),
              height: double.infinity,
              child: child,
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(64)),
                color: color ?? Colors.white,
              ),
            ),
          ],
        );
}

class CommonTitleText extends Text {
  const CommonTitleText(
    String title, {
    Key? key,
  }) : super(
          title,
          key: key,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 32,
          ),
        );
}

class LoginTextFieldBackground extends Container {
  LoginTextFieldBackground({
    Key? key,
    String? label,
    TextInputAction? textInputAction = TextInputAction.next,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextEditingController? controller,
    TextFormField? child,
  }) : super(
          key: key,
          padding: const EdgeInsets.only(left: 16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: colorShadow,
                offset: Offset(0, 0),
                blurRadius: 2,
              ),
            ],
          ),
          child: child ??
              TextFormField(
                controller: controller,
                textInputAction: textInputAction,
                textCapitalization: textCapitalization,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: label,
                ),
                style: const TextStyle(fontFamily: "Montserrat"),
              ),
        );
}
