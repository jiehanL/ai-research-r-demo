assert <- function(ok, message) {
  if (!isTRUE(ok)) stop(message, call. = FALSE)
}

check_cleaning <- function(recoder) {
  assert(identical(as.integer(recoder(c(1, 2, 99, NA_real_))), c(1L, 0L, NA_integer_, NA_integer_)),
         "Codebook test failed: 1=yes, 2=no, 99/NA=missing. A binary output alone is insufficient.")
  rejected <- inherits(try(recoder(c(1, 7)), silent = TRUE), "try-error")
  assert(rejected, "Unknown turnout codes must stop the analysis.")
  cat("PASS: codebook examples, nonresponse, and unknown-code rejection\n")
}

check_model_contract <- function(fit_fn, d) {
  models <- fit_fn(d)
  assert(identical(names(models), c("unadjusted", "adjusted")),
         "Expected both prespecified models: unadjusted and adjusted.")
  expected <- list(unadjusted = "education_years", adjusted = c("education_years", "age", "income_k"))
  for (name in names(models)) {
    m <- models[[name]]
    assert(identical(attr(terms(m), "term.labels"), expected[[name]]),
           paste("Unexpected formula in", name))
    assert(identical(all.vars(formula(m))[1], "turnout"), "Unexpected outcome.")
    assert(nobs(m) == nrow(d), "Sample size differs from the frozen analysis sample.")
    assert(identical(rownames(model.frame(m)), rownames(d)), "Models changed sample membership or order.")
  }
  cat("PASS: specified formulas and identical sample membership\n")
  invisible(models)
}
