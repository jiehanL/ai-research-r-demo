# AI and social science research in R

An 80-minute workshop for people who use R and are new to Git and coding agents. The data describe 400 simulated respondents.

## The classroom workflow

1. Use chat to explain and repair the turnout recode in `demo/cleaning.R`.
2. Try the corrected function on `c(1, 2, 99, NA)`. It should return `1, 0, NA, NA`.
3. Review the edit in Git and commit it.
4. Ask Codex to follow `demo/agent_task.md`. It adds the second regression and runs the analysis.
5. Read the code changes and results. Commit the work you accept, then sync with GitHub if you have a shared repository ready.

The classroom analysis uses one command, from the project folder in RStudio's **Terminal**:

```sh
Rscript --vanilla demo/run.R
```

It writes `estimates.csv`, `education_turnout.png`, `report.md`, the sample information, and the R version under `artifacts/live/`. The two exercise files need to be completed before the two-model results are available. The original starting recode is deliberately incorrect.

The script uses packages included with R. R 4.1 or later is required. `--vanilla` starts without saved workspaces or startup settings. The supplied R analysis needs no network connection. A cloud coding agent still uses its normal model service.

## Before class and backup results

Open `ai-research-r-demo.Rproj` in a fresh teaching copy. Prepare the completed example before class:

```sh
Rscript --vanilla run.R
```

This uses the completed functions in `R/` and saves its outputs in `artifacts/reference/`. Those functions and results are available if the live response is slow. Practice in a separate copy so the exercise files remain in their starting state for class.

## Files to know

| File or folder | Purpose |
|---|---|
| `specification.md` | Research question, sample, and planned regressions |
| `data/codebook.md` | Variable definitions |
| `data/raw/` | Fixed simulated data |
| `demo/cleaning.R` | Recode to repair with chat |
| `demo/models.R` | Regression function for the agent to extend |
| `demo/agent_task.md` | Saved request for the agent |
| `demo/run.R` | Classroom analysis command |
| `demo/prompts.md` | Short instructions for both demonstrations |
| `R/` | Completed example and reporting functions |
| `AGENTS.md` | Notes for an agent working on this project |
| `.agents/skills/research-review/` | Example instructions for reviewing an analysis |
| `tests/` | Additional checks for work after class |
| `api/` | Optional survey-text coding example |

## Starting the agent

In Codex, open the teaching folder as a local project and use **Local** mode so it works on the same files as RStudio. After repairing the recode, type:

> Follow the instructions in demo/agent_task.md.

The agent should change `demo/models.R`, run `demo/run.R`, and explain the results. Review the changed file and output yourself. You do not copy the agent's R code from its response into the editor.

For a terminal alternative, with the Codex CLI installed and signed in, use macOS, Linux, or Git Bash from the project folder:

```sh
codex exec --sandbox workspace-write - < demo/agent_task.md
```

Use either the app or this command for the same task. See the [Codex local-project instructions](https://learn.chatgpt.com/docs/projects) and [terminal instructions](https://learn.chatgpt.com/docs/non-interactive-mode).

## Git during the demonstration

Prepare the starting commit and `workshop-demo` branch before class. After the chat correction:

```sh
git --no-pager diff -- demo/cleaning.R
git add demo/cleaning.R
git commit -m "Fix turnout coding"
```

After reviewing the agent's analysis:

```sh
git --no-pager diff -- demo/models.R
git add demo/models.R
git commit -m "Add model with age and income"
git --no-pager log -3 --oneline
```

If you connected a shared GitHub repository beforehand, `git push` sends these saved commits. `git pull` brings shared updates into a local copy. The instructor guide explains how to prepare the connection. Keep setup and sign-in outside the session.

Generated files in `artifacts/` are excluded from routine Git tracking. A coauthor can recreate them with the saved code. Include the final figures and tables separately when sharing or archiving the research materials.

## Optional checks after class

The class uses a small example and direct review of the results. For further checking, the original test files remain available:

```sh
Rscript --vanilla tests/run_tests.R
Rscript --vanilla tests/check_cleaning.R demo/cleaning.R
Rscript --vanilla tests/check_models.R demo/models.R
```

The first command checks the completed reference analysis. The other two check the edited exercise files, including cases beyond the single classroom example. The original `Rscript --vanilla run.R --demo` also runs the exercise analysis with those additional checks and records input hashes. These commands are optional follow-up work.

## Optional API example

The default example uses six invented survey comments and prepared labels, including one deliberate error:

```sh
Rscript --vanilla api/demo_api.R
```

It does not call a model. Its five agreements in six examples are a teaching illustration, not an estimate of model accuracy. The classroom slides use the prepared examples without running this command.

For a live request after class, install `httr2` and `jsonlite` and set `OPENAI_API_KEY` and `OPENAI_MODEL` in your local environment. Choose an available model that supports the Responses API and structured outputs. Keep the key out of shared code. If using an ignored `.Renviron`, restart R and omit `--vanilla` so R reads that file:

```sh
Rscript api/demo_api.R --live
```

This sends the six fictional comments and coding guide, can incur charges, and saves the request information and response. Inspect the saved response before retrying a failed request. Use an approved data environment before substituting real research material.

## Interpretation and reproducibility

The two models use the same 354 respondents. The education coefficients are approximately 6.48 and 4.98 percentage points per year of education. Their 95% HC3 intervals are [4.77, 8.19] and [2.72, 7.24], using a normal approximation. These are associations in simulated data.

Save the data, codebook, analysis plan, accepted scripts, and reported output. Record the prompt and important decisions about AI's work. The classroom script saves R version information. Projects with additional packages can use `renv` to record their versions. When model responses become data, save those responses and the model information too.

## Documentation

- [Git history](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository), [push](https://git-scm.com/docs/git-push), and [pull](https://git-scm.com/docs/git-pull)
- [Connecting a local project to GitHub](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github)
- [R linear models](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html) and [HC estimators](https://cran.r-project.org/web/packages/sandwich/sandwich.pdf)
- [renv](https://rstudio.github.io/renv/articles/renv.html)

All observations and text examples were prepared for teaching.
