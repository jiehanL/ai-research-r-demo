# Reference implementation. The live exercise edits demo/cleaning.R instead.
recode_turnout <- function(x) {
  if (!is.numeric(x) || any(!is.na(x) & !x %in% c(1, 2, 99))) {
    stop("Unexpected turnout code; consult data/codebook.md.")
  }
  ifelse(is.na(x) | x == 99, NA_integer_, ifelse(x == 1, 1L, 0L))
}

prepare_data <- function(raw, recoder = recode_turnout) {
  required <- c("id", "turnout_code", "education_years", "age", "income_k")
  stopifnot(all(required %in% names(raw)), !anyDuplicated(raw$id),
            !anyNA(raw$id), all(raw$age >= 18 & raw$age <= 85))
  d <- raw
  d$turnout <- recoder(d$turnout_code)
  stopifnot(all(is.na(d$turnout) | d$turnout %in% c(0, 1)),
            all(is.na(d$education_years) | d$education_years %in% 8:20),
            all(is.na(d$income_k) | d$income_k >= 0))
  # Freeze one common sample before fitting either specification.
  keep <- complete.cases(d[c("turnout", "education_years", "age", "income_k")])
  audit <- data.frame(
    measure = c("raw_rows", "missing_turnout", "missing_education", "missing_income",
                "excluded_any_required", "analysis_rows"),
    n = c(nrow(d), sum(is.na(d$turnout)), sum(is.na(d$education_years)),
          sum(is.na(d$income_k)), sum(!keep), sum(keep)))
  list(data = d[keep, , drop = FALSE], audit = audit)
}
