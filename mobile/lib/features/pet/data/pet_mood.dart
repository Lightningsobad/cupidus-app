/// The five moods the backend can report from `GET /pets/status`
/// (`pets.service.ts` `computeMood`). Unknown or missing wire values fall back
/// to [content] so a future backend mood never crashes the screen.
enum PetMood {
  ecstatic,
  happy,
  content,
  sad,
  sick;

  static PetMood fromWire(String? value) => switch (value) {
        'ecstatic' => PetMood.ecstatic,
        'happy' => PetMood.happy,
        'content' => PetMood.content,
        'sad' => PetMood.sad,
        'sick' => PetMood.sick,
        _ => PetMood.content,
      };
}

/// The `Bun Sprite` component states this story is allowed to render.
/// The component declares a sixth `sleep` state that has no backend
/// equivalent (`ux/uiux-spec.md` §3) and must never be produced here.
enum BunSpriteState {
  inlove,
  happy,
  neutral,
  sulk,
  sick;

  static BunSpriteState fromMood(PetMood mood) => switch (mood) {
        PetMood.ecstatic => BunSpriteState.inlove,
        PetMood.happy => BunSpriteState.happy,
        PetMood.content => BunSpriteState.neutral,
        PetMood.sad => BunSpriteState.sulk,
        PetMood.sick => BunSpriteState.sick,
      };
}
