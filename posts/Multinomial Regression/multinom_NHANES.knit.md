---
title: "Multinomial Regression (NHANES data example)"
subtitle: "Princeton University"
author: "Suyog Chandramouli (adapted from materials by Jason Geller)"
date: '2026-03-04'
footer: "PSY 504: Advanced Statistics"
format: 
  revealjs:
    theme: white
    css: slide-style.css
    multiplex: true
    transition: fade
    slide-number: true
    incremental: false 
    chalkboard: true
    fontsize: "25pt"
webr:
  packages: ["tidyverse", "easystats", "broom", "knitr","nnet", "emmeans", "ordinal", "ggeffects","NHANES"]
filters:
  - webr
execute:
  freeze: auto
  echo: true
  message: false
  warning: false
  fig-align: center
  fig-width: 12
  fig-height: 8
  editor_options: 
  chunk_output_type: inline
  code-overflow: wrap
  html:
    code-fold: true
    code-tools: true
---

## Packages


::: {.cell}

```{.r .cell-code}
library(tidyverse)
library(easystats)
library(marginaleffects)
library(viridis)
library(ggeasy)
library(effects)
library(ordinal)
library(ggeffects)
library(emmeans)
library(foreign)
library(car)
library(knitr)
library(patchwork)
library(cowplot)
library(MASS)
library(brms)
options(scipen=999)
```
:::


-   You can follow along here: <https://github.com/suyoghc/PSY-504_Spring-2025/blob/main/Multinomial%20Regression/06-multinom.qmd>

## Outline

::::: columns
::: {.column width="50%"}
-   Introduce multinomial logistic regression

    -   Multinomial distribution
    -   Realtionship between logistic, ordinal, and multinomial regression

-   Motivating example: `NHANES` dataset
:::

::: {.column width="50%"}
![](ordmult.jpeg){fig-align="center"}
:::
:::::

## Multinomial distribution

-   Extension of Bernoulli and binomial distributions

-   When you have more than two outcomes and fixed number of trials

$$P(X_1 = x_1, X_2 = x_2, \ldots, X_k = x_k) = \frac{n!}{x_1! x_2! \cdots x_k!} p_1^{x_1} p_2^{x_2} \cdots p_k^{x_k}$$

-   $X$ = \# of times events occur
-   $p$ = probability of occurrence
-   $n$ = \# of trials

$$\text{Mean of } X_i = E[X_i] = n \cdot p_i$$$$\text{Variance of } X_i = \text{Var}(X_i) = n \cdot p_i \cdot (1 - p_i)$$

## Multinomial Logistic Regression

-   In ordinal regression:

$$\begin{array}{rcl} L_1 &=& \alpha_1-\beta_1x_1-\cdots-\beta_p X_p\\ L_2 &=& \alpha_2-\beta_1x_1-\cdots-\beta_p X_p & \\ L_{J-1} &=& \alpha_{J-1}-\beta_1x_1-\cdots-\beta_p X_p \end{array}$$

-   In the multinomial logistic model:

$$\begin{array}{rcl} L_1 &=& \alpha_1+\beta_1x_1+\cdots+\beta_p X_p\\ L_2 &=& \alpha_2+\beta_2x_1+\cdots+\beta_p X_p & \\ L_{J-1} &=& \alpha_{J-1}+\beta_jx_1+\cdots+\beta_p X_p \end{array}$$

## Multinomial logistic regression

-   Choose a baseline category. Let's choose $y=0$. Then,

$$P(y_i = 0|x_i) = P_{i0}$$ and $$P(y_i = 1|x_i) = P_{i1}$$

$$\log\bigg(\frac{p_{i1}}{p_{i0}}\bigg) = \beta_{0k} + \beta_{1k} x_i$$

-   Slope: $\beta_1$: when x increases by one unit, the odds of Y = 1 vs. baseline is expected to multiply by a factor or $exp(\beta)$

-   Intercept: $\beta_0$: when x = 0 the odds of Y = 1 is expected to be $exp(\beta)$

## Multinomial Logistic Regression

