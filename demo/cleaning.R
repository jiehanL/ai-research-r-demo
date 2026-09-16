# INTENTIONALLY WRONG. Edit only this function during demo 1.
# Both 1 (yes) and 2 (no) are positive; 99 means nonresponse.
recode_turnout <- function(x) {
  ifelse(x > 0, 1L, 0L)
}


# recode_turnout <- function(x) {
#   valid <- is.na(x) | x %in% c(1, 2, 99)
#   
#   if (any(!valid)) {
#     stop(
#       "Invalid turnout code(s): ",
#       paste(unique(x[!valid]), collapse = ", ")
#     )
#   }
#   
#   ifelse(
#     is.na(x) | x == 99, NA_integer_,
#     ifelse(x == 1, 1L, 0L)
#   )
# }