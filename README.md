# buache.systems

The Buache Systems website. Plain HTML and CSS, no framework, no build step, no
`npm`. Five pages that explain what the apps are and get you to a working install
command.

## Working on it

Serve `site/` from anything and open it:

```bash
python3 -m http.server 8000 --directory site
```

Use a server rather than opening the files directly. Every path in the markup is
root-relative, because the site is published at the root of a domain and because
that keeps the header and footer byte-identical on all five pages. Under `file://`
those paths do not resolve.

Then edit the file. There is nothing to rebuild and nothing to watch.

## Layout

```
brand/                the brand pack as delivered. Not published; the site
                      uses derived copies. Read brand/README.md before
                      touching a mark, a colour or a typeface.
site/
  index.html          the three apps, and why the project exists
  paint/              one page per app, all with the same structure
  snipper/
  shrink/
  download/           every .deb in one place
  robots.txt
  sitemap.xml
  favicon.svg         the small mark, with its own dark-theme media query;
                      favicon.ico and apple-touch-icon.png are rasters of it
  assets/
    style.css         the whole design system, tokens at the top
    theme.js          the theme toggle
    nav.js            the ARIA state on the Apps submenu
    copy.js           the copy buttons on command blocks
    brand/            the three application icons, as shipped
    fonts/            Inter and IBM Plex Mono, SIL OFL 1.1
    img/              screenshots and the Open Graph cards
tools/
  make-images.ps1     rasterises the icons and draws the OG cards
  fonts/              Inter as TTF, which the generator needs and the web
                      build cannot provide
```

The header and footer are copied into each page rather than included. With five
pages, a build step to avoid that duplication costs more than it saves. Change
one, change all five.

## Rules that matter

1. **No third-party requests, ever.** No CDN, no analytics, no webfont from
   someone else's server, no embed. The project's whole claim is that nothing
   leaves your machine; a site that leaks a request to make that claim is not
   worth publishing. The deploy workflow fails the build on any `src`, `srcset`,
   `url()` or `<link>` pointing at another host. Outbound `<a href>` links are
   fine, because a hyperlink loads nothing.

2. **Colours come from the tokens at the top of `style.css`.** Both themes are
   defined once with `light-dark()`; the toggle only sets `color-scheme` on the
   root. A literal colour anywhere else is the one thing that will look wrong in
   the other theme. The two exceptions are deliberate and documented where they
   are: the application icons carry their own ground, and `favicon.svg` has no
   stylesheet to inherit from.

3. **The amber is one colour in two values.** `#E8901F` on dark grounds,
   `#C77410` on light ones, never mixed in one composition. `--accent-strong`
   darkens the light-theme value further for text and filled buttons, because
   `#C77410` reaches only 3.15:1 on paper. The arithmetic is in the comment
   above the tokens; redo it if you change the grounds.

4. **A command block contains the command and nothing else.** No `$` prompt, no
   trailing comment. The copy button copies the element's text verbatim, so
   whatever is in the markup is what lands in someone's shell. The `<pre>`
   content starts at column 0 for the same reason: leading whitespace in the
   source would be leading whitespace in the clipboard.

5. **Say where an app stands, briefly.** Two of the three are not released, and
   their pages carry a "Coming soon" label above the fold where Paint has its
   download button. Keep the copy short: one tagline, six bullets, the facts.

6. **A download link either resolves or is not a link.** Snipper and Shrink have
   no package, so their rows on `/download/` carry a `.button-pending` span and
   not an `<a>` pointing at a release that does not exist. When they publish,
   the span becomes an anchor of the shape Paint's row already has.

## Regenerating the bills of materials

Each app page links a CycloneDX SBOM at `site/<app>/sbom.cdx.json`. It is the
output of that app's own `tools/sbom.sh`, resolved from its `pubspec.lock`.
Regenerate it whenever the app's version on the page changes:

```bash
cd ../paint && SBOM_OUT=../website/site/paint/sbom.cdx.json bash tools/sbom.sh
```

## Regenerating the raster assets

`brand/logo/` is the source of truth for the mark. `favicon.svg` restates it in
one file with a media query; the Open Graph cards, `apple-touch-icon.png` and
the legacy `favicon.ico` are drawn from the same circles by
`tools/make-images.ps1`. Run it only when the mark or a card's wording changes;
the output is committed.

```powershell
.\tools\make-images.ps1
```

It loads Inter from `tools/fonts/` rather than from the system, because Inter is
not installed on Windows and a card silently set in Segoe UI is a card that does
not carry the brand.

## Checks before shipping

- Loads with JavaScript disabled. The theme toggle and the copy buttons hide
  themselves; the Apps submenu still opens on hover and on focus, because CSS
  opens it and `nav.js` only adds the ARIA state.
- Zero third-party requests in the browser's network panel.
- Every install command copy-pastes and runs.
- Passes the [W3C validator](https://validator.w3.org/nu/).
- Lighthouse accessibility 100, contrast at least 4.5:1 in both themes.
- Readable at 320 px wide, with no horizontal page scroll. The Apps submenu
  flattens into the nav row below 48 rem; there is no hover on a touch screen.

## Deploying

Push to `main`. The workflow in `.github/workflows/pages.yml` runs the two checks
and uploads `site/` to GitHub Pages. Nothing is compiled on the way.

The repository is still `alpinsuite/website` and the GitHub links throughout the
site still point at the `alpinsuite` organisation, because that is where the code
actually is. The canonical URLs are `buache.systems`; point the domain at Pages,
or run one `sed` over `site/` if that changes.
