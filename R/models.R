fit_models <- function(d) {
  list(
    unadjusted = lm(turnout ~ education_years, data = d, na.action = na.fail),
    adjusted = lm(turnout ~ education_years + age + income_k,
                  data = d, na.action = na.fail)
  )
}
