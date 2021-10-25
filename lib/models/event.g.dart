// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      kind: json['kind'] as String?,
      etag: json['etag'] as String?,
      id: json['id'] as String?,
      status: json['status'] as String?,
      htmlLink: json['htmlLink'] as String?,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
      summary: json['summary'] as String?,
      description: json['description'] as String?,
      creator: json['creator'] == null
          ? null
          : Creator.fromJson(json['creator'] as Map<String, dynamic>),
      organizer: json['organizer'] == null
          ? null
          : Organizer.fromJson(json['organizer'] as Map<String, dynamic>),
      start: json['start'] == null
          ? null
          : Start.fromJson(json['start'] as Map<String, dynamic>),
      end: json['end'] == null
          ? null
          : End.fromJson(json['end'] as Map<String, dynamic>),
      iCalUid: json['iCalUID'] as String?,
      sequence: json['sequence'] as int?,
      reminders: json['reminders'] == null
          ? null
          : Reminders.fromJson(json['reminders'] as Map<String, dynamic>),
      eventType: json['eventType'] as String?,
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'kind': instance.kind,
      'etag': instance.etag,
      'id': instance.id,
      'status': instance.status,
      'htmlLink': instance.htmlLink,
      'created': instance.created,
      'updated': instance.updated,
      'summary': instance.summary,
      'description': instance.description,
      'creator': instance.creator,
      'organizer': instance.organizer,
      'start': instance.start,
      'end': instance.end,
      'iCalUID': instance.iCalUid,
      'sequence': instance.sequence,
      'reminders': instance.reminders,
      'eventType': instance.eventType,
    };
