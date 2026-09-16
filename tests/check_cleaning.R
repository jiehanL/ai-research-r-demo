args <- commandArgs(trailingOnly = TRUE)
path <- if (length(args)) args[1] else "R/cleaning.R"
source("tests/helpers.R")
source(path)
check_cleaning(recode_turnout)
