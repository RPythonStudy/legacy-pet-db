#' Fill NA PtID values using reference table (by PtName and ExamDate)
#'
#' For rows with missing PtID values in the target data.table,
#' this function fills them using matching values from a reference table,
#' where PtName and ExamDate match, and the PtID is uniquely defined.
#'
#' @param target_dt data.table to be updated (must contain PtName, ExamDate, PtID)
#' @param reference_dt data.table providing the correct PtID mapping
#' @return Updated copy of target_dt with filled PtID values where applicable
my_fill_na_ptid_by_reference <- function(target_dt, reference_dt) {
  required_cols <- c("PtName", "ExamDate", "PtID")
  stopifnot(all(required_cols %in% names(target_dt)))
  stopifnot(all(required_cols %in% names(reference_dt)))
  
  # Step 1: Extract rows where PtID is missing
  target_missing <- target_dt[is.na(PtID)]
  
  # Step 2: Create a reference map where PtName + ExamDate maps to exactly one PtID
  reference_map <- reference_dt[
    !is.na(PtID),
    .(n_unique = uniqueN(PtID), PtID = unique(PtID)),
    by = .(PtName, ExamDate)
  ][n_unique == 1, .(PtName, ExamDate, PtID)]
  
  # Step 3: Merge and fill in missing PtID
  target_missing[
    reference_map,
    on = .(PtName, ExamDate),
    PtID := i.PtID
  ]
  
  # Step 4: Integrate updated rows back into the full dataset
  updated_dt <- copy(target_dt)
  updated_dt[is.na(PtID)] <- target_missing
  
  return(updated_dt)
}
