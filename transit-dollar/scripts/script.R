# install.packages("ggplot2")
# install.packages("here")
# install.packages("dplyr")
# install.packages("scales")
# install.packages("ggtext")

rm(list=ls())

library(ggplot2)
library(here)
library(dplyr)
library(scales)
library(ggtext) # For element_textbox_simple
library(systemfonts) # Add this package

# Set up directory
here::i_am("transit-dollar/scripts/script.R")

# Read data
dt <- read.csv(here("transit-dollar", "data", "rev_src.csv"))

# Reverse order for proper stacking in horizontal bar
dt$revenue_source <- factor(dt$revenue_source, 
                           levels = rev(c("Local/regional (reserved)", 
                                      "Local/regional (discretionary)",
                                      "State (reserved)",
                                      "State (discretionary)")))

# Format percentages
dt$percent_label <- paste0(round(dt$percent * 100), "%")

# Set custom colors with named vector
revenue_colors <- c(
  "Local/regional (reserved)" = "#62bb46",
  "Local/regional (discretionary)" = "#44c8f5",
  "State (reserved)" = "#5d2684",
  "State (discretionary)" = "#939598"
)

#font_import()
# loadfonts(device = "all")  # Adjust based on your OS: "win", "mac", or "unix"

# Define explanatory text for below the chart
explanation_text <- "Local/regional (reserved) sources can include fare revenue, gas tax revenue, transit-specific programs like Commuter Choice, and revenue from Transportation Improvement Districts.

\n\n  Local/regional (discretionary) sources can include transfers from the General Fund, revenue from the sale of bonds, commercial & industrial (C&I) tax revenue, and allocations from NVTA.

\n\n  State (reserved) sources include funding from the Commonwealth Transportation Fund (CTF) and certain programs operated by DRPT.

\n\n  State (discretionary) sources include funding from the General Fund or other non-CTF sources."

# Create plot with the caption set up for proper wrapping
p <- ggplot(dt, aes(x = 1, y = percent, fill = revenue_source)) +
  geom_bar(stat = "identity", width = 0.5, position = position_stack()) +
  coord_flip() +
  scale_fill_manual(values = revenue_colors, 
                    guide = guide_legend(reverse = TRUE)) +
  scale_x_continuous(labels = NULL, breaks = NULL) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1)) +
  labs(
    title = "Where does each $ of revenue for transit come from?",
    x = NULL,
    y = NULL,
    fill = NULL,
    caption = explanation_text
  ) +
  geom_text(
    aes(label = percent_label),
    position = position_stack(vjust = 0.5),
    color = "white",
    fontface = "bold",
    family="Avenir Next"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(family="Avenir Next", size = 16, face = "bold", hjust = 0.5),
    legend.position = "bottom",
    legend.box = "horizontal",
    plot.margin = margin(t = 20, r = 20, b = 20, l = 20),
    axis.text.x = element_text(size = 12, family = "Avenir Next"),
    legend.text = element_text(size = 12, family = "Avenir Next"),
    # Textbox for auto-wrapping caption
    plot.caption = element_textbox_simple(
      family="Avenir Next",
      size = 11,
      color = "grey50",
      margin = margin(t = 15, b = 15),
      lineheight = 1.2,
      hjust = 0,
      halign = 0,
      width = unit(1, "npc"),
      padding = margin(10, 10, 10, 10),
      fill = NA
    ),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

# Print the plot
print(p)

# Save with automatic caption wrapping
ggsave(here("transit-dollar", "output", "revenue_stacked_bar_6_9.png"), p, 
        width = 9, height = 6, dpi = 300, bg = 'white')