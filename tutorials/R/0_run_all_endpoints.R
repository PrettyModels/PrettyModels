# Run all Private Equtiy Modesl API endpoints
# install.packages("rmarkdown")

# set working directory
if(sys.nframe() == 0L) rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
source("0_helper.R")

source("takahashi_alexander.R")
source("cash_flow_terminator.R")
source("ai_return_nowcaster.R")
source("deal_exit_simulator.R")

rmarkdown::render("takahashi_alexander/takahashi_alexander.Rmd")
rmarkdown::render("takahashi_alexander/cash_flow_expectations.Rmd")
rmarkdown::render("takahashi_alexander/commitment_planner.Rmd")
rmarkdown::render("cash_flow_terminator/cash_flow_expectations.Rmd")
rmarkdown::render("deal_exit_simulator/deal_exit_simulator.Rmd")
rmarkdown::render("ai_return_nowcaster/short_term_return_nowcast.Rmd")
rmarkdown::render("ai_return_nowcaster/sdf_price_range.Rmd")
rmarkdown::render("ai_return_nowcaster/nav_discount.Rmd")
print("D-O-N-E")
