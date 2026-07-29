//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_timeline_event_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateTimelineEventDto {
  /// Returns a new [CreateTimelineEventDto] instance.
  CreateTimelineEventDto({

    required  this.title,

     this.description,

     this.photoUrl,

     this.icon,

     this.type,

     this.date,
  });

      /// Event title
  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



      /// Event description
  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



      /// Photo URL associated with the event
  @JsonKey(
    
    name: r'photoUrl',
    required: false,
    includeIfNull: false,
  )


  final String? photoUrl;



      /// Event icon name
  @JsonKey(
    
    name: r'icon',
    required: false,
    includeIfNull: false,
  )


  final String? icon;



      /// Event type
  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final CreateTimelineEventDtoTypeEnum? type;



      /// Date of the event (ISO string)
  @JsonKey(
    
    name: r'date',
    required: false,
    includeIfNull: false,
  )


  final String? date;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateTimelineEventDto &&
      other.title == title &&
      other.description == description &&
      other.photoUrl == photoUrl &&
      other.icon == icon &&
      other.type == type &&
      other.date == date;

    @override
    int get hashCode =>
        title.hashCode +
        description.hashCode +
        photoUrl.hashCode +
        icon.hashCode +
        type.hashCode +
        date.hashCode;

  factory CreateTimelineEventDto.fromJson(Map<String, dynamic> json) => _$CreateTimelineEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTimelineEventDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Event type
enum CreateTimelineEventDtoTypeEnum {
    /// Event type
@JsonValue(r'milestone')
milestone(r'milestone'),
    /// Event type
@JsonValue(r'memory')
memory(r'memory'),
    /// Event type
@JsonValue(r'system')
system(r'system');

const CreateTimelineEventDtoTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


