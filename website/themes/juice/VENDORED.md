# Vendored theme

Modified copy of the Juice theme (MIT, see LICENSE), without its demo site.

- Source: https://github.com/huhu/juice
- Based on commit: 589336250d77eb4236080c325431588119e6d742 (2026-09-29)

## Changes from upstream

- No Carbon Ads: the default sidebar (ad script) and `carbon.css` are removed.
- No remote resources by default: no Google Fonts, no GitHub buttons script.
  Font variables fall back to system fonts; the logo uses `--header-font-family`.
- New `--header-text-color` variable for the header and hero, so they can
  have a dark background while the content keeps a dark text on a light one
  (upstream used `--primary-text-color` for both).
- `color-scheme: light dark` on `:root`, so Zola's dual code highlighting
  themes (CSS `light-dark()`) follow the visitor's preference.
- Pages only show their own table of contents (upstream showed the home
  page's one on every page whenever the home page had headings).
- Generic defaults instead of Juice's demo content: the hero shows
  `config.title` / `config.description` (optional image in
  `config.extra.juice_hero_image`), the footer shows `config.title` and the year.

Site-specific changes (Concentré content, colors, download buttons) live in
`website/templates/`, which override the theme's templates: keep this folder
generic.

To update: clone upstream in a temporary folder, compare with `diff -r`,
port the changes here and update the commit above.
