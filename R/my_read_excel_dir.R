my_read_excel_dir <- function(directory, pattern = "\\.xlsx$") {
  # 파일 경로 목록 추출
  file_paths <- list.files(directory, pattern, full.names = TRUE)
  
  # 각 파일을 문자형으로 읽어 data.table 리스트로 저장
  data_list <- lapply(file_paths, function(file) {
    data.table::as.data.table(readxl::read_excel(file, col_types = "text"))
  })
  
  # 컬럼명 기준으로 행결합, 누락컬럼은 NA로 채움
  data <- data.table::rbindlist(data_list, use.names = TRUE, fill = TRUE)
  
  return(data)
}
