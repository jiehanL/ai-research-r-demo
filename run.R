# Run from the repository root: Rscript --vanilla run.R [--demo]
args <- commandArgs(trailingOnly = TRUE)
if (any(!args %in% "--demo")) stop("Usage: Rscript --vanilla run.R [--demo]")
if (!file.exists("specification.md")) stop("Run from the repository root (open the .Rproj file first).")
demo <- "--demo" %in% args
source("R/cleaning.R")
source("R/reporting.R")
source("tests/helpers.R")
source(if (demo) "demo/cleaning.R" else "R/cleaning.R")
source(if (demo) "demo/models.R" else "R/models.R")
check_cleaning(recode_turnout)
manifest <- read.csv("data/raw/manifest.csv", stringsAsFactors = FALSE)
assert(identical(unname(tools::md5sum(manifest$path)), manifest$md5), "Raw data checksum mismatch.")
raw <- read.csv("data/raw/synthetic_turnout.csv")
prepared <- prepare_data(raw)
models <- fit_models(prepared$data)
if (!demo || "adjusted" %in% names(models)) check_model_contract(fit_models, prepared$data)
result <- summarize_models(models)
output_dir <- file.path("artifacts", if (demo) "live" else "reference")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write_report(result, prepared$audit, output_dir)
write.csv(data.frame(id = prepared$data$id), file.path(output_dir, "analysis_ids.csv"), row.names = FALSE)
capture.output(sessionInfo(), file = file.path(output_dir, "sessionInfo.txt"))
git_commit <- "unavailable; distribution archive or Git not installed"
if (nzchar(Sys.which("git")) && dir.exists(".git")) {
  revision <- suppressWarnings(system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE))
  if (length(revision) && is.null(attr(revision, "status"))) git_commit <- revision[1]
}
write.csv(data.frame(key = c("run_time_utc", "R_version", "mode", "git_commit", "data_origin", "interval"),
                    value = c(format(Sys.time(), tz = "UTC", usetz = TRUE), R.version.string,
                              if (demo) "live exercise" else "reference", git_commit,
                              "synthetic; seed 20260915; 400 observations", "95% HC3, normal approximation")),
          file.path(output_dir, "provenance.csv"), row.names = FALSE)
input_files <- c("data/raw/synthetic_turnout.csv", "specification.md", "R/cleaning.R", "R/reporting.R",
                 "tests/helpers.R", "run.R", if (demo) c("demo/cleaning.R", "demo/models.R") else "R/models.R")
write.csv(data.frame(path = input_files, md5 = unname(tools::md5sum(input_files))),
          file.path(output_dir, "file_manifest.csv"), row.names = FALSE)
print(result, row.names = FALSE, digits = 4)
cat("Wrote", output_dir, "\n")
