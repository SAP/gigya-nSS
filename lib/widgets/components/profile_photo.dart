import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/comm/moblie_channel.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/utils/error.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/components/image.dart';
import 'package:provider/provider.dart';

class ProfilePhotoWidget extends StatefulWidget {
  final NssWidgetData data;

  const ProfilePhotoWidget({Key? key, required this.data}) : super(key: key);

  @override
  _ProfilePhotoWidgetState createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends ImageWidgetState<ProfilePhotoWidget>
    with LocalizationMixin, VisibilityStateMixin {
  @override
  void initState() {
    super.initState();
    // Get image from profile binding or provided placeholder.
    var provider = Provider.of<BindingModel>(context, listen: false);
    provider.addListener(
      () {
        var imageURL = provider.getValue('profile.photoURL');
        debugPrint('notify changes with imageURL = $imageURL');
        getImage(imageURL, widget.data.defaultPlaceholder);
      },
    );

    registerVisibilityNotifier(context, widget.data, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderSize = getStyle(Styles.borderSize, data: widget.data);
    final borderColor = getStyle(Styles.borderColor, data: widget.data);
    final cornerRadius = getStyle(Styles.cornerRadius, data: widget.data);

    return SemanticsWrapperWidget(
      accessibility: widget.data.accessibility,
      child: Padding(
        padding: getStyle(Styles.margin, data: widget.data),
        child: NssCustomSizeWidget(
          data: widget.data,
          child: Consumer<BindingModel>(
            builder: (context, bindings, child) {
              return Material(
                borderRadius: BorderRadius.circular(cornerRadius),
                color: Colors.transparent,
                elevation: getStyle(Styles.elevation, data: widget.data),
                child: Stack(
                  children: <Widget>[
                    Opacity(
                      opacity: getStyle(Styles.opacity, data: widget.data),
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
                      ),
                    ),
                    InkWell(
                        borderRadius: BorderRadius.circular(
                          cornerRadius,
                        ),
                        onTap:
                            widget.data.allowUpload! ? _onProfileImageTap : null)
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Click trigger for widget. Will direct the native platform to present the selection.
  /// On selection data will be set in the profile but not published.
  /// Binary data is also needed in order to display the updated image.
  void _onProfileImageTap() async {
    debugPrint('_onProfileImageTap');
    final NssChannel channel = NssIoc().use(NssChannels).dataChannel;
    var data = await channel.invokeMethod<dynamic>('pick_image', {
      'text': widget.data.textKey
    }).timeout(Duration(minutes: 2), onTimeout: () {
      // Timeout
      engineLogger!.d('timeout');
    }).catchError((error) {
      engineLogger!.d('Data error with: ${error.toString()}');
      // Error
      handleDataErrors(error.code);
      return null;
    });
    if (data == null) {
      // Error fetching image data.
      engineLogger!.d('Error fetching native image data');
    }
    engineLogger!.d('data: ${data}');

    setState(() {
      if (kIsWeb) {
        List<int> intList = data.values.toList().cast<int>();

        imageProvider = MemoryImage(Uint8List.fromList(intList));
      } else {
        imageProvider = MemoryImage(data);
      }
    });
  }

  /// Handle specific widget errors.
  void handleDataErrors(String? code) {
    var provider = Provider.of<ScreenViewModel>(context, listen: false);
    switch (code) {
      case "500":
        // General image upload error.
        provider
            .setError(localizedStringFor(ErrorUtils.profileErrorImageUpload));
        break;
      case "413004":
        // Image size error.
        provider.setError(localizedStringFor(ErrorUtils.profileErrorImageSize));
        break;
    }
  }
}
