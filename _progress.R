yaml <- readr::read_lines("_quarto.yml")
yaml <- trimws(yaml)

parts <- stringr::str_detect(yaml, "- part:")

parts_name <- stringr::str_remove(yaml[parts], "- part: \"")
parts_name <- stringr::str_remove(parts_name, "\"")
parts_name <- c("intro", parts_name)

parts_split <- split(yaml, cumsum(parts))
names(parts_split) <- parts_name

parts_split <- purrr::map(parts_split, stringr::str_subset, "\\.qmd")

get_progress <- function(x) {
  suppressWarnings(
  res <- tibble::tibble(
    Total = length(x),
    Done = min(which(stringr::str_detect(x, "# Progress"))) - 1
  )
  )

  if (is.infinite(res$Done)) {
    res$Done <- res$Total
  }
  res
}

res <- purrr::map(parts_split, get_progress) |>
  purrr::list_rbind(names_to = "Part") |>
  dplyr::mutate(Percentage = scales::label_percent()(Done / Total),
                Percentage = formatC(Percentage, width = 7))

print(res)

cat("\n\n")

res |>
  dplyr::summarise(
    Part = "Total",
    Total = sum(Total),
    Done = sum(Done)
  ) |>
  dplyr::mutate(Percentage = scales::label_percent()(Done / Total),
                Percentage = formatC(Percentage, width = 7)) |>
  print()
