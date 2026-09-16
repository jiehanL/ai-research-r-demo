source("tests/helpers.R")
source("R/cleaning.R")
source("R/models.R")
source("R/reporting.R")
check_cleaning(recode_turnout)
raw <- read.csv("data/raw/synthetic_turnout.csv")
p <- prepare_data(raw)
assert(nrow(raw) == 400, "Unexpected teaching dataset size.")
assert(nrow(p$data) == sum(complete.cases(transform(raw, turnout_code = recode_turnout(turnout_code)))),
       "Complete-case sample differs from direct calculation.")
assert(!anyDuplicated(p$data$id), "Duplicate analysis IDs.")
duplicate <- rbind(raw, raw[1, ])
assert(inherits(try(prepare_data(duplicate), silent = TRUE), "try-error"), "Duplicate IDs must fail.")
models <- check_model_contract(fit_models, p$data)
result <- summarize_models(models)
# An independent scalar calculation checks the unadjusted slope.
direct_slope <- cov(p$data$education_years, p$data$turnout) / var(p$data$education_years)
assert(abs(result$estimate_pp[1] / 100 - direct_slope) < 1e-12, "Independent slope check failed.")
# HC3 also equals the crossproduct of leave-one-out coefficient changes.
beta_full <- coef(models$adjusted)
loo_changes <- t(vapply(seq_len(nrow(p$data)), function(i) {
  coef(lm(turnout ~ education_years + age + income_k, data = p$data[-i, ])) - beta_full
}, numeric(length(beta_full))))
assert(max(abs(vcov_hc3(models$adjusted) - crossprod(loo_changes))) < 1e-9,
       "HC3 disagrees with the independent leave-one-out calculation.")
assert(all(is.finite(as.matrix(result[c("estimate_pp", "lower_pp", "upper_pp")]))), "Nonfinite results.")
assert(all(result$lower_pp <= result$estimate_pp & result$estimate_pp <= result$upper_pp), "Invalid intervals.")
manifest <- read.csv("data/raw/manifest.csv", stringsAsFactors = FALSE)
assert(identical(unname(tools::md5sum(manifest$path)), manifest$md5), "Raw input changed.")
cat("PASS: sample accounting, duplicate rejection, independent slope and HC3 checks, input checksum\n")
cat("All reference tests passed. Scientific interpretation still requires human review.\n")
