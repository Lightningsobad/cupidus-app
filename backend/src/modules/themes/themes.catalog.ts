export interface ThemeGradientConfig {
    begin: [number, number];
    end: [number, number];
    colors: string[];
    stops?: number[];
}

export interface ThemeParticleConfig {
    enabled: boolean;
    shape: 'star' | 'circle' | 'petal' | 'bokeh' | 'firefly' | 'dew' | 'bubble' | 'spark' | 'snowflake' | 'snow';
    count: number;
    minSize: number;
    maxSize: number;
    minSpeed: number;
    maxSpeed: number;
    minOpacity: number;
    maxOpacity: number;
    colors: string[];
    directionDegrees: number;
    swayAmplitude?: number;
    twinklePeriodMs?: number;
}

export interface ThemeSpecialFXConfig {
    hasShootingStars?: boolean;
    shootingStarIntervalMs?: number;
    hasConstellationLines?: boolean;
    hasNeonFlicker?: boolean;
    nightDimming?: boolean;
}

export interface ThemeTouchReactionConfig {
    type: 'ripple' | 'ember' | 'wind_push' | 'water_wave' | 'spark' | 'bubble_pop' | 'star_trace';
    color: string;
    durationMs: number;
}

export interface ThemeFXConfig {
    type: string;
    particles: ThemeParticleConfig;
    specialFX?: ThemeSpecialFXConfig;
    touchReaction?: ThemeTouchReactionConfig;
}

export interface ThemeDefinition {
    id: string;
    nameVi: string;
    nameEn: string;
    tagVi: string;
    tagEn: string;
    storyVi: string;
    storyEn: string;
    price: number;
    swatch: string;
    gradient: ThemeGradientConfig;
    dots: string[];
    palette: { hex: string; name: string }[];
    badge?: string;
    isLight?: boolean;
    fxConfig: ThemeFXConfig;
}

