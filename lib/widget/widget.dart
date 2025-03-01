import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:caror/data/data_service.dart';
import 'package:caror/resources/generated/l10n.dart';
import 'package:caror/resources/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../resources/number.dart';

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
    Color shimmerColor = colorShimmer,
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
                  color: shimmerColor,
                ),
              )
            : child;
      },
    );
  }
}

class MaterialIconButton extends StatelessWidget {
  const MaterialIconButton(
    this.icon, {
    Key? key,
    this.size,
    this.padding = 20,
    this.color = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final double? size;
  final double padding;
  final Color color;
  final Color backgroundColor;
  final GestureTapCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: key,
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }
}

class CommonSliverRefreshControl extends CupertinoSliverRefreshControl {
  CommonSliverRefreshControl(
    AnimationController animationIconController, {
    Key? key,
    Future<void> Function()? onRefresh,
  }) : super(
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
                            Text(S.current.pulling_to_refresh),
                            SizedBox(height: max(0, pulledExtent / 5 - 7)),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: const Icon(Icons.arrow_circle_down_rounded,
                                  key: ValueKey('icon1')),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Text(S.current.refreshing),
                            SizedBox(height: max(0, pulledExtent / 5 - 7)),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
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

class CommonBackgroundContainer extends StatelessWidget {
  const CommonBackgroundContainer({
    Key? key,
    this.child,
    this.color,
    this.padding,
    this.headerHeight = 160,
    this.isBack = false,
  }) : super(key: key);

  final Widget? child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double headerHeight;
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = Number.getStatusBarHeight(context);
    return Stack(
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
        if (isBack)
          Positioned(
            left: 8,
            top: statusBarHeight,
            child: MaterialIconButton(
              Icons.arrow_back_rounded,
              padding: 13,
              color: Colors.white,
              backgroundColor: const Color(0x33FFFFFF),
              onPressed: () => Navigator.pop(context),
            ),
          ),
      ],
    );
  }
}

class CommonTitleText extends Text {
  const CommonTitleText(
    String title, {
    Key? key,
  }) : super(
          title,
          key: key,
          textAlign: TextAlign.center,
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

extension CustomPainterExt on CustomPainter {
  Path createAnimatedPath(
    Path originalPath,
    double animationPercent,
  ) {
    final totalLength = originalPath
        .computeMetrics()
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);
    final length = totalLength * animationPercent;
    var currentLength = 0.0;
    final path = Path();
    var metricsIterator = originalPath.computeMetrics().iterator;
    while (metricsIterator.moveNext()) {
      var metric = metricsIterator.current;
      var nextLength = currentLength + metric.length;
      final isLastSegment = nextLength > length;
      if (isLastSegment) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0.0, remainingLength);
        path.addPath(pathSegment, Offset.zero);
        break;
      } else {
        final pathSegment = metric.extractPath(0.0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }
      currentLength = nextLength;
    }
    return path;
  }
}

final kTransparentImage = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE
]);
