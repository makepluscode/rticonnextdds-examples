# Callgrind Visualization Guide

callgrind.out 파일을 시각화하는 여러 방법을 설명합니다.

## 방법 1: kcachegrind (GUI) - 가장 추천 ⭐

**설치:**
```bash
sudo apt-get install kcachegrind
```

**사용법:**
```bash
# 자동으로 열기
./view_callgrind.sh

# 또는 직접 실행
kcachegrind profiling_results/publisher.callgrind.out
```

**kcachegrind 사용법:**
- **왼쪽 패널**: 함수 목록 (비용 순으로 정렬)
  - `Self`: 함수 자체 실행 시간
  - `Called`: 호출 횟수
  - `Incl.`: 포함된 시간 (자식 함수 포함)
  
- **오른쪽 패널**: 호출 그래프
  - 위에서 아래로: 호출자 → 피호출자
  - 함수를 클릭하면 해당 함수의 호출 관계 표시
  
- **필터링**:
  - 검색창에서 함수 이름 검색
  - 특정 라이브러리/모듈만 보기

- **정렬 기준 변경**:
  - Self, Incl., Called 등으로 정렬 가능

---

## 방법 2: qcachegrind (Qt5 버전)

kcachegrind의 Qt5 기반 버전입니다.

**설치:**
```bash
sudo apt-get install qcachegrind
```

**사용법:**
```bash
qcachegrind profiling_results/publisher.callgrind.out
```

---

## 방법 3: callgrind_annotate (텍스트)

GUI가 없는 환경에서 사용합니다.

**기본 사용:**
```bash
callgrind_annotate profiling_results/publisher.callgrind.out | less
```

**상위 함수만 보기:**
```bash
# threshold: 1.0% 이상인 함수만 표시
callgrind_annotate --threshold=1.0 profiling_results/publisher.callgrind.out
```

**특정 함수 검색:**
```bash
callgrind_annotate profiling_results/publisher.callgrind.out | grep -A 10 "write"
```

**결과를 파일로 저장:**
```bash
callgrind_annotate profiling_results/publisher.callgrind.out > report.txt
```

---

## 방법 4: 웹 기반 도구 (선택사항)

### callgrind-web
```bash
# 설치 (Python 필요)
pip install callgrind-web

# 사용
callgrind-web profiling_results/publisher.callgrind.out
# 브라우저에서 http://localhost:5000 열림
```

---

## kcachegrind 주요 기능

### 1. 함수 목록 보기
- 왼쪽 패널에서 함수를 클릭하면 상세 정보 표시
- 정렬 기준 변경: Self, Incl., Called 등

### 2. 호출 그래프
- 함수를 더블클릭하면 호출 그래프로 이동
- 화살표: 호출 방향
- 색상: 비용이 높을수록 진한 색

### 3. 호출자/피호출자 보기
- 함수 선택 시:
  - **Callers**: 이 함수를 호출하는 함수들
  - **Callees**: 이 함수가 호출하는 함수들

### 4. 필터링
- 검색창에서 함수 이름 검색
- 정규표현식 지원

### 5. 내보내기
- File → Export → 이미지나 텍스트로 저장 가능

---

## 해석 팁

### 1. Self vs Incl.
- **Self**: 함수 자체 실행 시간 (자식 함수 제외)
- **Incl.**: 포함된 시간 (자식 함수 포함)

### 2. Hotspot 찾기
- Self 값이 높은 함수 = 병목 지점
- Incl. 값이 높지만 Self가 낮은 함수 = 자식 함수가 무거움

### 3. 호출 횟수 확인
- Called 값이 예상보다 높으면 불필요한 반복 호출 가능성

### 4. DDS 관련 함수
주요 DDS 함수들:
- `write*`: 데이터 쓰기
- `create_*`: 엔티티 생성
- `register_*`: 타입 등록
- 네트워크 관련 함수들

---

## 예제: publisher 분석

```bash
# 1. callgrind 데이터 생성
./profile_valgrind.sh publisher 0 10

# 2. 시각화
./view_callgrind.sh

# 또는 직접
kcachegrind profiling_results/publisher.callgrind.out
```

**분석 포인트:**
1. `write()` 함수의 실행 시간 확인
2. 네트워크 캡처 함수들의 오버헤드 확인
3. DDS 내부 함수들의 호출 패턴 확인

---

## 문제 해결

**kcachegrind가 열리지 않음:**
```bash
# 디스플레이 확인
echo $DISPLAY

# X11 포워딩 (SSH 원격 접속 시)
ssh -X user@host
```

**파일이 너무 커서 느림:**
```bash
# 특정 함수만 필터링
callgrind_annotate --threshold=5.0 profiling_results/publisher.callgrind.out
```

**텍스트 출력만 원함:**
```bash
callgrind_annotate profiling_results/publisher.callgrind.out > report.txt
less report.txt
```

---

## 추가 리소스

- [kcachegrind 매뉴얼](https://kcachegrind.github.io/html/Home.html)
- [Valgrind callgrind 문서](https://valgrind.org/docs/manual/cl-manual.html)

