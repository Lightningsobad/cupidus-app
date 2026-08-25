export type DailyTipTint = 'mint' | 'pink' | 'amber' | 'lilac' | 'peach';

export type DailyTipIcon =
  | 'videocam'
  | 'block'
  | 'local_cafe'
  | 'nightlight'
  | 'favorite'
  | 'chat_bubble'
  | 'savings'
  | 'self_improvement';

export interface DailyTip {
  id: string;
  icon: DailyTipIcon;
  tint: DailyTipTint;
  vi: {
    title: string;
    body: string;
  };
}

export const DAILY_TIPS: readonly DailyTip[] = [
  {
    id: 'tip-01',
    icon: 'videocam',
    tint: 'mint',
    vi: {
      title: 'Gọi video 10 phút',
      body: 'Dành 10 phút gọi video để kể cho nhau nghe một chuyện vui trong ngày.',
    },
  },
  {
    id: 'tip-02',
    icon: 'block',
    tint: 'pink',
    vi: {
      title: 'Tạm dừng tranh luận',
      body: 'Nếu thấy giọng điệu căng thẳng, hãy tạm dừng 5 phút trước khi nói tiếp.',
    },
  },
  {
    id: 'tip-03',
    icon: 'local_cafe',
    tint: 'amber',
    vi: {
      title: 'Hẹn cà phê cuối tuần',
      body: 'Rủ nhau một buổi cà phê không điện thoại vào cuối tuần này.',
    },
  },
  {
    id: 'tip-04',
    icon: 'nightlight',
    tint: 'lilac',
    vi: {
      title: 'Chúc ngủ ngon sớm hơn',
      body: 'Nhắn tin chúc ngủ ngon sớm hơn thường lệ để đối phương thấy được quan tâm.',
    },
  },
  {
    id: 'tip-05',
    icon: 'favorite',
    tint: 'peach',
    vi: {
      title: 'Nói lời cảm ơn cụ thể',
      body: 'Cảm ơn đối phương về một việc cụ thể họ đã làm trong tuần này.',
    },
  },
  {
    id: 'tip-06',
    icon: 'chat_bubble',
    tint: 'mint',
    vi: {
      title: 'Hỏi han không phán xét',
      body: 'Hỏi một câu về cảm xúc của đối phương và chỉ lắng nghe, không góp ý.',
    },
  },
  {
    id: 'tip-07',
    icon: 'savings',
    tint: 'amber',
    vi: {
      title: 'Bàn kế hoạch chi tiêu',
      body: 'Cùng thống nhất một khoản chi tiêu chung sắp tới để tránh hiểu lầm.',
    },
  },
  {
    id: 'tip-08',
    icon: 'self_improvement',
    tint: 'lilac',
    vi: {
      title: 'Cho nhau không gian riêng',
      body: 'Tôn trọng thời gian riêng của đối phương thay vì nhắn tin liên tục.',
    },
  },
  {
    id: 'tip-09',
    icon: 'block',
    tint: 'peach',
    vi: {
      title: 'Tránh so sánh với người khác',
      body: 'Tránh nhắc đến chuyện tình cảm của cặp đôi khác trong lúc trò chuyện.',
    },
  },
  {
    id: 'tip-10',
    icon: 'videocam',
    tint: 'pink',
    vi: {
      title: 'Xem chung một bộ phim',
      body: 'Chọn một bộ phim để cùng xem, dù đang ở xa nhau.',
    },
  },
  {
    id: 'tip-11',
    icon: 'local_cafe',
    tint: 'mint',
    vi: {
      title: 'Nấu một món cùng nhau',
      body: 'Thử nấu chung một món ăn mới, kể cả khi chỉ hướng dẫn qua video.',
    },
  },
  {
    id: 'tip-12',
    icon: 'favorite',
    tint: 'amber',
    vi: {
      title: 'Nhắc lại kỷ niệm đẹp',
      body: 'Nhắc lại một kỷ niệm đáng nhớ để cả hai cùng mỉm cười.',
    },
  },
];
