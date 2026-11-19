# ANOVA & Regression Analysis in R

This project covers two statistical modelling exercises in R. The first asks whether gender and education affect earnings, and handles the case where the classical ANOVA assumptions fail. The second asks which linear model best explains house prices, and how the effect of house size changes with the socioeconomic context.

> Course project · Análise Estatística II · Universidade do Algarve · Sep–Dec 2025 · pair work

## Part 1 — Earnings by gender and education (two-way ANOVA)

**Data:** `CPSSWEducation` (package `AER`), about 2,950 US workers. Education is grouped into secondary (< 12 years) and university (≥ 12 years).

**Approach**
1. Ran a two-way ANOVA with interaction (`earnings ~ gender * educ2`), followed by Tukey multiple comparisons.
2. Checked the assumptions:
   - normality with a QQ-plot and the Shapiro–Wilk test;
   - equal variances with the Levene and Bartlett tests;
   - independence with the Durbin–Watson test.
3. All three assumptions failed. Residuals were strongly skewed, variances were unequal across groups and the design was unbalanced. The response was therefore log-transformed and analysed with a **robust two-way ANOVA on trimmed means** (`WRS2::t2way`), followed by robust multiple comparisons (`mcp2atm`).

**Results**
- Gender and education both have a significant effect on earnings (p ≈ 0).
- University graduates and men earn more on average.
- There is no significant interaction (p = 0.776): the gender gap is similar at both education levels.

## Part 2 — Boston house prices (multiple linear regression)

**Data:** `Boston` (package `MASS`), 506 neighbourhoods. The target is `medv` (median home value).

**Approach**
1. Fitted a full model `medv ~ age + crim + rm + lstat` and ran residual diagnostics:
   - Shapiro–Wilk for normality;
   - Breusch–Pagan for constant variance;
   - Durbin–Watson for independence;
   - VIF for multicollinearity.
2. Ran stepwise selection by AIC.
3. Fitted a non-linear model with `lstat²` and `log(crim + 1)`.
4. Fitted an interaction model with `rm × lstat`.
5. Compared the models with AIC and nested F-tests.

**Results**

| Model | Adjusted R² |
|---|---|
| Full linear | 0.644 |
| Stepwise (AIC) | 0.644 |
| Non-linear | 0.719 |
| **Interaction (`rm × lstat`)** | **0.746** |

The interaction model has the lowest AIC. The marginal effect of an extra room is strongly positive in neighbourhoods with a low share of lower-status population (`lstat = 5`). It weakens sharply as `lstat` rises and is close to zero at `lstat = 20`.

## How to run

```r
install.packages(c("AER", "WRS2", "MASS", "ggplot2"))
source("Trabalho_analise.R")
```

`AER` also loads `car` (used for `vif` and `leveneTest`) and `lmtest` (used for `bptest` and `dwtest`). Both datasets ship with the packages, so no download is needed.

## Files

```
Trabalho_analise.R   # full analysis (Part 1 and Part 2)
report.pdf           # written report (Portuguese)
```

## Stack

R · AER · WRS2 · MASS · car · lmtest · ggplot2
