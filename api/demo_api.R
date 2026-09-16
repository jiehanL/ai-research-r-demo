# Offline by default: Rscript --vanilla api/demo_api.R
# Optional paid request: Rscript --vanilla api/demo_api.R --live
args <- commandArgs(trailingOnly = TRUE)
if (any(!args %in% "--live")) stop("Usage: Rscript --vanilla api/demo_api.R [--live]")
live <- "--live" %in% args
source("tests/helpers.R")
texts <- read.csv("api/texts.csv", stringsAsFactors = FALSE)
reference <- read.csv("api/reference_codes.csv", stringsAsFactors = FALSE)
prompt <- paste(readLines("api/prompt.txt"), collapse = "\n")
run_dir <- file.path("artifacts", "api", if (live) format(Sys.time(), "%Y%m%d-%H%M%S") else "illustrative")
dir.create(run_dir, recursive = TRUE, showWarnings = FALSE)
response_id <- "none: constructed teaching fixture"
used_model <- "none"
usage <- "none: no API request"
if (live) {
  if (!requireNamespace("httr2", quietly = TRUE) || !requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Optional live mode needs httr2 and jsonlite; see README.md.")
  }
  api_key <- Sys.getenv("OPENAI_API_KEY")
  requested_model <- Sys.getenv("OPENAI_MODEL")
  if (!nzchar(api_key) || !nzchar(requested_model)) {
    stop("Set OPENAI_API_KEY and OPENAI_MODEL in your local environment, never in source control.")
  }
  schema <- list(type = "object", additionalProperties = FALSE, required = list("codes"),
    properties = list(codes = list(type = "array", items = list(type = "object", additionalProperties = FALSE,
      required = list("id", "label"), properties = list(id = list(type = "string"),
      label = list(type = "string", enum = list("barrier", "no_barrier", "unclear")))))))
  body <- list(model = requested_model, store = FALSE, max_output_tokens = 1500,
    instructions = prompt, input = jsonlite::toJSON(texts, dataframe = "rows", auto_unbox = TRUE),
    text = list(format = list(type = "json_schema", name = "survey_codes", strict = TRUE, schema = schema)))
  jsonlite::write_json(body, file.path(run_dir, "request_without_credentials.json"), auto_unbox = TRUE, pretty = TRUE)
  # One bounded request; no automatic retry loop or hidden corpus upload.
  response <- httr2::request("https://api.openai.com/v1/responses") |>
    httr2::req_auth_bearer_token(api_key) |>
    httr2::req_body_json(body) |>
    httr2::req_timeout(60) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = FALSE)
  saveRDS(response, file.path(run_dir, "response.rds"))
  assert(identical(response$status, "completed"), "Incomplete response: inspect saved response before retrying.")
  output_text <- character()
  for (item in response$output) {
    if (identical(item$type, "message")) {
      for (part in item$content) {
        if (identical(part$type, "refusal")) stop("Model refused; inspect saved response.")
        if (identical(part$type, "output_text")) output_text <- c(output_text, part$text)
      }
    }
  }
  assert(length(output_text) > 0L, "No text output to parse.")
  decoded <- jsonlite::fromJSON(paste(output_text, collapse = "\n"))
  codes <- decoded$codes
  response_id <- response$id
  used_model <- response$model
  usage <- jsonlite::toJSON(response$usage, auto_unbox = TRUE)
} else {
  cat("OFFLINE ILLUSTRATION: constructed example predictions, not a recorded model response.\n")
  codes <- read.csv("api/illustrative_codes.csv", stringsAsFactors = FALSE)
}
assert(is.data.frame(codes) && all(c("id", "label") %in% names(codes)), "Missing expected fields.")
assert(nrow(codes) == nrow(texts) && !anyDuplicated(codes$id) && setequal(codes$id, texts$id), "ID coverage mismatch.")
assert(!anyNA(codes$label) && all(codes$label %in% c("barrier", "no_barrier", "unclear")), "Invalid labels.")
comparison <- merge(reference, codes, by = "id", suffixes = c("_reference", "_prediction"), sort = TRUE)
comparison$agreement <- comparison$label_reference == comparison$label_prediction
write.csv(comparison, file.path(run_dir, "comparison.csv"), row.names = FALSE)
writeLines(prompt, file.path(run_dir, "prompt.txt"))
write.csv(data.frame(key = c("mode", "run_time_utc", "model_returned", "response_id", "usage",
                             "texts_md5", "prompt_md5", "n", "R_version"),
  value = c(if (live) "live" else "constructed illustrative fixture",
            format(Sys.time(), tz = "UTC", usetz = TRUE), used_model, response_id, usage,
            unname(tools::md5sum("api/texts.csv")), unname(tools::md5sum("api/prompt.txt")),
            nrow(texts), R.version.string)), file.path(run_dir, "metadata.csv"), row.names = FALSE)
capture.output(sessionInfo(), file = file.path(run_dir, "sessionInfo.txt"))
print(comparison, row.names = FALSE)
print(table(reference = comparison$label_reference, prediction = comparison$label_prediction))
cat(sum(comparison$agreement), "of", nrow(comparison), "labels agree. Six invented items are not validation evidence.\n")
cat("Wrote", run_dir, "\n")
