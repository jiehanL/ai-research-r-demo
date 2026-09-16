# Demo 2 starts with one model. Add the prespecified adjusted model here.
fit_models <- function(d) {
  list(unadjusted = lm(turnout ~ education_years, data = d, na.action = na.fail))
}
