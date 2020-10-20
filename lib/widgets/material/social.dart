import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/decoration/page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';

/// Supported providers.
enum NssSocialProvider {
  facebook,
  google,
  yahoo,
  apple,
  twitter,
  line,
  wechat,
  amazon,
  linkedin,
  vkontakte,
  yahooJapan,
}

extension NssSocialProviderEx on NssSocialProvider {
  String get name => describeEnum(this);

  /// Get main provider color as designed by provider brand guidelines.
  Color getColor({bool forGrid = false}) {
    switch (this) {
      case NssSocialProvider.facebook:
        return Color(0xff0074fa);
      case NssSocialProvider.google:
        return forGrid ? Colors.white : Color(0xff4285F4);
      case NssSocialProvider.yahoo:
        return Color(0xff720e9e);
      case NssSocialProvider.twitter:
        return Color(0xff55acee);
      case NssSocialProvider.line:
        return Color(0xff00c800);
      case NssSocialProvider.wechat:
        return Color(0xff00c600);
      case NssSocialProvider.amazon:
        return forGrid ? Colors.white : Color(0xffffab00);
      case NssSocialProvider.vkontakte:
        return Color(0xff587ea3);
      case NssSocialProvider.yahooJapan:
        return Color(0xffe61318);
      case NssSocialProvider.apple:
        return Colors.black;
      case NssSocialProvider.linkedin:
        return Color(0xff007bb6);
    }
    return Colors.blue;
  }
}

/// Social login button widget.
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
    return Padding(
      padding: getStyle(Styles.margin, data: widget.data),
      child: customSizeWidget(
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
                      widget.data.iconEnabled
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image(
                                image: widget.data.iconURL != null
                                    ? NetworkImage(widget.data.iconURL)
                                    : AssetImage(
                                        'assets/social_images/${widget.data.provider.name}.png'),
                                width: 24,
                                height: 24,
                              ),
                            )
                          : SizedBox(width: 8),
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
                  onPressed: () {
                    viewModel.socialLogin(widget.data.provider);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Social grid layout (with available paging) widget.
class SocialLoginGrid extends StatefulWidget {
  final NssWidgetData data;

  const SocialLoginGrid({Key key, this.data}) : super(key: key);

  @override
  _SocialLoginGridState createState() => _SocialLoginGridState();
}

class _SocialLoginGridState extends State<SocialLoginGrid>
    with DecorationMixin, StyleMixin, LocalizationMixin {
  final double maxCellHeight = 94;
  final int maxRows = 2;

  final PageController _pageController = PageController();
  double currentPage = 0;

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page;
      });
    });
    super.initState();

    if (widget.data.rows > 2) {
      widget.data.rows = 2;
      engineLogger.e('You have specified a row count that exceeds allowed value.\n'
          'Currently max rows is set to 2');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int providerCount = widget.data.providers.length;
    final int maxInPage = widget.data.columns * widget.data.rows;
    bool paging = (providerCount > (widget.data.columns * widget.data.rows));
    final int numOfPages =
        (providerCount / maxInPage).abs().toInt() + (providerCount % maxInPage != 0 ? 1 : 0);

    debugPrint(
        'Social login grid: paging = $paging, numberOfPages = $numOfPages, aproximateHeight = ${maxCellHeight * widget.data.rows}');

    return Padding(
      padding: getStyle(Styles.margin, data: widget.data),
      child: Consumer<ScreenViewModel>(
        builder: (context, viewModel, child) {
          return paging
              ? NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowGlow();
                    return;
                  },
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(
                        height: (maxCellHeight * widget.data.rows),
                        child: PageView.builder(
                          itemCount: numOfPages,
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, position) {
                            var start = position * maxInPage;
                            var end = maxInPage * (position + 1);
                            if (widget.data.providers.length < end) {
                              var delta = end - widget.data.providers.length;
                              end = end - delta;
                            }
                            return createGrid(viewModel, start, end);
                          },
                        ),
                      ),
                      Container(
                        height: 10,
                        child: PageIndicator(
                          controller: _pageController,
                          color: getStyle(Styles.indicatorColor,
                              data: widget.data, themeProperty: 'enabledColor'),
                          itemCount: numOfPages,
                        ),
                      )
                    ],
                  ),
                )
              : createGrid(
                  viewModel,
                  0,
                  widget.data.providers.length,
                );
        },
      ),
    );
  }

  /// Create grid layouting of the given provider indexes.
  Widget createGrid(ScreenViewModel viewModel, int start, int end) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      int crossAxisCount = widget.data.columns;
      double axisSpacing = 4;
      var width = (MediaQuery.of(context).size.width - ((crossAxisCount - 1) * axisSpacing)) /
          crossAxisCount;
      var cellHeight = 100;
      var aspectRatio = width / cellHeight;
      return GridView.count(
        shrinkWrap: true,
        crossAxisSpacing: axisSpacing,
        mainAxisSpacing: axisSpacing,
        childAspectRatio: aspectRatio,
        crossAxisCount: crossAxisCount,
        children: widget.data.providers
            .map<Widget>((provider) {
              return createGridItem(
                viewModel,
                provider,
              );
            })
            .toList()
            .sublist(start, end),
      );
    });
  }

  /// Create grid social button widget.
  Widget createGridItem(ScreenViewModel viewModel, NssSocialProvider provider) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: InkWell(
              onTap: () {
                viewModel.socialLogin(provider);
              },
              child: Material(
                elevation: getStyle(Styles.elevation, data: widget.data),
                borderRadius: BorderRadius.circular(
                  getStyle(Styles.cornerRadius, data: widget.data),
                ),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      getStyle(Styles.cornerRadius, data: widget.data),
                    ),
                    color: provider.getColor(forGrid: true),
                  ),
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Center(
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 100),
                          width: 32,
                          height: 32,
                          image: AssetImage('assets/social_images/g_${provider.name}.png'),
                          placeholder: AssetImage('assets/social_images/${provider.name}.png'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          widget.data.hideTitles
              ? Container()
              : Text(
                  provider.name.inCaps,
                  style: TextStyle(
                    fontSize: getStyle(Styles.fontSize, data: widget.data),
                    color: getStyle(Styles.fontColor, data: widget.data),
                    fontWeight: getStyle(Styles.fontWeight, data: widget.data),
                  ),
                ),
        ],
      ),
    );
  }
}
