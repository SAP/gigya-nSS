import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api.g.dart';

@JsonSerializable(anyMap: true)
class ApiBaseResult {
  int statusCode;
  int errorCode;
  String callId;
  String errorMessage;

  Map<String, dynamic> data;

  ApiBaseResult({this.statusCode, this.callId, this.errorMessage, this.data, this.errorCode});

  factory ApiBaseResult.fromJson(Map<String, dynamic> json) => _$ApiBaseResultFromJson(json);

  Map<String, dynamic> toJson() => _$ApiBaseResultToJson(this);

  /// check the result status.
  bool isSuccess() => errorCode == 0;

  factory ApiBaseResult.platformException(PlatformException error) {
    return ApiBaseResult(
      statusCode: 500,
      errorCode: int.parse(error.code),
      errorMessage: error.message,
      data: error.details.cast<String, dynamic>(),
    );
  }
}
