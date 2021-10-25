import 'package:json_annotation/json_annotation.dart';

part 'reminders.g.dart';

@JsonSerializable()
class Reminders {
	bool? useDefault;

	Reminders({this.useDefault});

	factory Reminders.fromJson(Map<String, dynamic> json) {
		return _$RemindersFromJson(json);
	}

	Map<String, dynamic> toJson() => _$RemindersToJson(this);
}
