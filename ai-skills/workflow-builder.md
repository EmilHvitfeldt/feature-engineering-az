# Workflow Builder

## Description

Help users design a feature engineering experimentation plan for their dataset and modeling problem. Rather than prescribing a single pipeline, this skill:
- Sets up a series of experiments to test different approaches
- Creates decision branches based on observed results
- Suggests alternatives when initial approaches don't work
- Guides iterative refinement based on what the data shows

## Core Principle: Feature Engineering is Experimentation

There is no universal "correct" pipeline you can design upfront. The right workflow emerges through experimentation:
- What works depends on your specific data, not general rules
- You won't know what helps until you test it
- Results from early experiments inform later choices

Structure your suggestions as **experiments to run and decisions to make based on results**, not as a fixed pipeline.

## Instructions

### 1. Gather Information About the User's Situation

Before suggesting experiments, understand:

**Data types present**:
- Numeric features (continuous, discrete)
- Categorical features (nominal, ordinal, high-cardinality)
- Text fields
- Datetime columns
- Missing values
- Spatial/geographic data
- Time series structure
- Images, audio, video

**Modeling context**:
- Target type (regression, binary classification, multiclass, etc.)
- Model type if known (tree-based, linear, neural network, or trying multiple)
- Class imbalance issues
- Dataset size
- Evaluation metric they care about
- Baseline performance if they have one

If the user hasn't provided enough detail, **ask clarifying questions**. Don't guess—different answers lead to very different experiments.

### 2. Read Key Chapters

Before designing experiments, read these foundational chapters:

```
https://raw.githubusercontent.com/EmilHvitfeldt/feature-engineering-az/main/order.qmd
```
The `order.qmd` chapter covers sequencing of preprocessing steps.

```
https://raw.githubusercontent.com/EmilHvitfeldt/feature-engineering-az/main/models.qmd
```
The `models.qmd` chapter covers how different model types interact with feature engineering.

```
https://raw.githubusercontent.com/EmilHvitfeldt/feature-engineering-az/main/sparse.qmd
```
The `sparse.qmd` chapter is relevant for text or high-cardinality workflows.

Also read section overview chapters relevant to their data types (e.g., `numeric.qmd`, `categorical.qmd`).

If unsure which chapters exist:
```
https://raw.githubusercontent.com/EmilHvitfeldt/feature-engineering-az/main/_quarto.yml
```

### 3. Design an Experimentation Plan

Structure your response as a **decision tree of experiments**, not a linear pipeline.

**Start with a baseline**:
- Minimal preprocessing to establish a reference point
- This gives context for whether later changes help or hurt

**Then suggest experiments with decision branches**:
- What to try first
- What results would indicate (better, worse, no change)
- What to try next based on those results
- Alternative approaches if the first doesn't help

**Format each experiment as**:
1. What to change from the previous version
2. Why this might help (hypothesis)
3. How to evaluate (what metric to watch)
4. Decision branch:
   - If it helps → next experiment or lock it in
   - If it hurts or doesn't help → alternative to try
   - What to look for that might indicate why

### 4. Build in Iteration Points

At key stages, prompt the user to report back:
- "Run these first two experiments and tell me what you observe"
- "If X improved but Y didn't, we should try Z next"
- "If you're seeing [symptom], that suggests [diagnosis] and we should try [alternative]"

Be prepared to suggest alternatives based on:
- Unexpected results
- Overfitting vs underfitting signals
- Specific features that seem problematic
- Computational constraints they discover

### 5. Critical: Data Leakage

Warn users about data leakage risks in their experiments:
- All fitting must happen only on training data
- Proper cross-validation should wrap the entire pipeline
- Some methods (target encoding, etc.) need extra care
- Compare experiments using the same validation strategy

### 6. Link to the Rendered Book

Use rendered book URLs:
```
https://feaz-book.com/{filename}.html
```

## Chapter Quick Reference

| Data Type / Issue | Section Prefix | Overview Chapter |
|-------------------|----------------|------------------|
| Numeric features | `numeric-*` | `numeric.qmd` |
| Categorical features | `categorical-*` | `categorical.qmd` |
| Missing data | `missing-*` | `missing.qmd` |
| Text data | `text-*` | `text.qmd` |
| Datetime | `datetime-*` | `datetime.qmd` |
| Periodic/cyclical | `periodic-*` | `periodic.qmd` |
| Too many features | `too-many-*` | `too-many.qmd` |
| Correlated features | `correlated-*` | `correlated.qmd` |
| Outliers | `outliers-*` | `outliers.qmd` |
| Class imbalance | `imbalenced-*` | `imbalenced.qmd` |
| Spatial data | `spatial-*` | `spatial.qmd` |
| Time series | `time-series-*` | `time-series.qmd` |
| Images | `image-*` | `image.qmd` |
| Sparse matrices | - | `sparse.qmd` |
| Step ordering | - | `order.qmd` |
| Model considerations | - | `models.qmd` |

## Example Responses

### Example 1: Asking for Clarification

User: "I have customer data and want to predict churn."

