
# Feature Engineering A-Z

<!-- badges: start -->
<!-- badges: end -->

This repository contains the source material for the book "Feature Engineering A-Z". The rendered book can be found at https://feaz-book.com/

## Installation

This book shows examples in both R and Python, with [renv](https://rstudio.github.io/renv/index.html) being used to manage R dependencies and [Poetry](https://python-poetry.org/) being used to manage Python dependencies. 

You do this by calling `renv::restore()` from R, and `poetry build` from the terminal.

The book is rendered using [Quarto](https://quarto.org/). For this to work smoothly, the environment variable `RETICULATE_PYTHON` has been specified in [.Renviron](.Renviron).
