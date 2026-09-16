# The supplied raw CSV is already fixed. Use this only to regenerate a fresh copy.
# Existing raw data require the explicit --overwrite argument.
if (file.exists("data/raw/synthetic_turnout.csv") &&
    !"--overwrite" %in% commandArgs(trailingOnly = TRUE)) {
  stop("Raw teaching data already exist. Use --overwrite only when intentionally regenerating.")
}
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(20260915)
n <- 400L
unobserved <- rnorm(n)
age <- sample(18:80, n, replace = TRUE)
education_years <- round(pmin(20, pmax(8, 13 + 1.6 * unobserved + rnorm(n, 0, 2))))
income_k <- round(pmax(5, 15 + 3 * education_years + .15 * age + 4 * unobserved + rnorm(n, 0, 14)), 1)
prob <- plogis(-1.1 + .13 * (education_years - 12) + .025 * (age - 40) +
                 .009 * (income_k - 50) + .6 * unobserved)
turnout_code <- ifelse(rbinom(n, 1, prob) == 1, 1L, 2L)
turnout_code[sample.int(n, 20)] <- 99L
education_years[sample.int(n, 12)] <- NA
income_k[sample.int(n, 18)] <- NA
d <- data.frame(id = sprintf("P%03d", seq_len(n)), turnout_code, education_years, age, income_k)
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
write.csv(d, "data/raw/synthetic_turnout.csv", row.names = FALSE, na = "")
write.csv(data.frame(path = "data/raw/synthetic_turnout.csv",
                    md5 = unname(tools::md5sum("data/raw/synthetic_turnout.csv"))),
          "data/raw/manifest.csv", row.names = FALSE)
cat("Generated 400 fictional records. No real respondents or population inference.\n")
