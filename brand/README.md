# Buache Systems — brand assets

Everything here is production-ready. Hand this folder to a build agent as-is.

## Contents

    logo/       house mark, all variants + PNG exports
    icons/      five application icons, SVG + PNG exports
    favicon/    favicon.ico, favicon.svg, and PNG sizes
    tokens.css  CSS custom properties
    tokens.json the same values as JSON

## The mark

A 3x3 grid of dots whose mass increases across the diagonal, with the
largest dot carrying the accent colour.

Use `mark.svg` on light grounds and `mark-on-dark.svg` on dark ones — they
are not interchangeable, because the amber changes value (see below).

Below roughly 24px, switch to `mark-small.svg`. It drops to eight visible
dots at larger radii so the shape stays legible instead of turning to mush.

`mark-mono-black.svg` and `mark-mono-white.svg` are single-colour versions
for engraving, embroidery, stamps, and anywhere a second colour is not
available.

### Clear space and minimum size

Keep clear space equal to the radius of the accent dot on all four sides.
Minimum size is 16px for the small variant, 24px for the standard one.

## Colour

    --bu-ink          #1A1D1B   grid dots, body text
    --bu-paper        #F1F2EF   light ground
    --bu-amber        #E8901F   accent, on DARK grounds and at large sizes
    --bu-amber-dark   #C77410   accent, on LIGHT grounds and below ~48px

The two ambers are one colour in two values, not two colours. The bright
one loses contrast against white and the accent dot stops registering at
small sizes, so the darker step exists to carry it. Never mix them in the
same composition.

## Type

Inter for the name and interface, IBM Plex Mono for the sub-line and any
machine output (paths, hashes, versions, tabular data). Both are SIL Open
Font License, so they can be self-hosted and shipped inside binaries with
no licence cost.

Self-host rather than hotlinking Google Fonts — it is faster and it avoids
handing your visitors' IP addresses to a third party, which matters given
the privacy positioning.

## Lockup

`lockup.svg` is the primary horizontal lockup: mark on the left, `buache`
with `systems` set beneath it in amber.

IMPORTANT: the lockup SVGs contain live `<text>`, so they render correctly
only where Inter and IBM Plex Mono are loaded. That is the right format for
the website. For anywhere else — email signatures, PDFs, third-party sites,
app stores — convert the text to outlines first (in Inkscape:
Path > Object to Path) or the lockup will fall back to a system font.

## Application icons

Five icons on a shared system: one container radius, one glyph stroke
weight of 6.5 at a 100x100 viewBox, round caps and joins throughout, and a
two-stop vertical gradient per app. If you add a sixth app, match those
values exactly — the family reads as designed because of the constants, not
because of the drawings.

    paint     pen laying a stroke
    shrink    large square resizing to small
    snipper   selection frame
    mail      open envelope
    team      schematic antenna, emitting

The team app is the only one on a dark container. That is deliberate: it is
a different kind of product from the four utilities.

PNG exports are provided at 64, 128, 256 and 512 — the sizes Flathub and
Snap ask for.

## Favicon

    <link rel="icon" href="/favicon.ico" sizes="32x32">
    <link rel="icon" href="/favicon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/favicon-180.png">

## One thing to know

A 3x3 grid of nine dots is the established app-launcher control in Google
and Microsoft products, where it is often called the waffle. Some users may
read the mark as a UI affordance rather than a brand, particularly next to
a suite of apps. This was a considered decision, but it is worth knowing if
the question ever comes up, and worth a proper figurative trademark search
(Vienna Classification 26.1) before the mark is registered.
