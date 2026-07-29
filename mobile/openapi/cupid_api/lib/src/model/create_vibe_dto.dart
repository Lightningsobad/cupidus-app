//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_vibe_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateVibeDto {
  /// Returns a new [CreateVibeDto] instance.
  CreateVibeDto({

    required  this.mood,

     this.note,
  });

      /// Mood to check-in
  @JsonKey(
    
    name: r'mood',
    required: true,
    includeIfNull: false,
  )


  final CreateVibeDtoMoodEnum mood;



      /// Optional mood note
  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateVibeDto &&
      other.mood == mood &&
      other.note == note;

    @override
    int get hashCode =>
        mood.hashCode +
        note.hashCode;

  factory CreateVibeDto.fromJson(Map<String, dynamic> json) => _$CreateVibeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateVibeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Mood to check-in
enum CreateVibeDtoMoodEnum {
    /// Mood to check-in
@JsonValue(r'happy')
happy(r'happy'),
    /// Mood to check-in
@JsonValue(r'sad')
sad(r'sad'),
    /// Mood to check-in
@JsonValue(r'angry')
angry(r'angry'),
    /// Mood to check-in
@JsonValue(r'horny')
horny(r'horny'),
    /// Mood to check-in
@JsonValue(r'tired')
tired(r'tired');

const CreateVibeDtoMoodEnum(this.value);

final String value;

@override
String toString() => value;
}


