# Classroom analysis. Run from the project folder: Rscript --vanilla demo/run.R
if (!file.exists("specification.md")) stop("Open the teaching project folder first.")
source("R/cleaning.R")
source("demo/cleaning.R")
source("demo/models.R")
source("R/reporting.R")

raw <- read.csv("data/raw/synthetic_turnout.csv")
prepared <- prepare_data(raw)
models <- fit_models(prepared$data)
results <- summarize_models(models)

output_dir <- "artifacts/live"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(results, file.path(output_dir, "estimates.csv"), row.names = FALSE)
write.csv(prepared$audit, file.path(output_dir, "sample_audit.csv"), row.names = FALSE)
write.csv(data.frame(id = prepared$data$id), file.path(output_dir, "analysis_ids.csv"), row.names = FALSE)
write_coefficient_plot(results, file.path(output_dir, "education_turnout.png"))
capture.output(sessionInfo(), file = file.path(output_dir, "sessionInfo.txt"))

report <- c(
  "# Education and turnout", "",
  "This example uses simulated respondents. The regressions describe an association.", "",
  "| Model | N | Education coefficient (percentage points) | 95% interval |",
  "|---|---:|---:|---:|"
)
for (i in seq_len(nrow(results))) {
  r <- results[i, ]
  report <- c(report, sprintf("| %s | %d | %.2f | [%.2f, %.2f] |",
                              r$model, r$n, r$estimate_pp, r$lower_pp, r$upper_pp))
}
report <- c(report, "",
  "Each model uses the sample prepared before estimation. The education coefficient is in percentage points per additional year of education.",
  "Intervals use HC3 robust standard errors and a normal approximation. Adding controls does not establish a causal effect.", "",
  "Run `Rscript --vanilla demo/run.R` from the project folder to reproduce these files.",
  "See specification.md for the analysis plan and sessionInfo.txt for the R version."
)
writeLines(report, file.path(output_dir, "report.md"))

print(results[c("model", "n", "estimate_pp", "lower_pp", "upper_pp")],
      row.names = FALSE, digits = 4)
cat("Saved the table, figure, and report in artifacts/live\n")
