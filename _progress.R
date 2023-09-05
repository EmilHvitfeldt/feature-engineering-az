yaml <- readr::read_lines("_quarto.yml")
yaml <- trimws(yaml)

parts <- stringr::str_detect(yaml, "- part:")

parts_name <- stringr::str_remove(yaml[parts], "- part: \"")
parts_name <- stringr::str_remove(parts_name, "\"")
parts_name <- c("Intro", parts_name)

parts_split <- split(yaml, cumsum(parts))
names(parts_split) <- parts_name

parts_split <- purrr::map(parts_split, stringr::str_subset, "\\.qmd")
sound_ind <- stringr::str_detect(parts_split$`Sound Data`, "- sound")
parts_split$Ending <- parts_split$`Sound Data`[!sound_ind]
parts_split$`Sound Data` <- parts_split$`Sound Data`[sound_ind]

get_progress <- function(x) {
  suppressWarnings(
  res <- tibble::tibble(
    Total = length(x),
    draft = sum(stringr::str_detect(x, "# draft")),
    nice = sum(stringr::str_detect(x, "# nice")),
    done = sum(stringr::str_detect(x, "# done")),
    Progress = sum(stringr::str_detect(x, "# progress"))
  )
  )

  if (is.infinite(res$draft)) {
    res$draft <- res$Total
  }
  res
}

res <- purrr::map(parts_split, get_progress) |>
  purrr::list_rbind(names_to = "Part") |>
  dplyr::mutate(Percentage = scales::label_percent()(draft / Total),
                Percentage = formatC(Percentage, width = 7))

progress_col <- cli::make_ansi_style("hotpink")
draft_col <- cli::make_ansi_style("orange")
nice_col <- cli::make_ansi_style("#cccc00")
done_col <- cli::make_ansi_style("#4F9A05")
not_done_col <- cli::make_ansi_style("grey90")

make_line <- function(info, text_pad, progress_width = 50) {
  draft <- ceiling((info$draft / info$Total) * progress_width)
  progress <- floor((info$Progress / info$Total) * progress_width)

  not_done <- progress_width - draft - progress

  cli::cli_text(
    info$Part,
    strrep("\u00a0", text_pad - stringr::str_length(info$Part)),
    draft_col(strrep("█", draft)),
    progress_col(strrep("█", progress)),
    not_done_col(strrep("█", not_done)),
    "\u00a0",
    formatC(info$draft, width = 2),
    "\u00a0/\u00a0",
    formatC(info$Total, width = 2),
    " |",
    stringr::str_replace(
      formatC(info$draft / info$Total * 100, width = 6, digits = 2, format = "f"),
      " ", "\u00a0"
    ),
    "%"
  )
}

cli::cli({
  cli::cli_h1("Legend")

  cli::cli_text(
    "Not Done = ", not_done_col("███"),
    ", ",
    "Progress = ", progress_col("███"),
    ", ",
    "Draft = ", draft_col("███"),
    ", ",
    "Nice = ", nice_col("███"),
    ", ",
    "Done = ", done_col("███")
  )

  text_pad <- max(stringr::str_length(res$Part)) + 1

  cli::cli_h1("Sections")

  for (i in seq_len(nrow(res))) {
    make_line(res[i, ], text_pad)
  }

  cli::cli_h1("Total")

  res |>
    dplyr::summarise(
      Part = "Total",
      Total = sum(Total),
      draft = sum(draft),
      Progress = sum(Progress),
    ) |>
    make_line(text_pad)
})
