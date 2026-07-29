/**
 * Event emitted when a pet interaction reaches a milestone threshold.
 * Used by TimelineService to auto-create milestone timeline entries (H2 fix).
 */
export class PetMilestoneReachedEvent {
    constructor(
        public readonly coupleId: string,
        public readonly petName: string,
        public readonly milestone: number,
        public readonly level: number,
    ) { }
}
