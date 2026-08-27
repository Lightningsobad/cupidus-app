const { io } = require('socket.io-client');

const SERVER_URL = 'http://127.0.0.1:21020';
const XUAN_ID = '670c6070-2754-42ed-8969-ecb81a8eecfe';
const GIAC_CANH_ID = '2258ddf6-5a18-420a-9509-676c71ce898f';

async function run() {
    const eventType = process.argv[2] || 'emoji_storm';
    console.log(`Connecting to ${SERVER_URL} to test event: ${eventType}...`);

    const socket = io(SERVER_URL, {
        transports: ['websocket'],
    });

    socket.on('connect', () => {
        console.log('Connected to socket server.');

        if (eventType === 'emoji_storm') {
            console.log('Emitting chat:emoji_storm to Giác Cảnh:', GIAC_CANH_ID);
            socket.emit('chat:emojiStormReceived', {
                room: GIAC_CANH_ID,
                senderId: XUAN_ID,
                penalty: 'emoji_storm',
            });
            // Also emit directly via gateway handler
            socket.emit('in_app:action', {
                room: GIAC_CANH_ID,
                actionType: 'chat:emojiStormReceived',
                data: {
                    senderId: XUAN_ID,
                    penalty: 'emoji_storm',
                },
            });
        } else if (eventType === 'alarm_ring') {
            console.log('Emitting alarm:triggerAlarm to Giác Cảnh:', GIAC_CANH_ID);
            socket.emit('in_app:action', {
                room: GIAC_CANH_ID,
                actionType: 'alarm:triggerAlarm',
                data: {
                    title: '⏰ BÁO THỨC ĐÔI ĐANG REO! ⏰',
                    message: 'Xuan và Giác Cảnh cùng dậy đón bình minh nào! ☀️',
                },
            });
        } else if (eventType === 'pet_levelup') {
            console.log('Emitting pet:interacted to Giác Cảnh:', GIAC_CANH_ID);
            socket.emit('in_app:action', {
                room: GIAC_CANH_ID,
                actionType: 'pet:interacted',
                data: {
                    isLevelUp: true,
                    pet: {
                        name: 'Bún',
                        happiness: 100,
                    },
                },
            });
        } else if (eventType === 'ghost_request') {
            console.log('Emitting ghost_config:requested to Giác Cảnh:', GIAC_CANH_ID);
            socket.emit('in_app:action', {
                room: GIAC_CANH_ID,
                actionType: 'ghost_config:requested',
                data: {
                    id: 'ghost-test-123',
                    thresholdMinutes: 15,
                    penalty: 'emoji_storm',
                },
            });
        }

        setTimeout(() => {
            console.log('Done emitting event.');
            socket.disconnect();
            process.exit(0);
        }, 1200);
    });

    socket.on('connect_error', (err) => {
        console.error('Socket error:', err);
        process.exit(1);
    });
}

run();
