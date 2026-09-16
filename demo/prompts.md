# The two classroom demonstrations

## Chat: explain and repair the recode, 26:00–33:00

Show `demo/cleaning.R`. In the R Console, run:

```r
source("demo/cleaning.R")
recode_turnout(c(1, 2, 99, NA))
```

The starting function returns `1 1 1 NA`. Ask chat:

> This R function recodes survey turnout: `recode_turnout <- function(x) { ifelse(x > 0, 1L, 0L) }`. The codebook says 1 means voted, 2 means did not vote, and 99 means no response. Explain the mistake and give me a corrected function returning 1, 0, and NA respectively. Keep existing missing values as NA and flag codes outside the codebook as an error.

Read the answer, replace the function, and save the file. Run the same two Console lines again. The expected result is `1 0 NA NA`.

At 33:00–36:00, review `git diff -- demo/cleaning.R`, then add and commit the corrected file with the message `Fix turnout coding`.

## Agent: add the model and produce the results, 40:00–49:00

Open the teaching folder in Codex, using Local mode. Type:

> Follow the instructions in demo/agent_task.md.

The agent should add the planned model with age and income to `demo/models.R`, then run:

```sh
Rscript --vanilla demo/run.R
```

The saved task contains the details. The instructor reviews the changed file, table, and figure at 49:00–54:00, then commits the accepted work at 54:00–58:00. Sync with GitHub if the shared repository was prepared before class.

A terminal alternative, using the Codex CLI already installed and signed in:

```sh
codex exec --sandbox workspace-write - < demo/agent_task.md
```

This command is for macOS, Linux, or Git Bash. It starts the same agent task without opening an app conversation.

## Prepared examples

After about 90 seconds without a useful response, use the completed function. `R/cleaning.R` contains the recode and `R/models.R` contains the two regressions. Stop an agent run before copying a prepared function into its file.

If R itself is unavailable, use the table and figure prepared before class in `artifacts/reference/`. Explain when you use the completed example.

## Optional material

The research-review skill shows how to save reusable review instructions. Read it during the lesson; a separate live run is unnecessary. Formal tests and the API script are available for exploration after class. The API slides use prepared examples and do not require another command.
