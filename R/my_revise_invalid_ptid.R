library(dplyr)

my_revise_invalid_ptid <- function(invalid_dt, preparation_dt) {
  # 1차: PtName + ExamDate로 join
  revised <- invalid_dt %>%
    left_join(preparation_dt %>% select(PtName, ExamDate, PtID), 
              by = c("PtName", "ExamDate"), 
              suffix = c("", ".prep1")) %>%
    mutate(
      PtID = ifelse(!is.na(PtID.prep1), PtID.prep1, PtID)
    ) %>%
    select(-PtID.prep1)
  
  # 2차: 각 NA행별로 PtName의 preparation에서 유효 PtID가 하나만 있으면 대입
  na_rows <- revised %>% filter(is.na(PtID))
  if(nrow(na_rows) > 0) {
    na_rows_filled <- na_rows %>%
      rowwise() %>%
      mutate(
        # 해당 PtName으로 preparation에서 NA가 아닌 유일 PtID만 있으면 대입, 아니면 NA 유지
        PtID_fill = {
          vals <- unique(preparation_dt$PtID[preparation_dt$PtName == PtName & !is.na(preparation_dt$PtID)])
          if(length(vals) == 1) vals else NA
        }
      ) %>%
      ungroup() %>%
      mutate(
        PtID = ifelse(!is.na(PtID_fill), PtID_fill, PtID)
      ) %>%
      select(-PtID_fill)
    
    # 디버깅: 실제로 보정된 케이스만 보여주기
    cat("[디버깅] 유일한 PtID로 보정된 이름:\n")
    print(na_rows_filled %>% filter(!is.na(PtID)))
    cat("[디버깅] 보정 실패(여전히 NA)인 이름:\n")
    print(na_rows_filled %>% filter(is.na(PtID)))
    
    revised <- revised %>%
      filter(!is.na(PtID)) %>%
      bind_rows(na_rows_filled)
  }
  
  return(revised)
}
