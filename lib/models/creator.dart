import 'package:json_annotation/json_annotation.dart';

part 'creator.g.dart';

@JsonSerializable()
class Creator {
	String? email;
	bool? self;

	Creator({this.email, this.self});

	factory Creator.fromJson(Map<String, dynamic> json) {
		return _$CreatorFromJson(json);
	}

	Map<String, dynamic> toJson() => _$CreatorToJson(this);
}
