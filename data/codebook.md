# Synthetic turnout data

400 fictional adults, generated for this workshop with seed 20260915. There are no real respondents, consent records, sampling weights, survey clusters, or population estimates. The shipped CSV is the fixed teaching input; the generation script documents its origin.

| Variable | Meaning | Valid values / missing values |
|---|---|---|
| id | Fictional respondent ID | P001–P400; unique, never missing |
| turnout_code | Reported voting | 1 = yes; 2 = no; 99 = no response |
| education_years | Years of education | Integer 8–20; blank = missing |
| age | Age in years | Integer 18–80 |
| income_k | Annual income, thousands of fictional currency units | Nonnegative number; blank = missing |

Derived `turnout`: 1 for code 1, 0 for code 2, NA for code 99 or NA. Reject unrecognized nonmissing codes. A test that only checks whether derived values are 0/1 will miss the intentionally incorrect recode.

Select complete cases for turnout, education, age, and income **once**, before fitting either model. Keep the IDs. Marginal missingness counts overlap and must not be added to obtain total exclusions.

The generator includes a latent common cause of education and turnout. The observed regression coefficients are descriptive and should not be described as the causal return to education. The chosen missingness process is for a classroom demonstration, not a model of survey nonresponse.
