/**
 * Shared i18n locale configuration.
 *
 * Single source of truth for locale definitions used by:
 *   - website/astro.config.mjs   (Starlight i18n)
 *   - tools/build-docs.mjs       (llms-full.txt locale exclusion)
 *   - website/src/pages/404.astro
 */

export const locales = {
  root: {
    label: 'English',
    lang: 'en',
  },
};

/**
 * Non-root locale keys (URL prefixes for translated content). Empty: this
 * fork ships English only.
 * @type {string[]}
 */
export const translatedLocales = Object.keys(locales).filter((k) => k !== 'root');
