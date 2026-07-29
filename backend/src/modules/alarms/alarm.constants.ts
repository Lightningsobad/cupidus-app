export const ALARM_EVENTS = {
    SET_ALARM: 'setAlarm',         // Requester sets time
    NEW_ALARM_REQUEST: 'newAlarmRequest', // Partner receives request
    CONFIRM_ALARM: 'confirmAlarm', // Partner accepts
    ALARM_SCHEDULED: 'alarmScheduled', // Both notified it's on
    REJECT_ALARM: 'rejectAlarm', // Partner rejects
    TRIGGER_ALARM: 'triggerAlarm', // Server tells clients to RING (backup to local)
    STOP_ALARM: 'stopAlarm',       // Client slides to stop
    ALARM_STOPPED_BY_PARTNER: 'alarmStoppedByPartner', // Notify other
    ALARM_FULLY_STOPPED: 'alarmFullyStopped', // All stopped
};
