# PET 준비기록 분석 프로젝트

> 이 README.md는 GitHub Copilot 지침서 목적으로 작성되어 일반적인 README와 구조가 다를 수 있습니다. 기술적 세부사항과 코딩 컨벤션에 중점을 두고 있습니다.

## 프로젝트 개요

### 목적
- PET 준비기록을 판독과 PACS 영상과의 연계분석으로 보존이 필요한 기간을 분석

### 데이터 소스 및 기간 (EXACT DATES FOR COPILOT)
- **readings_ocs**: OCS PET 판독기록 (2000-07-04 ~ 2016-12-31)
- **readings_pacs**: PACS PET 판독기록 (2003-05-12 ~ 2016-12-31)  
- **readings_access**: Access PET 판독기록 (1997-07-16 ~ 2009-07-09)
- **preparations_ocs**: OCS PET 준비기록 (2000년대 ~ 2016-12-31)
- **preparations_access**: Access PET 준비기록 (2000-05-02 ~ 2009-08-07)

### 분석 전략 (COPILOT FILTERING RULES)
- **분석 기간**: 2003-05-12 ~ 2016-12-31 (주요 분석)
- **보조 분석**: 2000-07-04 ~ 2003-05-11
- **Outside PET 제외**: 모든 데이터셋에서 외부 PET 검사 제외
  ```r
  # ALWAYS exclude outside PET
  data <- data[!grepl("outside", item_name, ignore.case = TRUE)]
  ```

## 개발 가이드

### **핵심 작성지침 (COPILOT COLLABORATION RULES)**
> **가장 중요한 규칙**: GitHub Copilot과의 협업을 위한 필수 지침

1. **코드 가독성 우선** (READABILITY FIRST)
   - 코드는 중급자가 이해할 수 있는 수준으로 작성이 원칙
   - 복잡한 로직보다 디버깅이 용이한 구조 선택

2. **단계별 검증 필수** (STEP-BY-STEP VERIFICATION)
   - 모든 데이터 처리 단계 및 각 실행단계 마다 DEBUG 로그로 검증하는 것이 원칙
   - 오류 발생 시 정확한 지점 파악 가능하도록 구성

3. **DEBUG 로그 활용** (MANDATORY DEBUG LOGGING)
   ```r
   # 모든 주요 작업 후 반드시 검증
   result <- my_process_data(input_data)
   log_debug("처리 결과 행 수: %d", nrow(result))
   log_debug("처리 결과 컬럼: %s", paste(names(result), collapse = ", "))
   
   # 완성 후에는 로그 레벨 조정으로 깔끔한 출력
   # LOG_LEVEL을 "INFO"로 설정하면 DEBUG 메시지는 숨겨짐
   log_info("데이터 처리 완료")
   ```

4. **Copilot 오류 대응** (ERROR HANDLING FOR AI COLLABORATION)
   - Copilot 생성 코드는 반드시 단계별 실행 및 검증
   - 오류 메시지와 DEBUG 출력을 정확히 기록하여 수정 요청
   - 검증된 코드만 최종 채택

5. **문법 선택 원칙** (SYNTAX SELECTION RULES)
   - data.table 문법을 우선 사용하되, 디버깅이 어려운 경우 가독성 우선
   - 복잡한 data.table 체이닝보다 단계별 처리로 디버깅 용이성 확보
   ```r
   # PREFERRED: data.table 문법
   result <- data[condition, .(col1, col2)]
   
   # ACCEPTABLE: 디버깅이 쉬운 경우
   filtered_data <- data[condition]
   result <- filtered_data[, .(col1, col2)]
   log_debug("필터링 후 행 수: %d", nrow(filtered_data))
   ```

### 데이터 처리 패턴 (COPILOT CODE TEMPLATES)
```r
# 엑셀 파일 일괄 읽기 (STANDARD PATTERN)
data <- my_read_excel_dir("./data/raw/directory/", pattern = "\\.xlsx$")
log_debug("읽은 파일 수: %d", length(unique(data$source_file)))
log_debug("총 데이터 행 수: %d", nrow(data))

# 날짜 변환 (Excel 시리얼 날짜 - ALWAYS USE THIS PATTERN)
data[, date_col := as.Date(as.numeric(date_col), origin = "1899-12-30")]
log_debug("날짜 변환 완료, NA 개수: %d", sum(is.na(data$date_col)))

# NA 값 채우기 (참조 데이터 사용 - MEDICAL DATA SPECIFIC)
filled_data <- my_fill_dates_by_reference(na_data, reference_data)
log_debug("NA 채우기 전: %d", sum(is.na(na_data$date_col)))
log_debug("NA 채우기 후: %d", sum(is.na(filled_data$date_col)))
```

### 사용자정의함수 스타일 (COPILOT FUNCTION CONVENTIONS)
- **함수명**: `my_` 접두사 사용 (MANDATORY PREFIX)
- **파라미터**: 명확한 의미의 영문명 (NO KOREAN PARAMS)
  ```r
  # CURRENT PROJECT: Simple logging for clarity
  log_debug("데이터 처리 시작")
  log_info("환자 수: %d", nrow(data))
  
  # FUTURE COMPLEX PROJECTS: Consider structured logging
  # library(logger)
  # log_info("Processing started for {nrow(data)} patients")
  ```
- **에러 처리**: 간단명료한 검증 (MINIMAL ERROR HANDLING)
- **반환값**: 원본과 동일한 구조 유지 (PRESERVE STRUCTURE)
- **단계별 검증**: 모든 함수는 입력/출력 검증 포함 (VERIFICATION REQUIRED)
  ```r
  my_example_function <- function(input_data) {
    log_debug("입력: %d행", nrow(input_data))
    
    # 실제 처리
    result <- process_data(input_data)
    
    log_debug("출력: %d행", nrow(result))
    return(result)
  }
  ```

### 데이터 검증 및 정제 (COPILOT VALIDATION PATTERNS)
```r
# 환자번호 형식 검증 (MEDICAL ID VALIDATION)
invalid_data <- my_filter_invalid_ptid(data, "PtID")

# 날짜 범위 필터링 (DATE RANGE FILTERING)
filtered_data <- data[date_col >= as.Date("2003-05-12") & 
                     date_col <= as.Date("2016-12-31")]

# outside PET 제외 (EXCLUDE EXTERNAL STUDIES)
clean_data <- data[!grepl("outside", item_name, ignore.case = TRUE)]
```

## 코딩 스타일 (COPILOT CODING CONVENTIONS)
- **R**: snake_case, data.table 문법 우선하되 디버깅 용이성 고려
- **함수**: 중급자 이해 우선, 적절한 복잡성 허용
- **날짜**: Date 클래스 사용, Excel 시리얼 변환 패턴 통일
- **문법 우선순위**: data.table > dplyr > base R (단, 디버깅 어려운 경우 예외)

## 데이터 매칭 전략 (COPILOT MATCHING RULES)
- **환자번호 + 검사일자**: 기본 매칭 키
- **환자이름 + 검사일자**: 환자번호 오류 시 대안
- **±7일 범위**: 날짜 오차 허용 매칭
- **첫 번째 매치**: 중복 매칭 시 첫 번째 결과 사용

