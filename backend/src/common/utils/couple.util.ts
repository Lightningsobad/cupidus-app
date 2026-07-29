/**
 * Shared couple utility — extracts getCoupleId to avoid duplication (M3 fix)
 */
export function getCoupleId(userId: string, partnerId: string): string {
    return [userId, partnerId].sort().join(':');
}
