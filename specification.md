# Analysis specification — fixed before the classroom demo

Question: How is education associated with reported turnout in these synthetic observations?

- Unit: fictional adult respondent. Outcome: turnout recoded exactly as in `data/codebook.md`.
- Target quantity: the linear association in percentage points of turnout per additional year of education in the retained complete-case sample. This is not a population or causal effect.
- Sample: complete cases for turnout, education_years, age, and income_k. Freeze that sample for both models. Record IDs and exclusion counts.
- Unadjusted model: `turnout ~ education_years`.
- Adjusted model: `turnout ~ education_years + age + income_k`.
- Estimator: unweighted OLS / linear probability model, with intercepts. Income enters in thousands. No interactions, weights, clusters, or variable selection in this exercise.
- Uncertainty: HC3 heteroskedasticity-consistent standard errors and 95% normal-approximation intervals. Observations are independently generated. In real data, the sampling and assignment design determines weights and clustering; do not copy this default without justification.
- Report: both models, identical N and IDs, coefficients and intervals in percentage points, sample audit, coefficient plot, and a short description with the synthetic-data and associational limitations.
- Acceptance: codebook examples and unknown codes; uniqueness; common sample; exact formulas; independent scalar slope and leave-one-out HC3 checks; raw-data checksum; fresh-session execution.
- Interpretation: adjustment does not supply a causal identification strategy. HC3 does not resolve omitted variables, sample selection, measurement error, or functional-form assumptions. The linear probability model can predict outside [0,1].

Any later specification change must be justified and recorded. Keep exploratory analyses clearly labeled; do not choose specifications because their p-values look favorable.
