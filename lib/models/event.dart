import 'package:json_annotation/json_annotation.dart';

import 'creator.dart';
import 'end.dart';
import 'organizer.dart';
import 'reminders.dart';
import 'start.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
	String? kind;
	String? etag;
	String? id;
	String? status;
	String? htmlLink;
	String? created;
	String? updated;
	String? summary;
	String? description;
	Creator? creator;
	Organizer? organizer;
	Start? start;
	End? end;
	@JsonKey(name: 'iCalUID') 
	String? iCalUid;
	int? sequence;
	Reminders? reminders;
	String? eventType;

	Event({
		this.kind, 
		this.etag, 
		this.id, 
		this.status, 
		this.htmlLink, 
		this.created, 
		this.updated, 
		this.summary, 
		this.description, 
		this.creator, 
		this.organizer, 
		this.start, 
		this.end, 
		this.iCalUid, 
		this.sequence, 
		this.reminders, 
		this.eventType, 
	});

	factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

	Map<String, dynamic> toJson() => _$EventToJson(this);
}
