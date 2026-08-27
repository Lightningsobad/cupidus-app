export interface EmojiItemDefinition {
    id: string;
    nameVi: string;
    nameEn: string;
    code: string;
    emotion: string; // e.g. 'happy', 'laugh', 'love', 'kiss', 'wink', 'cool', 'shy', 'pout', 'angry', 'plead', 'cry', 'shock', 'think', 'sleep', 'hug', 'party', 'sweat', 'sick', 'speechless', 'gift'
    svgIcon?: string;
    keywords: string[];
}

export interface EmojiPackDefinition {
    id: string;
    nameVi: string;
    nameEn: string;
    tagVi: string;
    tagEn: string;
    storyVi: string;
    storyEn: string;
    price: number;
    badge?: 'new' | 'hot' | 'popular' | 'cute' | 'limited';
    icon: string; // Preview icon / character symbol
    bannerGradient: string[];
    itemCount: number;
    emojis: EmojiItemDefinition[];
}

export const EMOJI_CATALOG: EmojiPackDefinition[] = [
    {
        id: 'mochi-cat',
        nameVi: 'Mèo Béo Mochi',
        nameEn: 'Chubby Mochi Cat',
        tagVi: 'dễ thương · 20 biểu cảm chuẩn',
        tagEn: 'ultra cute · 20 core expressions',
        price: 0, // Starter pack / Free
        badge: 'popular',
        icon: '🐱',
        bannerGradient: ['#FFF0F5', '#FFD1DC', '#FF9AA2'],
        itemCount: 20,
        storyVi: 'Chú mèo Mochi tròn xoe đáng yêu với trọn bộ 20 biểu cảm từ ngọt ngào đến phụng phịu, giúp bạn truyền tải mọi cung bậc cảm xúc đến nửa kia.',
        storyEn: 'Cute chubby Mochi Cat with a full set of 20 emotional expressions from sweet love to funny sulking for every couple moment.',
        emojis: [
            { id: 'mochi_cat_happy', nameVi: 'Cười Vui Vẻ', nameEn: 'Happy Smile', code: ':mochi_cat_happy:', emotion: 'happy', keywords: ['cười', 'vui', 'happy', 'smile'] },
            { id: 'mochi_cat_laugh', nameVi: 'Cười Ra Nước Mắt', nameEn: 'Laughing Tears', code: ':mochi_cat_laugh:', emotion: 'laugh', keywords: ['cười lăn', 'hài', 'rofl', 'laugh'] },
            { id: 'mochi_cat_love', nameVi: 'Mắt Trái Tim', nameEn: 'Heart Eyes', code: ':mochi_cat_love:', emotion: 'love', keywords: ['yêu', 'thích', 'love', 'heart'] },
            { id: 'mochi_cat_kiss', nameVi: 'Bắn Tim Hôn Gió', nameEn: 'Blowing Kiss', code: ':mochi_cat_kiss:', emotion: 'kiss', keywords: ['hôn', 'bắn tim', 'kiss', 'chu'] },
            { id: 'mochi_cat_wink', nameVi: 'Nháy Mắt Lè Lưỡi', nameEn: 'Wink & Tongue', code: ':mochi_cat_wink:', emotion: 'wink', keywords: ['lè lưỡi', 'trêu', 'wink', 'silly'] },
            { id: 'mochi_cat_cool', nameVi: 'Ngầu Kính Râm', nameEn: 'Cool Sunglasses', code: ':mochi_cat_cool:', emotion: 'cool', keywords: ['ngầu', 'kính râm', 'cool', 'swag'] },
            { id: 'mochi_cat_shy', nameVi: 'Đỏ Mặt Ngại Ngùng', nameEn: 'Blushing Shy', code: ':mochi_cat_shy:', emotion: 'shy', keywords: ['ngại', 'đỏ mặt', 'shy', 'blush'] },
            { id: 'mochi_cat_pout', nameVi: 'Dỗi Hờn Phồng Má', nameEn: 'Pouting Face', code: ':mochi_cat_pout:', emotion: 'pout', keywords: ['dỗi', 'hờn', 'pout', 'sulking'] },
            { id: 'mochi_cat_angry', nameVi: 'Tức Giận Bốc Hỏa', nameEn: 'Angry Smoke', code: ':mochi_cat_angry:', emotion: 'angry', keywords: ['tức', 'giận', 'angry', 'fire'] },
            { id: 'mochi_cat_plead', nameVi: 'Tủi Thân Mắt Ướt', nameEn: 'Pleading Eyes', code: ':mochi_cat_plead:', emotion: 'plead', keywords: ['tủi thân', 'năn nỉ', 'plead', 'puppy eyes'] },
            { id: 'mochi_cat_cry', nameVi: 'Khóc Ròng Nước Mắt', nameEn: 'Crying Waterfall', code: ':mochi_cat_cry:', emotion: 'cry', keywords: ['khóc', 'buồn', 'cry', 'sobbing'] },
            { id: 'mochi_cat_shock', nameVi: 'Hết Hồn Kinh Ngạc', nameEn: 'Shocked Gasp', code: ':mochi_cat_shock:', emotion: 'shock', keywords: ['hết hồn', 'sốc', 'shock', 'omg'] },
            { id: 'mochi_cat_think', nameVi: 'Suy Nghĩ Trầm Tư', nameEn: 'Thinking', code: ':mochi_cat_think:', emotion: 'think', keywords: ['nghĩ', 'thắc mắc', 'think', 'hmm'] },
            { id: 'mochi_cat_sleep', nameVi: 'Ngủ Say Khò Khò', nameEn: 'Sleeping Snore', code: ':mochi_cat_sleep:', emotion: 'sleep', keywords: ['ngủ', 'khò', 'sleep', 'zzz'] },
            { id: 'mochi_cat_hug', nameVi: 'Ôm Chặt Dỗ Dành', nameEn: 'Warm Hug', code: ':mochi_cat_hug:', emotion: 'hug', keywords: ['ôm', 'dỗ', 'hug', 'cuddle'] },
            { id: 'mochi_cat_party', nameVi: 'Ăn Mừng Tiệc Tùng', nameEn: 'Party Celebrate', code: ':mochi_cat_party:', emotion: 'party', keywords: ['tiệc', 'chúc mừng', 'party', 'celebrate'] },
            { id: 'mochi_cat_sweat', nameVi: 'Cười Trừ Toát Mồ Hôi', nameEn: 'Sweat Grin', code: ':mochi_cat_sweat:', emotion: 'sweat', keywords: ['ngượng', 'mồ hôi', 'sweat', 'oops'] },
            { id: 'mochi_cat_sick', nameVi: 'Ốm Sốt Cảm Lạnh', nameEn: 'Sick Fever', code: ':mochi_cat_sick:', emotion: 'sick', keywords: ['ốm', 'sốt', 'mệt', 'sick'] },
            { id: 'mochi_cat_speechless', nameVi: 'Cạn Lời Bất Lực', nameEn: 'Speechless Facepalm', code: ':mochi_cat_speechless:', emotion: 'speechless', keywords: ['cạn lời', 'chịu', 'facepalm', 'sigh'] },
            { id: 'mochi_cat_gift', nameVi: 'Tặng Quà Bất Ngờ', nameEn: 'Sweet Gift', code: ':mochi_cat_gift:', emotion: 'gift', keywords: ['quà', 'tặng', 'gift', 'present'] },
        ],
    },
    {
        id: 'baby-dino',
        nameVi: 'Khủng Long Nhí Dodo',
        nameEn: 'Playful Baby Dino',
        tagVi: 'tinh nghịch · 20 biểu cảm chuẩn',
        tagEn: 'super cute · 20 core expressions',
        price: 250,
        badge: 'hot',
        icon: '🦖',
        bannerGradient: ['#E8F5E9', '#C8E6C9', '#81C784'],
        itemCount: 20,
        storyVi: 'Khủng long xanh lá Dodo với đôi tay ngắn tủn mủn siêu ngố, sẵn sàng thở ra lửa tình yêu và làm nũng bên bạn cả ngày.',
        storyEn: 'Playful green baby Dino Dodo with cute tiny arms, breathing love fire and cheering up your partner with 20 delightful expressions.',
        emojis: [
            { id: 'dino_happy', nameVi: 'Nhe Răng Cười Tít', nameEn: 'Big Grin', code: ':dino_happy:', emotion: 'happy', keywords: ['cười', 'vui', 'grin', 'happy'] },
            { id: 'dino_laugh', nameVi: 'Cười Đập Đuôi', nameEn: 'Tail Thumping Laugh', code: ':dino_laugh:', emotion: 'laugh', keywords: ['cười to', 'vui nhộn', 'laugh', 'rofl'] },
            { id: 'dino_love', nameVi: 'Mắt Tim Lơ Lửng', nameEn: 'Floating Heart Eyes', code: ':dino_love:', emotion: 'love', keywords: ['tim', 'yêu', 'love', 'hearts'] },
            { id: 'dino_kiss', nameVi: 'Thở Lửa Trái Tim', nameEn: 'Fire Heart Kiss', code: ':dino_kiss:', emotion: 'kiss', keywords: ['thở lửa', 'hôn', 'fire', 'kiss'] },
            { id: 'dino_wink', nameVi: 'Nghiêng Đầu Lè Lưỡi', nameEn: 'Cheeky Tongue', code: ':dino_wink:', emotion: 'wink', keywords: ['lè lưỡi', 'ngố', 'tongue', 'tease'] },
            { id: 'dino_cool', nameVi: 'Đeo Kính Khoanh Tay', nameEn: 'Boss Sunglasses', code: ':dino_cool:', emotion: 'cool', keywords: ['chất', 'ngầu', 'sunglasses', 'cool'] },
            { id: 'dino_shy', nameVi: 'Che Mắt Ngượng Ngùng', nameEn: 'Cover Eyes Shy', code: ':dino_shy:', emotion: 'shy', keywords: ['ngại', 'đỏ mặt', 'shy', 'peek'] },
            { id: 'dino_pout', nameVi: 'Dậm Chân Giận Dỗi', nameEn: 'Stomping Pout', code: ':dino_pout:', emotion: 'pout', keywords: ['dỗi', 'dậm chân', 'pout', 'angry'] },
            { id: 'dino_angry', nameVi: 'Phì Lửa Bùng Nổ', nameEn: 'Flaming Rage', code: ':dino_angry:', emotion: 'angry', keywords: ['tức', 'phì lửa', 'rage', 'fire'] },
            { id: 'dino_plead', nameVi: 'Ôm Vỏ Trứng Rưng Rưng', nameEn: 'Eggshell Plead', code: ':dino_plead:', emotion: 'plead', keywords: ['xin', 'rưng rưng', 'plead', 'egg'] },
            { id: 'dino_cry', nameVi: 'Há Mồm Phun Nước Mắt', nameEn: 'Fountain Tears', code: ':dino_cry:', emotion: 'cry', keywords: ['khóc to', 'nước mắt', 'cry', 'sob'] },
            { id: 'dino_shock', nameVi: 'Giật Nảy Rơi Mũ', nameEn: 'Hat Drop Shock', code: ':dino_shock:', emotion: 'shock', keywords: ['hết hồn', 'giật mình', 'shock', 'omg'] },
            { id: 'dino_think', nameVi: 'Gãi Đầu Nhìn Trời', nameEn: 'Head Scratch Think', code: ':dino_think:', emotion: 'think', keywords: ['nghĩ', 'thắc mắc', 'think', 'wonder'] },
            { id: 'dino_sleep', nameVi: 'Bóng Nước Mũi Ngủ Khò', nameEn: 'Snoozing Bubble', code: ':dino_sleep:', emotion: 'sleep', keywords: ['ngủ', 'bóng mũi', 'sleep', 'zzz'] },
            { id: 'dino_hug', nameVi: 'Tay Ngắn Cố Ôm', nameEn: 'Tiny Arm Hug', code: ':dino_hug:', emotion: 'hug', keywords: ['ôm', 'tay ngắn', 'hug', 'cuddle'] },
            { id: 'dino_party', nameVi: 'Vung Pháo Kim Tuyến', nameEn: 'Confetti Party', code: ':dino_party:', emotion: 'party', keywords: ['ăn mừng', 'pháo', 'party', 'confetti'] },
            { id: 'dino_sweat', nameVi: 'Gãi Lưng Toát Mồ Hôi', nameEn: 'Nervous Back Scratch', code: ':dino_sweat:', emotion: 'sweat', keywords: ['mồ hôi', 'gượng', 'sweat', 'nervous'] },
            { id: 'dino_sick', nameVi: 'Dán Miếng Hạ Sốt', nameEn: 'Cooling Patch Sick', code: ':dino_sick:', emotion: 'sick', keywords: ['sốt', 'ốm', 'sick', 'patch'] },
            { id: 'dino_speechless', nameVi: 'Nằm Bẹp Bất Lực', nameEn: 'Flat On Floor', code: ':dino_speechless:', emotion: 'speechless', keywords: ['bất lực', 'chịu', 'flat', 'done'] },
            { id: 'dino_gift', nameVi: 'Đội Hộp Quà Tặng Bae', nameEn: 'Head Gift Delivery', code: ':dino_gift:', emotion: 'gift', keywords: ['quà', 'tặng bae', 'gift', 'present'] },
        ],
    },
];
