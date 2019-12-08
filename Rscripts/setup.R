# setup.R
# clean up ----------------------------------------------------------------

rm(list = ls())
graphics.off()
cat('\014')

file.remove(list.files(pattern = '*.png', full.names = T))

# libraries ---------------------------------------------------------------

library(data.table)
library(dplyr)
library(lubridate)
library(ggplot2)
# library(network)
library(visNetwork)

# custom functions --------------------------------------------------------

source('Rfunctions/naPlot.R')
source('Rfunctions/savePng.R')

# config ------------------------------------------------------------------

config <- list(
  fileName = 'c:/Projects/commonData/my_daily_ride_journeys/journeys.csv'
  , doPlots = T
  , dpi = 100
)
