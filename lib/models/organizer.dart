import 'package:json_annotation/json_annotation.dart';

part 'organizer.g.dart';

@JsonSerializable()
class Organizer {
	String? email;
	bool? self;

	Organizer({this.email, this.self});

	factory Organizer.fromJson(Map<String, dynamic> json) {
		return _$OrganizerFromJson(json);
	}

	Map<String, dynamic> toJson() => _$OrganizerToJson(this);
}
