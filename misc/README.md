# PSY 504 — Site Upgrade Guide

## What changed

| File | What it does |
|------|-------------|
| `_quarto.yml` | Adds Syllabus & Schedule links to the navbar |
| `index.qmd` | Replaces default title with course name, adds quick-links row, uses listing with descriptions + category tags |
| `custom.scss` | Styles: cleaner typography, quick-link chips, tighter listing cards, category pill filters |
| `styles.css` | Placeholder for any extra CSS |
| `about.qmd` | Minimal about page (edit as needed) |

## How to integrate

### 1. Replace `_quarto.yml`
Copy over your existing `_quarto.yml`. Merge in any existing settings you want to keep
(e.g., `freeze`, `execute`, `revealjs` defaults). The key additions are:
- `navbar: left:` entries for Syllabus / Schedule / About
- `theme: [cosmo, custom.scss]` under `format: html:`
- `css: styles.css`

### 2. Replace `index.qmd`
Drop this in as your new `index.qmd`. Update the Google Drive and feedback form URLs.

### 3. Add `custom.scss` and `styles.css`
Place both at the project root (same level as `_quarto.yml`).

### 4. Update each post's YAML front matter
Add `description` and `categories` to each existing post. Example:

```yaml
---
title: "GLM & Logistic Regression"
description: "Generalized linear models framework, link functions, binary outcome models"
date: 2025-02-11
categories: [GLM]
format:
  revealjs:
    theme: default
---
```

The `description` shows as a subtitle in the listing.
The `categories` generate filterable tags (e.g., GLM, Linear Models, Bayesian, Mixed Models).

### 5. Render
```bash
quarto render
```

## Suggested category labels for your posts

- `Linear Models` — Multiple regression
- `GLM` — Logistic regression, Poisson, etc.
- `Mixed Models` — Multilevel / HLM
- `Bayesian` — Bayesian inference topics
- `Foundations` — Probability, distributions, estimation
