# Shared setup for the diagrams in the "Imbalanced Data" chapters.
#
# Every figure in this section is drawn on the same toy data set, with the same
# colors and shapes, so that a reader who has parsed one figure has parsed the
# coordinate space for all of them.

library(ggplot2)
library(patchwork)

# Colors are shared with the animated versions of these diagrams at
# https://emilhvitfeldt.github.io/tidy-animations/. Shape is doubled with
# color rather than replaced by it, so the figures survive grayscale printing.
imb_colors <- c(
  majority  = "#9aa2ae",
  minority  = "#d6336c",
  synthetic = "#e59db7"
)

imb_shapes <- c(
  majority  = 16,
  minority  = 17,
  synthetic = 2
)

# Two classes in two dimensions. The minority class sits in its own region but
# sends a few points into the majority cloud, giving the boundary-focused
# methods something to find, and one isolated point far from everything, which
# is what makes the "SMOTE interpolates from outliers" caveat visible.
imb_toy <- function() {
  set.seed(1234)

  n_majority <- 60
  majority <- data.frame(
    x = rnorm(n_majority, 0, 1.1),
    y = rnorm(n_majority, 0, 1.0),
    class = "majority"
  )

  core <- data.frame(
    x = rnorm(11, 2.6, 0.75),
    y = rnorm(11, 1.9, 0.62),
    class = "minority"
  )

  # Pushed into the overlap region between the classes.
  border <- data.frame(
    x = c(1.35, 1.6, 0.95),
    y = c(0.95, 0.35, 1.35),
    class = "minority"
  )

  outlier <- data.frame(x = -2.1, y = -1.9, class = "minority")

  out <- rbind(majority, core, border, outlier)
  out$class <- factor(out$class, levels = c("majority", "minority", "synthetic"))
  out$id <- seq_len(nrow(out))
  out
}

# The plot skeleton. Limits are fixed across every panel so that points never
# jump between panels of the same figure.
imb_base <- function(data, title = NULL) {
  ggplot(data, aes(x, y, color = class, shape = class)) +
    geom_point(size = 2) +
    # Unused levels are dropped, so that chapters with no synthetic points do
    # not carry an empty "synthetic" key around in their legend.
    scale_color_manual(values = imb_colors, drop = TRUE, name = NULL) +
    scale_shape_manual(values = imb_shapes, drop = TRUE, name = NULL) +
    coord_fixed(xlim = c(-2.9, 4.1), ylim = c(-2.2, 2.9)) +
    labs(title = title, x = NULL, y = NULL) +
    guides(
      color = guide_legend(nrow = 1),
      shape = guide_legend(nrow = 1)
    ) +
    theme_minimal() +
    theme(
      axis.text = element_blank(),
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = rel(0.9))
    )
}

# Points that a method has flagged for removal are drawn on top of the data as
# a dark cross, so the reader can see what left rather than only what remains.
imb_removed <- "grey30"

# Indices of the k nearest neighbors of `i`, searching only within `pool`.
imb_neighbors <- function(data, i, pool = seq_len(nrow(data)), k = 5) {
  pool <- setdiff(pool, i)
  d <- sqrt((data$x[pool] - data$x[i])^2 + (data$y[pool] - data$y[i])^2)
  pool[order(d)][seq_len(k)]
}

# The same, for every row at once. Returns a list of index vectors.
imb_all_neighbors <- function(data, pool = seq_len(nrow(data)), k = 5) {
  lapply(seq_len(nrow(data)), function(i) imb_neighbors(data, i, pool, k))
}

# Share of an observation's neighbors that carry a different class label. This
# one quantity drives Borderline-SMOTE, ADASYN, ENN and instance hardness.
imb_disagreement <- function(data, k = 5) {
  neighbors <- imb_all_neighbors(data, k = k)
  vapply(
    seq_len(nrow(data)),
    function(i) mean(data$class[neighbors[[i]]] != data$class[i]),
    numeric(1)
  )
}

# A circle, for drawing neighborhoods.
imb_ring <- function(point, r) {
  angle <- seq(0, 2 * pi, length.out = 200)
  data.frame(x = point$x + r * cos(angle), y = point$y + r * sin(angle))
}

# Radius that just encloses `neighbors` around `point`.
imb_radius <- function(data, i, neighbors, pad = 1.15) {
  max(sqrt((data$x[neighbors] - data$x[i])^2 +
             (data$y[neighbors] - data$y[i])^2)) * pad
}

# Interpolate a synthetic point a fraction `gap` of the way from `i` to `j`.
imb_interpolate <- function(data, i, j, gap) {
  out <- data.frame(
    x = data$x[i] + gap * (data$x[j] - data$x[i]),
    y = data$y[i] + gap * (data$y[j] - data$y[i]),
    class = "synthetic"
  )
  out$class <- factor(out$class, levels = levels(data$class))
  out
}

# A minimal SMOTE, used only to draw the figures.
imb_smote <- function(data, k = 5, seed = 42) {
  set.seed(seed)
  minority <- which(data$class == "minority")
  n_new <- sum(data$class == "majority") - length(minority)

  picks <- sample(minority, n_new, replace = TRUE)
  new <- lapply(picks, function(i) {
    neighbor <- sample(imb_neighbors(data, i, minority, k), 1)
    gap <- runif(1)
    data.frame(
      x = data$x[i] + gap * (data$x[neighbor] - data$x[i]),
      y = data$y[i] + gap * (data$y[neighbor] - data$y[i]),
      class = "synthetic"
    )
  })

  new <- do.call(rbind, new)
  new$class <- factor(new$class, levels = levels(data$class))
  new$id <- nrow(data) + seq_len(nrow(new))
  rbind(data, new)
}
