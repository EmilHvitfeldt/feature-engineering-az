// Social Card Template for Feature Engineering A-Z
// Compile with: typst compile social-card-template.typ social-card.png

// === PARAMETERS (passed via --input flag) ===
#let chapter-title = sys.inputs.at("title", default: "Chapter Title")
#let chapter-subtitle = sys.inputs.at("subtitle", default: "Section")

// === DESIGN SETTINGS (from theme.scss) ===
#let card-width = 1200pt
#let card-height = 630pt

// Theme colors
#let theme-purple = rgb("#854ac8")
#let theme-green = rgb("#1EAF98")
#let theme-darkgreen = rgb("#01836e")

// Card colors
#let background-color = rgb("#ffffff")
#let title-color = theme-darkgreen
#let accent-color = theme-purple
#let text-color = rgb("#333333")
#let subtitle-color = rgb("#666666")

#set page(
  width: card-width,
  height: card-height,
  margin: 0pt,
)

#set text(
  font: "Raleway",
  fill: text-color,
)

// === CARD LAYOUT ===
#box(
  width: 100%,
  height: 100%,
  fill: background-color,
  inset: 60pt,
)[
  // Top: Book title (centered with full-width underline)
  #block(width: 100%)[
    #align(center)[
      #text(size: 52pt, fill: subtitle-color, weight: "semibold", tracking: 0.2em)[
        Feature Engineering A-Z
      ]
    ]
    #v(-32pt)
    #line(length: 100%, stroke: 9pt + theme-green)
  ]

  #v(1fr)

  // Middle: Chapter section/part
  #text(size: 60pt, fill: accent-color, weight: "semibold")[
    #chapter-subtitle
  ]

  #v(16pt)

  // Main: Chapter title
  #align(right)[
    #text(size: 75pt, weight: "semibold", fill: title-color)[
      #chapter-title
    ]
  ]

  #v(1fr)

  // Bottom: URL (left) and Author (right)
  #block(width: 100%)[
    #stack(dir: ltr,
      text(size: 42pt, fill: subtitle-color)[feaz-book.com],
      h(1fr),
      text(size: 42pt, fill: subtitle-color)[Emil Hvitfeldt]
    )
  ]
]
