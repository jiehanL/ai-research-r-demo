# Add the second regression and produce the results

The instructor has used chat to repair the turnout recode in `demo/cleaning.R`. Continue the analysis using the project files.

Read `specification.md` and `data/codebook.md`. In `demo/models.R`, keep the education-only regression and add the regression with age and income. Keep the list names `unadjusted` and `adjusted`. Use the supplied data `d` for both models, with the same respondents and these formulas:

```r
turnout ~ education_years
turnout ~ education_years + age + income_k
```

Run the classroom analysis:

```sh
Rscript --vanilla demo/run.R
```

Read the table in `artifacts/live/estimates.csv` and view `artifacts/live/education_turnout.png` if your tools allow it. Explain the change and give a short interpretation of the education coefficients, identifying the data as simulated. Tell the instructor if you could not run R or view the figure.

Show the edit to `demo/models.R` using Git. Leave it for the instructor to review and commit. Keep the data, analysis plan, and completed examples as they are. The supplied script already produces the table, figure, and report. Separate test commands are optional work after class.