-   Geller et al.(2018)

    -   Which of the following best describes your pattern of study?

        -   Light cram
        -   Heavy cram
        -   Space out

-   Let "Space out" be the baseline category. Then

$$\log\bigg(\frac{\pi_{light }}{\pi_{space}}\bigg) = \beta_{0B} + \beta_{1B}x_i \\[10pt]
\log\bigg(\frac{\pi_{heavy}}{\pi_{space}}\bigg) = \beta_{0C} + \beta_{1C} x_i$$

## Summary

-   Multinomial logistic regression models the probabilities of j response categories (j-1)

    -   Typically these compare each of the first m-1 categories to the last (reference) category

        -   1 vs. m, 2 vs.m, 3 vs. m

-   Logits for any pair of categories can be calculated from the m-1 fitted ones

## NHANES data

-   [National Health and Nutrition Examination Survey](https://www.cdc.gov/nchs/nhanes/index.htm) is conducted by the National Center for Health Statistics (NCHS)

-   The goal is to *"assess the health and nutritional status of adults and children in the United States"*

-   This survey includes an interview and a physical examination

## NHANES data

-   We will use the data from the <font class="vocab">`NHANES`</font> R package

-   Contains 75 variables for the 2009 - 2010 and 2011 - 2012 sample years

-   The data in this package is modified for educational purposes and should **not** be used for research

-   Original data can be obtained from the [NCHS website](https://www.cdc.gov/nchs/data_access/index.htm) for research purposes

-   Type <font class="vocab">`?NHANES`</font> in console to see list of variables and definitions

## Health rating vs. age & physical activity

-   **Question**: Can we use a person's age and whether they do regular physical activity to predict their self-reported health rating?

-   We will analyze the following variables:

    -   <font class="vocab">`HealthGen`: </font>Self-reported rating of participant's health in general. Excellent, Vgood, Good, Fair, or Poor.

    -   <font class="vocab">`Age`: </font>Age at time of screening (in years). Participants 80 or older were recorded as 80.

    -   <font class="vocab">`PhysActive`: </font>Participant does moderate to vigorous-intensity sports, fitness or recreational activities

## The data

```{webr-r}
nhanes_adult <- NHANES %>%
  #only use ages 18+
  filter(Age >= 18) %>%
  #select 4 vars from the full dataset
  dplyr::select(HealthGen, Education, Age, PhysActive)  %>%
  # get rid of nas
  drop_na()

```


::: {.cell}

:::



::: {.cell}

```{.r .cell-code}
glimpse(nhanes_adult)
```

::: {.cell-output .cell-output-stdout}

```
Rows: 6,465
Columns: 5
$ HealthGen      <fct> Good, Good, Good, Good, Vgood, Vgood, Vgood, Vgood, Vgo…
$ Education      <fct> High School, High School, High School, Some College, Co…
$ Age            <int> 34, 34, 34, 49, 45, 45, 45, 66, 58, 54, 50, 33, 60, 56,…
$ PhysActive     <fct> No, No, No, No, Yes, Yes, Yes, Yes, Yes, Yes, Yes, No, …
$ PhysActive_yes <fct> No, No, No, No, Yes, Yes, Yes, Yes, Yes, Yes, Yes, No, …
```


:::
:::


## Exploratory data analysis


::: {.cell layout-align="center"}
::: {.cell-output-display}
![](multinom_NHANES_files/figure-revealjs/unnamed-chunk-4-1.png){fig-align='center' width=50%}
:::
:::


## Exploratory data analysis


::: {.cell layout-align="center"}
::: {.cell-output-display}
![](multinom_NHANES_files/figure-revealjs/unnamed-chunk-5-1.png){fig-align='center' width=80%}
:::
:::


## Multinomial model in R

-   Use the <font class="vocab">`multinom()`</font> function in the `nnet` package

```{webr-r}
library(nnet)# multinom 

health_m <- multinom(HealthGen ~ PhysActive + Age, 
                     data = nhanes_adult)
summary(health_m)
```


::: {.cell}

:::


## Output results

```{webr-r}
model_parameters(health_m, exponentiate = FALSE)%>%  filter(Response=="Fair") %>%
  kable(digits = 3, format = "markdown")
```

```{webr-r}
model_parameters(health_m, exponentiate = TRUE)%>%  filter(Response=="Fair") %>%
  kable(digits = 3, format = "markdown")
```

## Fair vs. excellent health

The baseline category for the model is `Excellent`

The model equation for the log-odds a person rates themselves as having "Fair" health vs. "Excellent" is

$$\log\Big(\frac{\hat{\pi}_{Fair}}{\hat{\pi}_{Excellent}}\Big) = 1.03  + 0.001 ~ \text{age} - 1.66 ~ \text{PhysActive}$$

## Fair vs. excellent health: Interpretations

$$\log\Big(\frac{\hat{\pi}_{Fair}}{\hat{\pi}_{Excellent}}\Big) = 1.03  + \color{Red} {0.001} ~ \text{age} - 1.66 ~ \text{PhysActive}$$

. . .

-   For each additional year in age, the odds a person rates themselves as having fair health versus excellent health are expected to multiply by 1.001 (exp(0.001)), holding physical activity constant.

    -   As Age ⬆️, more likely to report Fair vs. Excellent health

## Fair vs. excellent health: Interpretations

$$\log\Big(\frac{\hat{\pi}_{Fair}}{\hat{\pi}_{Excellent}}\Big) = 1.03  + 0.001 ~ \text{age} \color{Red}{- 1.66} ~ \text{PhysActive}$$

. . .

-   The odds a person who does physical activity will rate themselves as having fair health versus excellent health are expected to be 0.19 `(exp(-1.66))` times the odds for a person who doesn't do physical activity, holding age constant.

    -   A person who does physical activity is more likely to rate themselves in Excellent vs. Fair health

## Interpretations

$$\log\Big(\frac{\hat{\pi}_{Fair}}{\hat{\pi}_{Excellent}}\Big) = \color{Red}{1.03}  + 0.001 ~ \text{age} - 1.66 ~ \text{PhysActive}$$

. . .

-   The odds a 0 year old person who doesn't do physical activity rates themselves as having fair health vs. excellent health are 2.801 `(exp(1.03))`.

⚠️ **Need to mean-center age for the intercept to have a meaningful interpretation!**

## Good vs. Excellent health

```{webr-r}
model_parameters(health_m, exponentiate = FALSE)%>%  filter(Response=="Good") %>%
  kable(digits = 3, format = "markdown")

```

## Good vs. Excellent health

-   Get OR

```{webr-r}
model_parameters(health_m, exponentiate = TRUE) %>% 
  filter(Response=="Good") %>%
  kable(digits = 3, format = "markdown")
```

## Good vs. Excellent health

The baseline category for the model is `Excellent`

The model equation for the log-odds a person rates themselves as having "Good" health vs. "Excellent" is

$$\log\Big(\frac{\hat{\pi}_{Good}}{\hat{\pi}_{Excellent}}\Big) = 1.99  - 0.003   ~ \text{age} - 1.011 ~ \text{PhysActive}$$

## Interpretations

$$\log\Big(\frac{\hat{\pi}_{Good}}{\hat{\pi}_{Excellent}}\Big) = 1.99 \color{Red}{- 0.003}   ~ \text{age} - 1.011 ~ \text{PhysActive}$$

. . .

For each additional year in age, the odds a person rates themselves as having "Good" health versus "Excellent" health are expected to multiply by 0.997 (exp(-0.003)), holding physical activity constant

-   As Age ⬆️, higher probability to report excellant health vs. good health

## Interpretations

$$\log\Big(\frac{\hat{\pi}_{Good}}{\hat{\pi}_{Excellent}}\Big) = {1.99}  - 0.003     ~ \text{age} \color{Red}{- 1.011} ~ \text{PhysActive}$$

. . .

-   The odds a person who does physical activity will rate themselves as having "Good" health versus "Excellent" health are expected to be 0.364 `(exp(-1.01))` times the odds for a person who doesn't do physical activity, holding age constant

    -   A person who does physical activity rate themselves in Excellent vs. good health

## Interpretations

$$\log\Big(\frac{\hat{\pi}_{Good}}{\hat{\pi}_{Excellent}}\Big) = \color{Red}{1.99}  - 0.003  ~ \text{age} - 1.011 ~ \text{PhysActive}$$

. . .

-   The odds a 0 year old person who doesn't do physical activity rates themselves as having Good health vs. Excellent health are 7.316 `(exp(1.99))`.

<!-- -->

-   Those reporting no physical activity are more likely to report Good vs. Excellent health

⚠️ **Need to mean-center age for the intercept to have a meaningful interpretation!**

## Change baseline

::: callout-important
-   Chosen baseline/reference should be determined a priori
:::

<br> <br>


::: {.cell}

```{.r .cell-code}
nhanes_adult %>%
  mutate(HealthGen = relevel(as.factor(HealthGen), ref= "Poor"))
#relevel modle to change baseline
```
:::


## Model

-   Report LRT with the `anova` function


::: {.cell}

```{.r .cell-code}
car::Anova(health_m) %>% 
  kable()
```

::: {.cell-output-display}


|           |  LR Chisq| Df| Pr(>Chisq)|
|:----------|---------:|--:|----------:|
|PhysActive | 494.76865|  4|  0.0000000|
|Age        |  25.51445|  4|  0.0000396|


:::
:::


## Comparisons

-   `emmeans` approach

    -   Log odds (category vs. reference) for the difference between variables (`PhysActive`)

```{webr-r}

multi_an <- emmeans(health_m, ~ PhysActive|HealthGen) # get education 
coefs = contrast(regrid(multi_an, "log"),"trt.vs.ctrl1", by="PhysActive") # make sure logit and response vs. baseline the difference in logs odds is equal to the log of the odds
contrast(coefs, "revpairwise", by = "contrast") %>% kable() # This line performs additional contrasts on the results obtained from the previous step (coefs).

```

## Comparisons


::: {.cell}

```{.r .cell-code}
multi_an <- emmeans(health_m, ~ PhysActive|HealthGen) # get education 
coefs = contrast(regrid(multi_an, "log"),"trt.vs.ctrl1", by="PhysActive") # make sure logit and response vs. baseline
contrast(coefs, "revpairwise", by = "contrast") %>% kable() # This line performs additional contrasts on the results obtained from the previous step (coefs).
```

::: {.cell-output-display}


|contrast1 |contrast          |   estimate|        SE| df|    t.ratio|   p.value|
|:---------|:-----------------|----------:|---------:|--:|----------:|---------:|
|Yes - No  |Vgood - Excellent | -0.3317154| 0.0948777| 12|  -3.496243| 0.0044123|
|Yes - No  |Good - Excellent  | -1.0113060| 0.0921090| 12| -10.979450| 0.0000001|
|Yes - No  |Fair - Excellent  | -1.6624228| 0.1094439| 12| -15.189722| 0.0000000|
|Yes - No  |Poor - Excellent  | -2.6704765| 0.2361543| 12| -11.308187| 0.0000001|


:::
:::


## Comparisons

-   For continuous predictors, `emmeans` uses marginal effects at the mean (MEM)

-   We can use `marginaleffects` to get average effect of `Age`


::: {.cell}

```{.r .cell-code}
# avg_slopes(
#     health_m,
#     hypothesis = "reference",
#     variables = c("Age"), 
#     type="latent") %>% 
#   kable()
```
:::


## NHANES: Predicted probabilities: `PhysActive`


::: {.cell}

```{.r .cell-code}
#calculate predicted probabilities
ggemmeans(health_m, terms=c("PhysActive")) %>%
  kable(format = "markdown", digits = 3)
```

::: {.cell-output-display}


|x   | predicted| std.error| conf.low| conf.high|response.level |group |
|:---|---------:|---------:|--------:|---------:|:--------------|:-----|
|No  |     0.069|     0.005|    0.068|     0.070|Excellent      |1     |
|No  |     0.244|     0.008|    0.241|     0.247|Vgood          |1     |
|No  |     0.437|     0.009|    0.433|     0.442|Good           |1     |
|No  |     0.204|     0.007|    0.202|     0.207|Fair           |1     |
|No  |     0.045|     0.004|    0.045|     0.045|Poor           |1     |
|Yes |     0.155|     0.006|    0.153|     0.157|Excellent      |1     |
|Yes |     0.394|     0.008|    0.390|     0.398|Vgood          |1     |
|Yes |     0.357|     0.008|    0.353|     0.361|Good           |1     |
|Yes |     0.087|     0.005|    0.086|     0.088|Fair           |1     |
|Yes |     0.007|     0.001|    0.007|     0.007|Poor           |1     |


:::
:::


## Plot predicted probabilities: `PhysActive`


::: {.cell layout-align="center"}

```{.r .cell-code}
ggemmeans(health_m, terms = c("PhysActive")) %>%   
  ggplot(aes(x = x, y = predicted, fill = response.level)) + 
  geom_col() +
  geom_text(
    aes(label = round(predicted, 3)),
    color = "white",
    position = position_fill(vjust = 0.5),
    size = 5
  ) + 
  labs(
    x = "Physical Activity",
    y = "Predicted Probability",
    fill = "Response"
  ) + 
  theme(text = element_text(size = 30)) +  
  scale_fill_viridis(discrete = TRUE) + 
  theme_lucid(base_size = 25)
```

::: {.cell-output-display}
![](multinom_NHANES_files/figure-revealjs/unnamed-chunk-12-1.png){fig-align='center' width=1152}
:::
:::


## Plot predicted probabilities: `Age`


::: {.cell layout-align="center"}

```{.r .cell-code}
ggpredict(health_m, terms=c("Age")) %>%
ggplot(., aes(x=x, y=predicted, fill=response.level)) + 
    geom_area(alpha=0.6 , size=.5, colour="white") + 
    labs(x="Age", y="Predicted Probablity") + 
    scale_fill_viridis(discrete = T) +
   labs(fill = "Response") + 
    theme_lucid(base_size=25)
```

::: {.cell-output-display}
![](multinom_NHANES_files/figure-revealjs/unnamed-chunk-13-1.png){fig-align='center' width=1152}
:::
:::


# Model selection

## Add `Education` to the model?

-   We consider adding the participants' `Education` level to the model

    -   Education takes values `8thGrade`, `9-11thGrade`, `HighSchool`, `SomeCollege`, and `CollegeGrad`

-   Models we're testing:

    -   Reduced Model: `Age`, `PhysActive`
    -   Full Model: `Age`, `PhysActive`, `Education`

$$\begin{align}&H_0: \beta_{8thGrade} = \beta_{9-11thGrade} = \beta_{HighSchool} = \beta_{SomeCollege} = \beta_{CollegeGrad} = 0\\
&H_a: \text{ at least one }\beta_j \text{ is not equal to }0\end{align}$$

## Add `Education` to the model?


::: {.cell}

```{.r .cell-code}
model_red <- multinom(HealthGen ~ Age + PhysActive, 
               data = nhanes_adult)
model_full <- multinom(HealthGen ~ Age + PhysActive + 
                         Education, 
               data = nhanes_adult)
```
:::



::: {.cell}

:::


## Add `Education` to the model?


::: {.cell}

```{.r .cell-code}
anova(model_red, model_full, test = "Chisq") %>%
  kable(format = "markdown")
```

::: {.cell-output-display}


|Model                        | Resid. df| Resid. Dev|Test   |    Df| LR stat.| Pr(Chi)|
|:----------------------------|---------:|----------:|:------|-----:|--------:|-------:|
|Age + PhysActive             |     25848|   16994.23|       |    NA|       NA|      NA|
|Age + PhysActive + Education |     25832|   16505.10|1 vs 2 |    16| 489.1319|       0|


:::
:::


At least one coefficient associated with `Education` is non-zero. Therefore, we will include `Education` in the model.

## Full model


::: {.cell}

```{.r .cell-code}
car::Anova(model_full, type="II") %>%
  kable(format = "markdown", digits = 3)
```

::: {.cell-output-display}


|           | LR Chisq| Df| Pr(>Chisq)|
|:----------|--------:|--:|----------:|
|Age        |   19.295|  4|      0.001|
|PhysActive |  242.631|  4|      0.000|
|Education  |  489.132| 16|      0.000|


:::
:::


## Comparisons

-   Use `emmeans` to extract the log odds coefs for comparisons of interest


::: {.cell}

```{.r .cell-code}
multi_an <- emmeans(model_full, ~ Education|HealthGen) # get education 
coefs = contrast(regrid(multi_an, "log"),"trt.vs.ctrl1", by="Education") # make sure logit and response vs. baseline
contrast(coefs, "revpairwise", by = "contrast") # This line performs additional contrasts on the results obtained from the previous step (coefs).
```

::: {.cell-output .cell-output-stdout}

```
contrast = Vgood - Excellent:
 contrast1                       estimate    SE df t.ratio p.value
 (9 - 11th Grade) - 8th Grade      0.7754 0.308 28   2.519  0.1151
 High School - 8th Grade           0.7139 0.279 28   2.554  0.1071
 High School - (9 - 11th Grade)   -0.0614 0.200 28  -0.307  0.9979
 Some College - 8th Grade          0.8035 0.272 28   2.958  0.0453
 Some College - (9 - 11th Grade)   0.0282 0.188 28   0.150  0.9999
 Some College - High School        0.0896 0.135 28   0.664  0.9625
 College Grad - 8th Grade          0.4324 0.269 28   1.607  0.5052
 College Grad - (9 - 11th Grade)  -0.3430 0.184 28  -1.863  0.3600
 College Grad - High School       -0.2816 0.128 28  -2.203  0.2082
 College Grad - Some College      -0.3712 0.105 28  -3.548  0.0112

contrast = Good - Excellent:
 contrast1                       estimate    SE df t.ratio p.value
 (9 - 11th Grade) - 8th Grade      0.3823 0.273 28   1.402  0.6312
 High School - 8th Grade           0.1235 0.245 28   0.505  0.9862
 High School - (9 - 11th Grade)   -0.2589 0.188 28  -1.374  0.6487
 Some College - 8th Grade          0.0366 0.237 28   0.154  0.9999
 Some College - (9 - 11th Grade)  -0.3457 0.178 28  -1.946  0.3176
 Some College - High School       -0.0869 0.129 28  -0.673  0.9607
 College Grad - 8th Grade         -0.8178 0.236 28  -3.468  0.0136
 College Grad - (9 - 11th Grade)  -1.2002 0.176 28  -6.828  <.0001
 College Grad - High School       -0.9413 0.125 28  -7.531  <.0001
 College Grad - Some College      -0.8544 0.105 28  -8.161  <.0001

contrast = Fair - Excellent:
 contrast1                       estimate    SE df t.ratio p.value
 (9 - 11th Grade) - 8th Grade     -0.1884 0.274 28  -0.689  0.9572
 High School - 8th Grade          -0.7716 0.247 28  -3.126  0.0309
 High School - (9 - 11th Grade)   -0.5832 0.199 28  -2.933  0.0479
 Some College - 8th Grade         -1.2668 0.242 28  -5.243  0.0001
 Some College - (9 - 11th Grade)  -1.0784 0.191 28  -5.637  <.0001
 Some College - High School       -0.4953 0.149 28  -3.330  0.0190
 College Grad - 8th Grade         -2.3936 0.251 28  -9.544  <.0001
 College Grad - (9 - 11th Grade)  -2.2052 0.203 28 -10.882  <.0001
 College Grad - High School       -1.6220 0.161 28 -10.058  <.0001
 College Grad - Some College      -1.1267 0.148 28  -7.590  <.0001

contrast = Poor - Excellent:
 contrast1                       estimate    SE df t.ratio p.value
 (9 - 11th Grade) - 8th Grade     -0.2980 0.342 28  -0.870  0.9053
 High School - 8th Grade          -1.0438 0.325 28  -3.212  0.0252
 High School - (9 - 11th Grade)   -0.7457 0.291 28  -2.566  0.1047
 Some College - 8th Grade         -0.9419 0.307 28  -3.069  0.0351
 Some College - (9 - 11th Grade)  -0.6438 0.269 28  -2.394  0.1467
 Some College - High School        0.1019 0.244 28   0.417  0.9933
 College Grad - 8th Grade         -2.1252 0.360 28  -5.898  <.0001
 College Grad - (9 - 11th Grade)  -1.8271 0.328 28  -5.563  0.0001
 College Grad - High School       -1.0814 0.307 28  -3.526  0.0118
 College Grad - Some College      -1.1833 0.283 28  -4.183  0.0022

Results are averaged over the levels of: PhysActive 
Results are given on the log (not the response) scale. 
P value adjustment: tukey method for comparing a family of 5 estimates 
```


:::
:::


## Predicted Probabilities: `Education`


::: {.cell layout-align="center"}

```{.r .cell-code}
plot_edu <- ggemmeans(model_full, terms = c("Education")) %>%
  ggplot(aes(x = x, y = predicted, fill = response.level)) +  
  geom_col() + 
  geom_text(
    aes(label = round(predicted, 3)),
    color = "white",
    position = position_fill(vjust = 0.5),
    size = 5
  ) + 
  labs(
    x = "Education",
    y = "Predicted Probability",
    fill = "Response"
  ) + 
  scale_fill_viridis(discrete = TRUE)
```
:::



::: {.cell layout-align="center"}
::: {.cell-output-display}
![](multinom_NHANES_files/figure-revealjs/unnamed-chunk-20-1.png){fig-align='center' width=50%}
:::
:::


# Checking Assumptions

## Assumptions for multinomial logistic regression

-   Same assumptions as logistic regression
    -   Fit separate logistic regressions to check for linearity, outliers, and multicollinearity


::: {.cell}

```{.r .cell-code}
nhanes_adult <- nhanes_adult %>%
  mutate(Excellent = factor(if_else(HealthGen == "Excellent", "1", "0")), 
         Vgood = factor(if_else(HealthGen == "Vgood", "1", "0")), 
         Good = factor(if_else(HealthGen == "Good", "1", "0")), 
         Fair = factor(if_else(HealthGen == "Fair", "1", "0")), 
         Poor = factor(if_else(HealthGen == "Poor", "1", "0"))
  )

# fit sep logistic models
```
:::



::: {.cell}

```{.r .cell-code}
performance::check_model()
```
:::


## Model fit

-   Mcfadden's $R^2$


::: {.cell}

```{.r .cell-code}
r2_mcfadden()
```
:::


## Effect Size

-   Convert to Cohen's *d*

$$ d = \frac{log(OR)*\sqrt(3)}{{\pi}}$$

-   Recommended by a reviewer once


::: {.cell}

```{.r .cell-code}
# easystats effectszie package

effectsize::oddsratio_to_d()
```
:::


## Write-up

-   Report full model results
    -   $\chi^2$ test
        -   Age, $\chi^2 (4)$ = 19.30, *p* \< .05
        -   PhysActive, $\chi^2 (4)$ = 242.63, *p* \< .05
        -   Education, $\chi^2 (16)$ = 489.13, *p* \< .05
-   Model fit: $R^2$

::: callout-note
-   Read the textbook chapter for example
:::

## Write-up

-   Log odds for each variable of interest in J-1 models

    -   Table with included ORs (see next slide for example)

    -   Figure showing predicted probabilities

## OR table (Geller et al., 2018)


::: {.cell layout-align="center"}

:::


## Advanced Applications

-   Multilevel multinomial models

    -   brms
    -   `mclogit` https://cran.r-project.org/web/packages/mclogit/mclogit.pdf


::: {.cell}

```{.r .cell-code}
health_m <- brm(HealthGen ~ PhysActive + Age, family=categorical, cores = 4, chains = 4, data = nhanes_adult)
```
:::


