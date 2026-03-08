#!/usr/bin/env Rscript
# Generate social cards for all chapters and update qmd files
# Usage: Rscript generate-social-cards.R

library(yaml)

# Create output directory
dir.create("social-cards", showWarnings = FALSE)

# Read _quarto.yml
config <- yaml::read_yaml("_quarto.yml")

# Extract chapters with their parts
get_chapters_with_parts <- function(config) {
  chapters <- list()

  for (item in config$book$chapters) {
    if (is.character(item)) {
      # Top-level chapter (no part)
      chapters <- append(chapters, list(list(file = item, part = NULL)))
    } else if (is.list(item) && "part" %in% names(item)) {
      # Part with chapters
      part_name <- item$part
      for (ch in item$chapters) {
        chapters <- append(chapters, list(list(file = ch, part = part_name)))
      }
    }
  }

  chapters
}

# Extract title from qmd file (looks for # Title {#sec-...})
get_chapter_title <- function(qmd_file) {
  if (!file.exists(qmd_file)) {
    return(NULL)
  }

  lines <- readLines(qmd_file, n = 50, warn = FALSE)

  # Look for H1 heading with section ID
  title_line <- grep("^# .+\\{#sec-", lines, value = TRUE)

  if (length(title_line) == 0) {
    # Fallback: look for any H1 heading
    title_line <- grep("^# ", lines, value = TRUE)
  }

  if (length(title_line) == 0) {
    return(NULL)
  }

  # Extract title (remove # prefix and anything in curly brackets)
  title <- title_line[1]
  title <- sub("^#+ *", "", title)
  title <- gsub(" *\\{[^}]*\\}", "", title)
  title <- trimws(title)

  title
}

# Add or update image field in qmd YAML front matter
update_qmd_image <- function(qmd_file, image_path) {
  lines <- readLines(qmd_file, warn = FALSE)

  # Find YAML front matter boundaries
  yaml_markers <- which(lines == "---")

  if (length(yaml_markers) < 2) {
    # No YAML front matter, add it
    new_yaml <- c("---", paste0("image: ", image_path), "---", "")
    lines <- c(new_yaml, lines)
  } else {
    yaml_start <- yaml_markers[1]
    yaml_end <- yaml_markers[2]

    # Check if image field already exists
    yaml_lines <- lines[(yaml_start + 1):(yaml_end - 1)]
    image_line_idx <- grep("^image:", yaml_lines)

    if (length(image_line_idx) > 0) {
      # Update existing image field
      yaml_lines[image_line_idx[1]] <- paste0("image: ", image_path)
    } else {
      # Add image field at end of YAML
      yaml_lines <- c(yaml_lines, paste0("image: ", image_path))
    }

    lines <- c(
      lines[1:yaml_start],
      yaml_lines,
      lines[yaml_end:length(lines)]
    )
  }

  writeLines(lines, qmd_file)
}

# Generate social card for a chapter
generate_card <- function(qmd_file, part_name, update_qmd = TRUE) {
  title <- get_chapter_title(qmd_file)

  if (is.null(title)) {
    message("  Skipping ", qmd_file, " (no title found)")
    return(FALSE)
  }

  # Remove work-in-progress emoji prefix from title
  title <- sub("^\U0001F3D7\\s*", "", title)

  # Output filename (same as qmd but .png)
  output_name <- sub("\\.qmd$", ".png", basename(qmd_file))
  output_path <- file.path("social-cards", output_name)

  # Subtitle (part name or default)
  subtitle <- if (!is.null(part_name)) part_name else "Feature Engineering A-Z"

  # Build typst command
  cmd <- sprintf(
    'typst compile --input title=%s --input subtitle=%s social-card-template.typ %s',
    shQuote(title),
    shQuote(subtitle),
    shQuote(output_path)
  )

  message("  Generating: ", output_name)
  result <- system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)

  if (result != 0) {
    message("    ERROR: Failed to generate ", output_name)
    return(FALSE)
  }

  # Update qmd file with image path
  if (update_qmd) {
    update_qmd_image(qmd_file, output_path)
    message("    Updated: ", qmd_file)
  }

  TRUE
}

# Main
message("Generating social cards...")
message("")

chapters <- get_chapters_with_parts(config)
success_count <- 0
skip_count <- 0

for (ch in chapters) {
  result <- generate_card(ch$file, ch$part, update_qmd = TRUE)
  if (isTRUE(result)) {
    success_count <- success_count + 1
  } else {
    skip_count <- skip_count + 1
  }
}

message("")
message("Done! Generated ", success_count, " social cards (", skip_count, " skipped)")
message("Output directory: social-cards/")
message("QMD files updated with image: field")
