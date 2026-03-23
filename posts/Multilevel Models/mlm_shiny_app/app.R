library(shiny)
library(tidyverse)
library(easystats)
library(lme4)
library(broom)
library(broom.mixed)
library(patchwork)

ui <- fluidPage(
  titlePanel("OLS vs. MLM: Why Clustering Matters"),
  p("Use the sliders to change the data generating process. Watch how OLS and MLM behave differently as you increase between-group variability."),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      sliderInput("n_groups", "Number of groups:",
                  min = 5, max = 100, value = 30, step = 5),
      sliderInput("n_per", "Observations per group:",
                  min = 5, max = 50, value = 10, step = 5),
      sliderInput("group_sd", "Between-group SD (clustering strength):",
                  min = 0, max = 10, value = 3, step = 0.5),
      sliderInput("true_slope", "True slope of X:",
                  min = -2, max = 2, value = 0, step = 0.1),
      sliderInput("residual_sd", "Within-group (residual) SD:",
                  min = 0.5, max = 5, value = 1, step = 0.5),
      actionButton("resim", "Re-simulate (new random draw)",
                   class = "btn-primary"),
      hr(),
      helpText("When between-group SD = 0, there is no clustering and OLS = MLM.",
               "Increase between-group SD to see how OLS and MLM diverge.")
    ),

    mainPanel(
      width = 9,
      plotOutput("sim_plot"),
      h4("Each group separately"),
      uiOutput("facet_ui"),
      h4("Model comparison"),
      tableOutput("model_table"),
      h4("ICC"),
      verbatimTextOutput("icc_text")
    )
  )
)

server <- function(input, output, session) {

  sim_data <- reactive({
    input$resim

    n_groups <- input$n_groups
    n_per <- input$n_per
    group_effects <- rnorm(n_groups, sd = input$group_sd)

    tibble(
      group = rep(1:n_groups, each = n_per),
      x = rnorm(n_groups * n_per),
      y = 5 + input$true_slope * x + group_effects[group] + rnorm(n_groups * n_per, sd = input$residual_sd)
    )
  })

  output$sim_plot <- renderPlot({
    sim <- sim_data()

    p1 <- sim %>%
      ggplot(aes(x = x, y = y, color = factor(group))) +
      geom_point(size = 2, alpha = 0.5) +
      geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 1.2) +
      labs(y = "Y", x = "X", title = "OLS view (ignores groups)") +
      guides(color = "none") +
      theme_lucid(base_size = 16)

    p2 <- sim %>%
      ggplot(aes(x = x, y = y, color = factor(group))) +
      geom_point(size = 2, alpha = 0.5) +
      geom_smooth(aes(group = group), method = "lm", se = FALSE, linewidth = 0.4, alpha = 0.4) +
      geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 1.2) +
      labs(y = "Y", x = "X", title = "MLM view (group lines shown)") +
      guides(color = "none") +
      theme_lucid(base_size = 16)

    p1 + p2 + plot_layout(ncol = 2)
  }, height = 400, width = 900)

  output$facet_ui <- renderUI({
    n_groups <- input$n_groups
    ncols <- min(n_groups, 10)
    nrows <- ceiling(n_groups / ncols)
    h <- max(250, nrows * 200)
    plotOutput("facet_plot", height = paste0(h, "px"))
  })

  output$facet_plot <- renderPlot({
    sim <- sim_data()

    sim %>%
      ggplot(aes(x = x, y = y, color = factor(group))) +
      geom_point(size = 1.5, alpha = 0.6) +
      geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
      facet_wrap(~group) +
      labs(y = "Y", x = "X", title = "Within each group: is there a relationship?") +
      guides(color = "none") +
      theme_lucid(base_size = 11) +
      theme(strip.text = element_text(size = 8),
            axis.text = element_text(size = 7))
  }, width = 1200)

  output$model_table <- renderTable({
    sim <- sim_data()

    ols <- lm(y ~ x, data = sim)
    mlm <- lmer(y ~ x + (1|group), data = sim)

    bind_rows(
      tidy(ols) %>% filter(term == "x") %>%
        mutate(Model = "OLS (ignores clusters)"),
      tidy(mlm) %>% filter(term == "x") %>%
        mutate(Model = "MLM (random intercept)")
    ) %>%
      mutate(
        `True slope` = input$true_slope,
        Significant = ifelse(p.value < 0.05, "Yes *", "No")
      ) %>%
      select(Model, `True slope`, Estimate = estimate, SE = std.error,
             `p-value` = p.value, Significant) %>%
      mutate(across(where(is.numeric), ~round(.x, 4)))
  }, striped = TRUE, hover = TRUE, spacing = "l")

  output$icc_text <- renderText({
    sim <- sim_data()
    mlm <- lmer(y ~ x + (1|group), data = sim)
    icc_val <- performance::icc(mlm)

    paste0(
      "ICC (adjusted) = ", round(icc_val$ICC_adjusted, 3),
      "  --  ", round(icc_val$ICC_adjusted * 100, 1),
      "% of variance is between groups.\n",
      "Between-group SD = ", input$group_sd,
      ", Within-group SD = ", input$residual_sd,
      ", N groups = ", input$n_groups,
      ", n per group = ", input$n_per
    )
  })
}

shinyApp(ui, server)
