my_validate_ptid <- function(dt, col_name) {
  # 패턴1: 4~8자리 숫자만
  # 패턴2: T, S, E(대소문자 무관)로 시작하는 값 허용
  pattern <- "^\\d{4,8}$|^T.*|^S.*|^E.*"
  
  invalid_dt <- dt[!grepl(pattern, get(col_name), ignore.case = TRUE), ]
  
  return(invalid_dt)
}