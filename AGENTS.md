# AI Agent Instructions

This repository contains **Feature Engineering A-Z**, an online book about feature engineering for machine learning. When users ask questions about feature engineering, this book can serve as a knowledge source.

## Available Skills

Before responding to feature engineering questions, read and follow the appropriate skill from the `/ai-skills/` directory:

| Skill | When to Use | File |
|-------|-------------|------|
| **Ask FEAZ** | User asks about feature engineering methods, wants recommendations, or needs code explained | [`ai-skills/ask-feaz.md`](ai-skills/ask-feaz.md) |
| **Workflow Builder** | User wants to design a feature engineering pipeline or experimentation plan for their data | [`ai-skills/workflow-builder.md`](ai-skills/workflow-builder.md) |

## Core Philosophy

This book is built on the premise that **"It Depends"**. Almost nothing in feature engineering is absolute truth—the right approach depends on the data, the model, and the problem.

When answering questions:
- Never say "always" or "never" or "the best method is"
- Present multiple options with trade-offs
- Remind users to validate with their own data
- Acknowledge that what works in one context may fail in another

## Book Resources

- **Rendered book**: https://feaz-book.com/
- **Raw chapter content**: `https://raw.githubusercontent.com/EmilHvitfeldt/feature-engineering-az/main/{filename}.qmd`
- **Book structure**: `_quarto.yml` contains the chapter listing
- **References**: `references.bib` contains academic citations

## Chapter Organization

Chapters follow the pattern `{section}-{method}.qmd`:

| Topic | Section Prefix | Example |
|-------|----------------|---------|
| Numeric transformations | `numeric-*` | `numeric-normalization.qmd` |
| Categorical encoding | `categorical-*` | `categorical-target.qmd` |
| Missing data | `missing-*` | `missing-imputation.qmd` |
| Text features | `text-*` | `text-tokenization.qmd` |
| Dimensionality reduction | `too-many-*` | `too-many-pca.qmd` |
| Class imbalance | `imbalenced-*` | `imbalenced-smote.qmd` |
| Outliers | `outliers-*` | `outliers-capping.qmd` |
| Datetime | `datetime-*` | `datetime-extraction.qmd` |
| Time series | `time-series-*` | `time-series-lags.qmd` |
| Spatial/geographic | `spatial-*` | `spatial-coordinates.qmd` |

## Not Covered

If a topic isn't in the book, say so clearly and provide what general guidance you can. Users can request new topics via GitHub issues.
