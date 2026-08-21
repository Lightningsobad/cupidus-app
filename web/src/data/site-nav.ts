export type PageKey =
  | 'home'
  | 'pets'
  | 'zodiac'
  | 'share'
  | 'blog'
  | 'about'
  | 'support'
  | 'legal';

export interface NavItem {
  key: PageKey;
  href: string;
  vi: string;
  en: string;
}

export interface FooterColumn {
  tvi: string;
  ten: string;
  links: NavItem[];
}

export function hrefFor(key: PageKey): string {
  return key === 'home' ? '/' : `/${key}`;
}

/** Source: `Cupid Web.dc.html:715-718`. `legal` is deliberately absent — it is footer-only. */
export const navItems: NavItem[] = [
  { key: 'home', href: hrefFor('home'), vi: 'Trang chủ', en: 'Home' },
  { key: 'pets', href: hrefFor('pets'), vi: 'Pet', en: 'Pets' },
  { key: 'zodiac', href: hrefFor('zodiac'), vi: 'Hoàng đạo', en: 'Zodiac' },
  { key: 'share', href: hrefFor('share'), vi: 'Ghép đôi', en: 'Invite' },
  { key: 'blog', href: hrefFor('blog'), vi: 'Blog', en: 'Blog' },
  { key: 'about', href: hrefFor('about'), vi: 'Về chúng mình', en: 'About' },
  { key: 'support', href: hrefFor('support'), vi: 'Hỗ trợ', en: 'Support' },
];

/** Source: `Cupid Web.dc.html:831-848`. "Press kit" and both Legal links reuse existing routes. */
export const footerCols: FooterColumn[] = [
  {
    tvi: 'Sản phẩm',
    ten: 'Product',
    links: [
      { key: 'home', href: hrefFor('home'), vi: 'Trang chủ', en: 'Home' },
      { key: 'pets', href: hrefFor('pets'), vi: 'Dàn pet', en: 'Pets' },
      { key: 'zodiac', href: hrefFor('zodiac'), vi: 'Hoàng đạo', en: 'Zodiac' },
      { key: 'share', href: hrefFor('share'), vi: 'Ghép đôi', en: 'Invite' },
      { key: 'blog', href: hrefFor('blog'), vi: 'Blog', en: 'Blog' },
    ],
  },
  {
    tvi: 'Công ty',
    ten: 'Company',
    links: [
      { key: 'about', href: hrefFor('about'), vi: 'Về chúng mình', en: 'About' },
      { key: 'about', href: hrefFor('about'), vi: 'Press kit', en: 'Press kit' },
      { key: 'support', href: hrefFor('support'), vi: 'Hỗ trợ', en: 'Support' },
    ],
  },
  {
    tvi: 'Pháp lý',
    ten: 'Legal',
    links: [
      { key: 'legal', href: hrefFor('legal'), vi: 'Quyền riêng tư', en: 'Privacy' },
      { key: 'legal', href: hrefFor('legal'), vi: 'Điều khoản', en: 'Terms' },
    ],
  },
];

export const THEME_STORAGE_KEY = 'cupid-web-theme';
export const LANG_STORAGE_KEY = 'cupid-web-lang';

/** Source: `Cupid Web.dc.html:728`. Keyed by the theme currently active, i.e. the theme being left. */
export const themeToggleTitles = {
  dark: { vi: 'Chuyển sang Hồng mơ mộng', en: 'Switch to Dreamy Pink' },
  light: { vi: 'Chuyển sang nền tối', en: 'Switch to dark' },
} as const;
