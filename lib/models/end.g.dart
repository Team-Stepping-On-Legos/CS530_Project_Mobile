// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'end.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

End _$EndFromJson(Map<String, dynamic> json) => End(
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$EndToJson(End instance) => <String, dynamic>{
      'dateTime': instance.dateTime?.toIso8601String(),
      'timeZone': instance.timeZone,
    };
