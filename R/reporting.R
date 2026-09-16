# HC3 covariance for this workshop's unweighted, full-rank OLS models.
# For applied projects use a maintained estimator appropriate to the design.
vcov_hc3 <- function(model) {
  x <- model.matrix(model)
  if (model$rank != ncol(x) || any(hatvalues(model) >= 1 - 1e-10)) {
    stop("HC3 requires full rank and leverage below one.")
  }
  bread <- solve(crossprod(x))
  adjusted_x <- x * as.numeric(residuals(model) / (1 - hatvalues(model)))
  bread %*% crossprod(adjusted_x) %*% bread
}

summarize_models <- function(models) {
  do.call(rbind, lapply(names(models), function(name) {
    m <- models[[name]]
    estimate <- unname(coef(m)["education_years"])
    se <- sqrt(vcov_hc3(m)["education_years", "education_years"])
    data.frame(model = name, n = nobs(m), estimate_pp = 100 * estimate,
               se_pp = 100 * se, lower_pp = 100 * (estimate - qnorm(.975) * se),
               upper_pp = 100 * (estimate + qnorm(.975) * se),
               interval = "HC3; normal approximation; 95%")
  }))
}

write_coefficient_plot <- function(results, path) {
  png(path, width = 1400, height = 750, res = 150)
  on.exit(dev.off())
  par(mar = c(5, 8, 4, 2), family = "sans", las = 1)
  y <- rev(seq_len(nrow(results)))
  limits <- range(c(0, results$lower_pp, results$upper_pp))
  plot(results$estimate_pp, y, xlim = limits + c(-.5, .5),
       ylim = c(.5, nrow(results) + .5), yaxt = "n", pch = 19,
       col = "#12665B", cex = 1.6, ylab = "",
       xlab = "Turnout association per additional year of education (percentage points)",
       main = "Synthetic teaching data: association, not a causal effect")
  axis(2, at = y, labels = results$model)
  abline(v = 0, lty = 2, col = "#999999")
  segments(results$lower_pp, y, results$upper_pp, y, lwd = 3, col = "#12665B")
  points(results$estimate_pp, y, pch = 19, col = "#12665B", cex = 1.6)
  mtext("95% HC3 intervals, normal approximation; identical complete-case sample", side = 3, cex = .8)
}

write_report <- function(results, audit, output_dir) {
  write.csv(results, file.path(output_dir, "estimates.csv"), row.names = FALSE)
  write.csv(audit, file.path(output_dir, "sample_audit.csv"), row.names = FALSE)
  write_coefficient_plot(results, file.path(output_dir, "education_turnout.png"))
  lines <- c("# Education and turnout: synthetic teaching analysis", "",
    "All observations are simulated. These are descriptive associations in a selected complete-case sample.",
    "No real population estimate or causal effect is established.", "",
    "| Specification | N | Association (pp/year) | 95% HC3 interval |",
    "|---|---:|---:|---:|")
  for (i in seq_len(nrow(results))) {
    r <- results[i, ]
    lines <- c(lines, sprintf("| %s | %d | %.2f | [%.2f, %.2f] |", r$model, r$n,
                             r$estimate_pp, r$lower_pp, r$upper_pp))
  }
  lines <- c(lines, "", "Intervals use a normal approximation. Both models use the same complete-case sample.",
    "The adjusted model includes age and income. Covariate adjustment does not establish identification.",
    "HC3 addresses heteroskedasticity under independent observations; it does not solve confounding or selection.",
    "The linear probability model is a teaching choice and may predict outside [0,1].", "",
    "## Sample accounting", "",
    paste(audit$measure, audit$n, sep = ": "), "",
    "Missingness counts overlap; only excluded_any_required is the total excluded.", "",
    "## Reproduction", "", "Run `Rscript --vanilla run.R` from the project root.",
    "See specification.md, provenance.csv, file_manifest.csv, and sessionInfo.txt.")
  writeLines(lines, file.path(output_dir, "report.md"))
}
