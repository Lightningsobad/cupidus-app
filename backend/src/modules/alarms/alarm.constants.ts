export const ALARM_EVENTS = {
    SET_ALARM: 'setAlarm',         // Requester sets time
    UPDATE_ALARM: 'updateAlarm',   // Requester updates alarm
    TOGGLE_ALARM: 'toggleAlarm',   // Requester requests toggle on/off
    DELETE_ALARM: 'deleteAlarm',   // Requester requests delete
    NEW_ALARM_REQUEST: 'newAlarmRequest', // Partner receives request
    CONFIRM_ALARM: 'confirmAlarm', // Partner accepts request
    REJECT_ALARM: 'rejectAlarm',   // Partner rejects request
    ALARM_SCHEDULED: 'alarmScheduled', // Both notified it's on
    ALARM_DELETED: 'alarmDeleted', // Alarm removed
    TRIGGER_ALARM: 'triggerAlarm', // Server tells clients to RING
    STOP_ALARM: 'stopAlarm',       // Client slides to stop
    ALARM_STOPPED_BY_PARTNER: 'alarmStoppedByPartner', // Notify other
    ALARM_FULLY_STOPPED: 'alarmFullyStopped', // All stopped
};