export const THEME_CATALOG: ThemeDefinition[] = [
    {
        id: 'nebula',
        nameVi: 'Tinh Vân',
        nameEn: 'Nebula',
        tagVi: 'mặc định · dịu mắt ban đêm',
        tagEn: 'default · easy at night',
        price: 0,
        swatch: 'linear-gradient(150deg,#3A2B6B,#8B5FCF 52%,#FF7FB6)',
        gradient: {
            begin: [-1.0, -1.0],
            end: [1.0, 1.0],
            colors: ['#3A2B6B', '#8B5FCF', '#FF7FB6'],
        },
        dots: ['#B78CF5', '#FF7FB6', '#79E2CD'],
        palette: [
            { hex: '#241B42', name: 'Surface' },
            { hex: '#B78CF5', name: 'Lilac' },
            { hex: '#FF7FB6', name: 'Pink' },
            { hex: '#79E2CD', name: 'Mint' },
            { hex: '#FFF6FB', name: 'Cotton' },
        ],
        storyVi: 'Bản gốc của Cupid: nền tím than, sao lấp lánh và hồng pastel. Bé pet nào cũng hợp.',
        storyEn: "Cupid's original: deep violet, quiet stars, pastel pink. Every pet looks good in it.",
        fxConfig: {
            type: 'nebula',
            particles: {
                enabled: true,
                shape: 'star',
                count: 14,
                minSize: 3,
                maxSize: 6,
                minSpeed: 0.1,
                maxSpeed: 0.4,
                minOpacity: 0.25,
                maxOpacity: 1.0,
                colors: ['#FFFFFF', '#FFD9EA', '#CEB4FF'],
                directionDegrees: 45,
                twinklePeriodMs: 4000,
            },
            specialFX: {
                hasShootingStars: false,
                nightDimming: false,
            },
            touchReaction: {
                type: 'ripple',
                color: '#B78CF5',
                durationMs: 600,
            },
        },
    },
    {
        id: 'sunset',
        nameVi: 'Hoàng Hôn Đà Lạt',
        nameEn: 'Đà Lạt Sunset',
        tagVi: 'ấm · cho cặp yêu xa',
        tagEn: 'warm · for long distance',
        price: 320,
        swatch: 'linear-gradient(150deg,#4A2350,#C2508F 48%,#FFB067)',
        gradient: {
            begin: [-1.0, -1.0],
            end: [1.0, 1.0],
            colors: ['#4A2350', '#C2508F', '#FFB067'],
        },
        dots: ['#FF9576', '#FFC97E', '#C2508F'],
        badge: 'hot',
        palette: [
            { hex: '#33203F', name: 'Dusk' },
            { hex: '#C2508F', name: 'Rosé' },
            { hex: '#FF9576', name: 'Ember' },
            { hex: '#FFC97E', name: 'Butter' },
            { hex: '#FFF1E4', name: 'Cream' },
        ],
        storyVi: 'Màu của 5 giờ chiều trên đồi thông. Chat bubble chuyển sang cam ấm, đồng hồ hai múi giờ có nắng riêng.',
        storyEn: 'The colour of 5pm on a pine hill. Chat bubbles turn warm amber; the dual clock gets its own sunlight.',
        fxConfig: {
            type: 'sunset',
            particles: {
                enabled: true,
                shape: 'bokeh',
                count: 12,
                minSize: 4,
                maxSize: 10,
                minSpeed: 0.2,
                maxSpeed: 0.6,
                minOpacity: 0.2,
                maxOpacity: 0.8,
                colors: ['#FF9576', '#FFC97E', '#FFB067', '#FFE4A0'],
                directionDegrees: -90, // floating upwards
                swayAmplitude: 15,
            },
            specialFX: {
                nightDimming: false,
            },
            touchReaction: {
                type: 'ember',
                color: '#FF9576',
                durationMs: 700,
            },
        },
    },
    {
        id: 'sakura',
        nameVi: 'Mùa Hoa Anh Đào',
        nameEn: 'Sakura Season',
        tagVi: 'theo mùa · có hiệu ứng cánh hoa',
        tagEn: 'seasonal · petal effect',
        price: 480,
        swatch: 'linear-gradient(160deg,#5B3350,#E58AB0 46%,#FFD9E4)',
        gradient: {
            begin: [-1.0, -1.0],
            end: [1.0, 1.0],
            colors: ['#5B3350', '#E58AB0', '#FFD9E4'],
        },
        dots: ['#FF9EC4', '#FFD9E4', '#A57BC4'],
        badge: 'seasonal',
        palette: [
            { hex: '#3B2440', name: 'Bark' },
            { hex: '#E58AB0', name: 'Blossom' },
            { hex: '#FFD9E4', name: 'Petal' },
            { hex: '#A57BC4', name: 'Wisteria' },
            { hex: '#FFF7FA', name: 'Snow' },
        ],
        storyVi: 'Cánh hoa rơi chậm sau màn hình chính, mỗi lần cả hai check-in cùng ngày thì rơi dày hơn.',
        storyEn: 'Petals drift behind the home screen — and fall thicker on days you both check in.',
        fxConfig: {
            type: 'sakura',
            particles: {
                enabled: true,
                shape: 'petal',
                count: 18,
                minSize: 6,
                maxSize: 14,
                minSpeed: 0.5,
                maxSpeed: 1.2,
                minOpacity: 0.35,
                maxOpacity: 0.9,
                colors: ['#FF9EC4', '#FFD9E4', '#FFEBF1'],
                directionDegrees: 80,
                swayAmplitude: 28,
            },
            specialFX: {
                nightDimming: false,
            },
            touchReaction: {
                type: 'wind_push',
                color: '#FF9EC4',
                durationMs: 800,
            },
        },
    },
    {
        id: 'midnight',
        nameVi: 'Nửa Đêm',
        nameEn: 'Midnight',
        tagVi: 'tối sâu · dễ ngủ',
        tagEn: 'deep dark · sleep friendly',
        price: 260,
        swatch: 'linear-gradient(155deg,#0C1130,#1E3A6E 55%,#4F86C6)',
        gradient: {
            begin: [-1.0, -1.0],
            end: [1.0, 1.0],
            colors: ['#0C1130', '#1E3A6E', '#4F86C6'],
        },
        dots: ['#4F86C6', '#8FB8E8', '#2C1E5E'],
        palette: [
            { hex: '#0C1130', name: 'Ink' },
            { hex: '#1E3A6E', name: 'Deep' },
            { hex: '#4F86C6', name: 'Tide' },
            { hex: '#8FB8E8', name: 'Haze' },
            { hex: '#E8F0FF', name: 'Moon' },
        ],
        storyVi: 'Dành cho những cuộc gọi 2 giờ sáng. Độ sáng tự hạ sau 23h, báo thức chung chuyển sang xanh lạnh.',
        storyEn: 'Built for 2am calls. Brightness eases after 11pm and the synced alarm turns cold blue.',
        fxConfig: {
            type: 'midnight',
            particles: {
                enabled: true,
                shape: 'firefly',
                count: 7,
                minSize: 4,
                maxSize: 8,
                minSpeed: 0.2,
                maxSpeed: 0.5,
                minOpacity: 0.15,
                maxOpacity: 0.85,
                colors: ['#8FB8E8', '#A6CEFF', '#E8F0FF'],
                directionDegrees: -45,
                swayAmplitude: 20,
                twinklePeriodMs: 5000,
            },
            specialFX: {
                nightDimming: true,
            },
            touchReaction: {
                type: 'water_wave',
                color: '#4F86C6',
                durationMs: 900,
            },
        },
    },
    {
        id: 'matcha',
        nameVi: 'Trà Xanh',
        nameEn: 'Matcha',
        tagVi: 'mát · ít gây phân tâm',
        tagEn: 'calm · low distraction',
        price: 260,
        swatch: 'linear-gradient(150deg,#1E3A34,#3F7A63 52%,#A8D8B9)',
        gradient: {
            begin: [-1.0, -1.0],
            end: [1.0, 1.0],
            colors: ['#1E3A34', '#3F7A63', '#A8D8B9'],
        },
        dots: ['#79E2CD', '#A8D8B9', '#3F7A63'],
        palette: [
            { hex: '#16302A', name: 'Forest' },
            { hex: '#3F7A63', name: 'Leaf' },
            { hex: '#79E2CD', name: 'Mint' },
            { hex: '#A8D8B9', name: 'Sage' },
            { hex: '#F2FBF4', name: 'Rice' },
        ],
        storyVi: 'Không gradient chói, không hiệu ứng. Cặp nào hay cãi nhau lúc nửa đêm nên thử theme này.',
        storyEn: 'No loud gradients, no effects. Couples who argue at midnight should try this one.',
        fxConfig: {
            type: 'matcha',
            particles: {
                enabled: true,
                shape: 'dew',
                count: 5,
                minSize: 3,
                maxSize: 6,
                minSpeed: 0.1,
                maxSpeed: 0.3,
                minOpacity: 0.2,
                maxOpacity: 0.7,
                colors: ['#79E2CD', '#A8D8B9', '#F2FBF4'],
                directionDegrees: 90,
                swayAmplitude: 5,
            },
            specialFX: {
                nightDimming: false,
            },
            touchReaction: {
                type: 'water_wave',
                color: '#79E2CD',
                durationMs: 750,
            },
        },
    },
    {
        id: 'neon',
        nameVi: 'Đêm Sài Gòn',
        nameEn: 'Saigon Neon',
        tagVi: 'rực · hợp chụp thẻ kỷ niệm',
        tagEn: 'loud · great for cards',
        price: 420,
        swatch: 'linear-gradient(150deg,#1B0B2E,#B4249B 50%,#28D8D8)',
        gradient: {
            begin: [-1.0, -1.0],
            end: [1.0, 1.0],
            colors: ['#1B0B2E', '#B4249B', '#28D8D8'],
        },
        dots: ['#FF3D9A', '#28D8D8', '#B4249B'],
        badge: 'new',
        palette: [
            { hex: '#1B0B2E', name: 'Night' },
            { hex: '#B4249B', name: 'Magenta' },
            { hex: '#FF3D9A', name: 'Hot' },
            { hex: '#28D8D8', name: 'Cyan' },
            { hex: '#FFE7F6', name: 'Glow' },
        ],
        storyVi: 'Viền neon quanh thẻ kỷ niệm, tên hai đứa sáng như biển hiệu quán ăn đêm.',
        storyEn: 'Neon edges on every keepsake card, both your names lit like a late-night diner sign.',
        fxConfig: {
            type: 'neon',
            particles: {
                enabled: true,
                shape: 'spark',
                count: 16,
                minSize: 2,
                maxSize: 6,
                minSpeed: 0.8,
                maxSpeed: 2.0,
                minOpacity: 0.4,
                maxOpacity: 1.0,
                colors: ['#FF3D9A', '#28D8D8', '#B4249B', '#FFFFFF'],
                directionDegrees: 60,
            },
            specialFX: {
                hasNeonFlicker: true,
                nightDimming: false,
            },
            touchReaction: {
                type: 'spark',
                color: '#28D8D8',
                durationMs: 500,
            },
        },
    },
    {
        id: 'butter',
        nameVi: 'Bơ Sữa',
        nameEn: 'Butter Milk',
        tagVi: 'sáng · theme nền sáng đầu tiên',
        tagEn: 'light · our first light theme',
        price: 380,
        isLight: true,
        swatch: 'linear-gradient(150deg,#FFF3DC,#FFD79E 50%,#FFB6C9)',
        gradient: {
            begin: [-1.0, -1.0],
            end: [1.0, 1.0],
            colors: ['#FFF3DC', '#FFD79E', '#FFB6C9'],
        },
        dots: ['#FFC97E', '#FFAB93', '#8C6239'],
        palette: [
            { hex: '#FFF8EC', name: 'Milk' },
            { hex: '#FFD79E', name: 'Butter' },
            { hex: '#FFAB93', name: 'Peach' },
            { hex: '#8C6239', name: 'Cocoa' },
            { hex: '#4A3520', name: 'Ink' },
        ],
        storyVi: 'Nền sáng, chữ nâu sữa. Ban ngày ngoài nắng vẫn đọc được tin nhắn.',
        storyEn: 'Light surfaces, cocoa ink. Readable outdoors, even at noon.',
        fxConfig: {
            type: 'butter',
            particles: {
                enabled: true,
                shape: 'bubble',
                count: 10,
                minSize: 4,
                maxSize: 12,
                minSpeed: 0.3,
                maxSpeed: 0.7,
                minOpacity: 0.25,
                maxOpacity: 0.8,
                colors: ['#FFD79E', '#FFAB93', '#FFF8EC'],
                directionDegrees: -90,
                swayAmplitude: 12,
            },
            specialFX: {
                nightDimming: false,
            },
            touchReaction: {
                type: 'bubble_pop',
                color: '#FFAB93',
                durationMs: 600,
            },
        },
    },
    {
        id: 'starmap',
        nameVi: 'Bản Đồ Sao',
        nameEn: 'Star Map',
        tagVi: 'dựng theo ngày sinh hai đứa',
        tagEn: 'built from both birthdays',
        price: 640,
        swatch: 'linear-gradient(155deg,#141232,#37307A 48%,#9E8CF5)',
        gradient: {
            begin: [-1.0, -1.0],
            end: [1.0, 1.0],
            colors: ['#141232', '#37307A', '#9E8CF5'],
        },
        dots: ['#9E8CF5', '#FFE9A8', '#37307A'],
        badge: 'limited',
        palette: [
            { hex: '#141232', name: 'Void' },
            { hex: '#37307A', name: 'Orbit' },
            { hex: '#9E8CF5', name: 'Nova' },
            { hex: '#FFE9A8', name: 'Starlight' },
            { hex: '#EDEBFF', name: 'Dust' },
        ],
        storyVi: 'Nền là bầu trời đúng đêm hai đứa quen nhau. Cung hoàng đạo của cả hai được vẽ nối bằng một đường mảnh.',
        storyEn: 'The sky exactly as it looked the night you met, with both zodiac signs joined by a thin line.',
        fxConfig: {
            type: 'starmap',
            particles: {
                enabled: true,
                shape: 'star',
                count: 22,
                minSize: 2,
                maxSize: 7,
                minSpeed: 0.1,
                maxSpeed: 0.3,
                minOpacity: 0.3,
                maxOpacity: 1.0,
                colors: ['#FFE9A8', '#9E8CF5', '#EDEBFF', '#FFFFFF'],
                directionDegrees: 0,
                twinklePeriodMs: 3200,
            },
            specialFX: {
                hasShootingStars: true,
                shootingStarIntervalMs: 6500,
                hasConstellationLines: true,
                nightDimming: false,
            },
            touchReaction: {
                type: 'star_trace',
                color: '#FFE9A8',
                durationMs: 800,
            },
        },
    },
    {
        id: 'christmas',
        nameVi: 'Giáng Sinh Ấm Áp',
        nameEn: 'Cozy Christmas',
        tagVi: 'theo mùa · tuyết rơi & nến ấm',
        tagEn: 'seasonal · falling snow & warm glow',
        price: 390,
        swatch: 'linear-gradient(150deg,#122B1E,#8B2635 52%,#F4D06F)',
        gradient: {
            begin: [-1.0, -1.0],
            end: [1.0, 1.0],
            colors: ['#122B1E', '#4A1521', '#8B2635', '#F4D06F'],
        },
        dots: ['#F4D06F', '#E63946', '#2A9D8F'],
        badge: 'seasonal',
        palette: [
            { hex: '#0D1F15', name: 'Pine Forest' },
            { hex: '#8B2635', name: 'Crimson Red' },
            { hex: '#2A9D8F', name: 'Holly Green' },
            { hex: '#F4D06F', name: 'Warm Gold' },
            { hex: '#FFFBF2', name: 'Snow Cream' },
        ],
        storyVi: 'Bông tuyết trắng rơi nhè nhẹ, cây thông lung linh và ánh nến ấm áp xua tan cái lạnh mùa đông.',
        storyEn: 'Gentle falling snowflakes, twinkling pine trees and warm candlelight to warm your winter nights.',
        fxConfig: {
            type: 'christmas',
            particles: {
                enabled: true,
                shape: 'snowflake',
                count: 22,
                minSize: 3.5,
                maxSize: 9.0,
                minSpeed: 0.3,
                maxSpeed: 0.8,
                minOpacity: 0.35,
                maxOpacity: 0.95,
                colors: ['#FFFFFF', '#F4D06F', '#E0F2FE', '#FFE4E6'],
                directionDegrees: 80.0,
                swayAmplitude: 20.0,
                twinklePeriodMs: 3500,
            },
            specialFX: {
                nightDimming: false,
            },
            touchReaction: {
                type: 'spark',
                color: '#F4D06F',
                durationMs: 650,
            },
        },
    },
];
