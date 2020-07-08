import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:provider/provider.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';

enum NssSocialProvider {
  facebook,
  google,
  yahoo,
  twitter,
  line,
  wechat,
  amazon,
  blogger,
  foursquare,
  instagram,
  kakao,
  linkedin,
  livedoor,
  messenger,
  mixi,
  naver,
  netlog,
  odnoklassniki,
  orangeFrance,
  paypaloauth,
  tencentQq,
  renren,
  sinaWeibo,
  spiceworks,
  vkontakte,
  wordpress,
  xing,
  yahooJapan,
  apple
}

extension NssSocialProviderEx on NssSocialProvider {
  String get name => describeEnum(this);

  Color getColor() {
    switch (this) {
      case NssSocialProvider.facebook:
        return _getColorWithHex('0074fa');
      case NssSocialProvider.google:
        return _getColorWithHex('4285F4');
      case NssSocialProvider.yahoo:
        return _getColorWithHex('720e9e');
      case NssSocialProvider.twitter:
        return _getColorWithHex('55acee');
      case NssSocialProvider.line:
        return _getColorWithHex('00c800');
      case NssSocialProvider.wechat:
        return _getColorWithHex('00c600');
      case NssSocialProvider.amazon:
        return _getColorWithHex('ffab00');
      case NssSocialProvider.blogger:
        return _getColorWithHex('ff7800');
      case NssSocialProvider.foursquare:
        return _getColorWithHex('0072b6');
      case NssSocialProvider.instagram:
        return _getColorWithHex('3f729b');
      case NssSocialProvider.vkontakte:
        return _getColorWithHex('587ea3');
      case NssSocialProvider.xing:
        return _getColorWithHex('007676');
      case NssSocialProvider.yahooJapan:
        return _getColorWithHex('720e9e');
      case NssSocialProvider.apple:
        return Colors.black;
      case NssSocialProvider.linkedin:
        return _getColorWithHex('007bb6');
      case NssSocialProvider.kakao:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.livedoor:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.messenger:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.mixi:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.naver:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.netlog:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.odnoklassniki:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.orangeFrance:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.paypaloauth:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.tencentQq:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.renren:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.sinaWeibo:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.spiceworks:
        // TODO: Handle this case.
        break;
      case NssSocialProvider.wordpress:
        // TODO: Handle this case.
        break;
    }
    return Colors.blue;
  }

  Color _getColorWithHex(String hexColorString, {String opacity}) {
    if (hexColorString == null) {
      return null;
    }
    hexColorString = hexColorString.toUpperCase().replaceAll("#", "");
    if (hexColorString.length == 6) {
      hexColorString = (opacity ?? "FF") + hexColorString;
    }
    int colorInt = int.parse(hexColorString, radix: 16);
    return Color(colorInt);
  }
}

class SocialButtonWidget extends StatefulWidget {
  final NssWidgetData data;

  const SocialButtonWidget({Key key, this.data}) : super(key: key);

  @override
  _SocialButtonWidgetState createState() => _SocialButtonWidgetState();
}

class _SocialButtonWidgetState extends State<SocialButtonWidget>
    with DecorationMixin, StyleMixin, LocalizationMixin {
  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(
      widget.data,
      Padding(
        padding: getStyle(Styles.margin, data: widget.data),
        child: sizeIfNeeded(
          widget.data,
          Consumer<ScreenViewModel>(
            builder: (context, viewModel, child) {
              final text = widget.data.textKey == null
                  ? 'Sign in with ${widget.data.provider.name.inCaps}'
                  : localizedStringFor(widget.data.textKey);

              var background = getStyle(Styles.background, data: widget.data);

              if (widget.data.style[Styles.background.name] == null) {
                background = widget.data.provider.getColor();
              }

              return Opacity(
                opacity: getStyle(Styles.opacity, data: widget.data),
                child: ButtonTheme(
                  buttonColor: background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      getStyle(Styles.cornerRadius, data: widget.data),
                    ),
                  ),
                  child: RaisedButton(
                    padding: EdgeInsets.zero,
                    elevation: getStyle(Styles.elevation, data: widget.data),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: Image(
                            image:
                                AssetImage('assets/social_images/${widget.data.provider.name}.png'),
                            width: 28,
                            height: 28,
                          ),
                        ),
                        Text(
                          // Get localized submit text.
                          text,
                          style: TextStyle(
                            fontSize: getStyle(Styles.fontSize, data: widget.data),
                            color: getStyle(Styles.fontColor,
                                data: widget.data, themeProperty: 'secondaryColor'),
                            fontWeight: getStyle(Styles.fontWeight, data: widget.data),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {},
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
