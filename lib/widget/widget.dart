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

class CommonBackIcon extends Material {
  CommonBackIcon(GestureTapCallback? onCLick, {Key? key})
      : super(
          key: key,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onCLick,
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
        );
}
