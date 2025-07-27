# .Rprofile for legacy-pet-data
# --------------------------------------------

# 1. renv: 프로젝트별 패키지 환경 격리
if (file.exists("renv/activate.R")) {
  source("renv/activate.R")
}

# 2. logger 패키지 기반 로깅
if (!requireNamespace("logger", quietly = TRUE)) install.packages("logger")
library(logger)

# 로그 디렉토리/파일 준비
log_dir <- "logs"
if (!dir.exists(log_dir)) dir.create(log_dir)
log_file <- file.path(log_dir, "legacy-pet-data.log")

# 콘솔+파일 동시 출력
log_appender(appender_console)

# 업계표준 로그 포맷: 타임스탬프, LEVEL, PID, 호출함수:라인, 메시지
log_layout(layout_glue_generator(
  format = '[{format(time, "%Y-%m-%d %H:%M:%S")}] [{toupper(level)}]{if (exists("caller")) paste0(" [", caller, "]") else ""} {msg}'
))


# 로그레벨: 환경변수 우선, 기본은 DEBUG
log_level <- Sys.getenv("LOG_LEVEL", "DEBUG")
log_threshold(log_level)

# 초기화 메시지
log_info("Legacy PET Data 분석 시작 - 로깅 레벨: {log_level}")
