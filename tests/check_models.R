args <- commandArgs(trailingOnly = TRUE)
path <- if (length(args)) args[1] else "R/models.R"
source("tests/helpers.R")
source("R/cleaning.R")
source(path)
d <- prepare_data(read.csv("data/raw/synthetic_turnout.csv"))$data
check_model_contract(fit_models, d)
