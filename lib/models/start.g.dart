// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Start _$StartFromJson(Map<String, dynamic> json) => Start(
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$StartToJson(Start instance) => <String, dynamic>{
      'dateTime': instance.dateTime?.toIso8601String(),
      'timeZone': instance.timeZone,
    };
