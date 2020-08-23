import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/linkify.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:provider/provider.dart';

enum ImageSource { web, asset }

typedef ErrorCallback();

abstract class ImageWidgetState<T extends StatefulWidget> extends State<T>
    with DecorationMixin, BindingMixin, StyleMixin {
  ImageProvider imageProvider = MemoryImage(kTransparentImage);

  /// Fetch the image according to provided specs.
  getImage(url, fallback) async {
    final ImageSource imageSource = getImageSource(url);

    // Starting with the source.
    if (imageSource == ImageSource.web) {
      resolveNetworkResource(url, () {
        // Error -> fallback.
        resolveFallback(fallback);
      });
    } else {
      resovleAssetResource(url, () {
        // Error -> fallback.
        resolveFallback(fallback);
      });
    }
  }

  /// Resolve fallback if main URL fetch has failed.
  void resolveFallback(fallback) {
    final String fallbackPath = fallback ?? '';
    if (fallbackPath.isEmpty) {
      resolveStaticPlaceholder();
      return;
    }
    final ImageSource fallbackSource = getImageSource(fallback);
    if (fallbackSource == ImageSource.web) {
      resolveNetworkResource(fallbackPath, () {
        resolveStaticPlaceholder();
      });
    } else {
      resovleAssetResource(fallbackPath, () {
        resolveStaticPlaceholder();
      });
    }
  }

  /// Place a static image if fallback image has failed.
  void resolveStaticPlaceholder() {
    if (mounted) {
      setState(() {
        engineLogger.d('Failed to obtain image for widget');
        imageProvider = MemoryImage(kTransparentImage);
      });
    }
  }

  /// Try to fetch the image from a network resource.
  void resolveNetworkResource(String url, ErrorCallback error) {
    NetworkImage networkImage = NetworkImage(
      url,
    );
    final ImageStream stream = networkImage.resolve(ImageConfiguration.empty);
    stream.addListener(
      ImageStreamListener((info, call) {
        // Image loaded.
        setState(() {
          imageProvider = networkImage;
        });
      }, onError: (ex, stacktrace) {
        // Exception.
        error();
      }),
    );
  }

  /// Try to fetch the image form a native asset resource.
  Future<void> resovleAssetResource(String url, ErrorCallback error) async {
    if (url.isEmpty) {
      error();
      return null;
    }
    final MethodChannel channel = NssIoc().use(NssChannels).dataChannel;
    var data = await channel
        .invokeMethod<Uint8List>('image_resource', {'url': url}).timeout(
            Duration(seconds: 4), onTimeout: () {
      // Timeout
      return null;
    }).catchError((error) {
      // Error
      return null;
    });
    if (data == null) {
      error();
    }
    setState(() {
      imageProvider = MemoryImage(data);
    });
  }

  /// Vary resource type.
  ImageSource getImageSource(String url) {
    return Linkify.isValidUrl(url) ? ImageSource.web : ImageSource.asset;
  }
}

class ImageWidget extends StatefulWidget {
  final NssWidgetData data;

  const ImageWidget({Key key, this.data}) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends ImageWidgetState<ImageWidget> {
  @override
  void initState() {
    super.initState();
    getImage(widget.data.bind ?? widget.data.url, widget.data.fallback);
  }

  @override
  Widget build(BuildContext context) {
    final borderSize = getStyle(Styles.borderSize, data: widget.data);
    final borderColor = getStyle(Styles.borderColor, data: widget.data);
    final cornerRadius = getStyle(Styles.cornerRadius, data: widget.data);

    return Padding(
      padding: getStyle(Styles.margin, data: widget.data),
      child: sizeIfNeeded(
        widget.data,
        Consumer<BindingModel>(
          builder: (context, bindings, child) {
            return Material(
              borderRadius: BorderRadius.circular(cornerRadius),
              color: Colors.transparent,
              elevation: getStyle(Styles.elevation, data: widget.data),
              child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                        width: borderSize,
                      ),
                      borderRadius: BorderRadius.circular(
                        cornerRadius,
                      ),
                      color: getStyle(Styles.background, data: widget.data),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.fill),
                    ),
                  ) ??
                  Container(),
            );
          },
        ),
      ),
    );
  }
}

final Uint8List kTransparentImage = new Uint8List.fromList(<int>[
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
  0xAE,
]);
