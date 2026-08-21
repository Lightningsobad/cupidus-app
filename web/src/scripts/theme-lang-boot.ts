/*
 * Render-blocking. Must stay the first child of <body>: it writes
 * document.body.dataset, which does not exist while <head> is parsing.
 * Inlined verbatim by SiteLayout.astro via a ?raw import, so this file must
 * remain plain browser-executable JS with no imports and no TypeScript syntax.
 * Storage reads are wrapped in try/catch exactly as Cupid Web.dc.html:686 does.
 */
(function () {
  var theme = 'dark';
  var lang = 'vi';
  try {
    var storedTheme = localStorage.getItem('cupid-web-theme');
    if (storedTheme === 'dark' || storedTheme === 'light') {
      theme = storedTheme;
    }
    var storedLang = localStorage.getItem('cupid-web-lang');
    if (storedLang === 'vi' || storedLang === 'en') {
      lang = storedLang;
    }
  } catch (e) {}
  document.body.dataset.theme = theme;
  document.body.dataset.lang = lang;
  document.documentElement.lang = lang;
})();
