import 'package:caror/data/DataService.dart';
import 'package:caror/themes/AppTheme.dart';
import 'package:flutter/material.dart';

class SimpleProgressBar extends Center {
  SimpleProgressBar({Key? key})
      : super(
          key: key,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFE8E8E8),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                )
              ],
            ),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
}

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