> To design useful experiments, I need to understand your situation better:
>
> 1. **What feature types do you have?** (numeric, categorical, text, dates, etc.)
> 2. **How much missing data?** (rough percentage)
> 3. **Is it imbalanced?** (what's the churn rate?)
> 4. **What model(s) are you trying?** (or are you comparing multiple?)
> 5. **What's your evaluation metric?** (AUC, F1, precision at k, etc.)
> 6. **Do you have a baseline score yet?**

### Example 2: Experimentation Plan

User: "Binary classification with XGBoost, ~100k rows, numeric and high-cardinality categorical features, datetime columns, 5% missing, 10% churn rate, evaluating on AUC. No baseline yet."

> Here's an experimentation plan. Run these in order and report back what you observe.
>
> ---
>
> ### Experiment 0: Establish Baseline
>
> Start with minimal preprocessing:
> - Drop datetime columns for now
> - Simple label encoding for categoricals (or let XGBoost handle them if using recent version)
> - Let XGBoost handle missing values natively
> - Use `scale_pos_weight=9` to address imbalance
>
> **Evaluate**: 5-fold CV AUC
>
> **Record this score**—everything else is measured against it.
>
> ---
>
> ### Experiment 1: Datetime Features
>
> Add datetime-derived features:
> - Extract: month, day of week, days since signup (if applicable)
> - Try cyclical encoding for month/day of week
>
> **Hypothesis**: Temporal patterns may predict churn (e.g., weekend signups churn more)
>
> **Decision branch**:
> - If AUC improves by >0.005 → keep datetime features, proceed to Experiment 2
> - If no change or worse → drop datetime features, still proceed to Experiment 2
> - If large improvement → also try more granular time features (hour, week of year)
>
> [Datetime extraction](https://feaz-book.com/datetime-extraction.html) | [Periodic features](https://feaz-book.com/periodic.html)
>
> ---
>
> ### Experiment 2: Categorical Encoding
>
> Try target encoding for high-cardinality categoricals (use out-of-fold to prevent leakage):
>
> **Hypothesis**: Target encoding may capture category-level churn patterns better than label encoding
>
> **Decision branch**:
> - If AUC improves → keep target encoding, proceed to Experiment 3
> - If AUC drops → likely overfitting. Try:
>   - (2a) Add smoothing/regularization to target encoding
>   - (2b) Fall back to frequency encoding instead
>   - (2c) Collapse rare categories first, then re-try
> - If no change → stick with simpler label encoding, proceed to Experiment 3
>
> [Target encoding](https://feaz-book.com/categorical-target.html) | [Frequency encoding](https://feaz-book.com/categorical-frequency.html) | [Collapsing levels](https://feaz-book.com/categorical-collapse.html)
>
> ---
>
> ### Experiment 3: Missing Data Strategy
>
> Compare XGBoost's native handling vs explicit imputation + indicator:
>
> **Hypothesis**: Missing indicators might be informative (e.g., missing data = inactive user)
>
> **Decision branch**:
> - If indicators help → missingness is informative, keep them
> - If no change → native handling is fine, simpler is better
> - If worse → might be adding noise, stick with native handling
>
> [Missing indicators](https://feaz-book.com/missing-indicator.html)
>
> ---
>
> ### Experiment 4: Class Imbalance (if needed)
>
> If you're seeing issues with precision/recall trade-off despite decent AUC:
>
> Try SMOTE or adjusted undersampling **within CV folds**:
>
> **Decision branch**:
> - If precision/recall improves at your operating threshold → keep it
> - If AUC drops significantly → resampling is hurting more than helping, rely on `scale_pos_weight` instead
>
> [Imbalanced overview](https://feaz-book.com/imbalenced.html) | [SMOTE](https://feaz-book.com/imbalenced-smote.html)
>
> ---
>
> ### After Running These
>
> Report back:
> 1. Baseline AUC
> 2. Which experiments helped, hurt, or showed no change
> 3. Any unexpected behavior (e.g., severe overfitting, certain features dominating)
>
> Based on your results, we can:
> - Dive deeper into what's working (feature interactions, more datetime features)
> - Diagnose what's not working (look at feature importances, residuals)
> - Try alternative approaches for steps that didn't help

### Example 3: Responding to Results

User: "Baseline was 0.78 AUC. Datetime features helped (+0.02). Target encoding made it worse (dropped to 0.76). Missing indicators no change."

> Good data. Here's how to proceed:
>
> **Datetime features**: Lock these in. Since they helped, you might try:
> - Adding interaction: `days_since_signup * day_of_week`
> - More granular features if you have timestamps
>
> **Target encoding hurting**: This suggests overfitting on category-level patterns. Try these alternatives:
>
> 1. **Frequency encoding** - just uses category counts, no target leakage risk
>    [Frequency encoding](https://feaz-book.com/categorical-frequency.html)
>
> 2. **Collapse rare levels first** - group categories with <100 samples into "other", then try target encoding again
>    [Collapsing levels](https://feaz-book.com/categorical-collapse.html)
>
> 3. **Feature hashing** - if cardinality is very high (1000+), this sidesteps the problem entirely
>    [Feature hashing](https://feaz-book.com/categorical-hashing.html)
>
> **Missing indicators**: No change means native handling is fine. Keep it simple.
>
> **Next experiments**:
> - Try the categorical alternatives above
> - Then consider: feature selection (are some features hurting?), outlier handling for numeric features
>
> What's the cardinality of your categorical columns?
