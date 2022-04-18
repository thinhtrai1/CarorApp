import 'package:caror/data/data_service.dart';
import 'package:caror/themes/theme.dart';
import 'package:flutter/material.dart';

class CommonIcon extends Material {
  CommonIcon(IconData icon, {Key? key, double padding = 20, GestureTapCallback? onPressed})
      : super(
          key: key,
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Icon(icon),
            ),
          ),
        );
}

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
