// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarItem _$CalendarItemFromJson(Map<String, dynamic> json) => CalendarItem(
      id: json['id'] as String?,
      summary: json['summary'] as String?,
      description: json['description'] as String?,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      htmlLink: json['htmlLink'] as String?,
      event: json['event'] == null
          ? null
          : Event.fromJson(json['event'] as Map<String, dynamic>),
      notifications: json['notifications'] as List<dynamic>?,
    );

Map<String, dynamic> _$CalendarItemToJson(CalendarItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'summary': instance.summary,
      'description': instance.description,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'htmlLink': instance.htmlLink,
      'event': instance.event,
      'notifications': instance.notifications,
    };
