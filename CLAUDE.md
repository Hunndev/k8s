# k8s-hb — Claude 동작 가이드

`/k8s-survey`, `/k8s-troubleshoot`가 항상 따르는 운영 규칙. 세부 절차는 `commands/*.md` 참조.

## 핵심 전제

- 모든 사이트 **air-gapped** — Claude는 사무실 측, 클러스터 직접 접근 불가
- 데이터 채널: (1) paste된 이메일/로그, (2) 사용자가 종이로 받아 전달한 내용
- **80% 케이스는 이메일 분석만으로 해결**. 출장은 마지막 수단

## 레포 구조

```
commands/         /k8s-survey, /k8s-troubleshoot 정의
sites/_TEMPLATE/  신규 사이트 6파일 골격
sites/SCHEMA.md   frontmatter 스키마 (필수 준수)
scripts/site-validate.sh   사이트 디렉토리 검증
tests/site-validate.bats   bats 자동 검사
```

실제 사이트 데이터는 `$K8S_HB_SITES_PATH`에 분리 저장. 플러그인 내장 `sites/`는 시연용.

## sites_path 해석 (진입 시 필수)

1. `K8S_HB_SITES_PATH` 환경변수
2. 아래 `sites_path:` 선언 (env 미설정 시)
3. 둘 다 없으면 **fail-loud 종료** — `commands/CLAUDE.md`의 메시지 출력 후 작업 중단. fallback 없음.

<!-- sites_path: /Users/yunhunbin/k8s-hb-sites -->

## 사이트 컨텍스트 로딩 순서

`sites/<customer>/` 존재 시 양 명령어가 이 순서로 읽는다 (목표 ≤20KB/호출):

```
00-overview.md, 06-deployment-style.md, 07-stack.md  (필수)
13-known-issues.md  (있으면)
14-history.md       (마지막 5건)
```

신규 파일 작성 시 frontmatter는 `$K8S_HB_SITES_PATH/SCHEMA.md` 준수. 자세한 작성 규칙은 `sites/CLAUDE.md`.

## 동작 약속

- **파일 수정은 사용자 yes 후에만** — `/k8s-survey` 생성, `/k8s-troubleshoot`의 14-history 1줄 추가 모두
- **모순 감지 ★** — sites/ 기록과 paste된 이메일/로그가 충돌하면 추론 중단, 사용자에게 어느 쪽이 정확한지 확인
- **/k8s-survey는 대화형** — 한 번에 2-3개씩 질문, 모르면 `(TODO: 추후 보완)`, "있는 것만 기록"
- **/k8s-troubleshoot 분기** — 90%+ 확신이면 회신 초안, 그 외엔 출장 브리핑 + 종이 폼

## 종이 폼 (출장 분기 전용)

`/k8s-troubleshoot`이 출장 결정 시에만 생성. `/k8s-survey`는 종이 폼 안 만듦.

- 순수 마크다운, A4 1-2장, 가설 3개 이내
- 체크박스 `- [ ]`, 명령은 ` ```bash ` 코드펜스 (오기 방지)
- 상단: 사이트명·작업일·작성자·연락처 / 하단: "복귀 후 Claude와 대화로 결과 알려주세요"

## 검증 명령

```bash
bash scripts/site-validate.sh $K8S_HB_SITES_PATH/<customer>   # 사이트 검증
bats tests/site-validate.bats                                  # 플러그인 자체 테스트
```

## 사용자 페르소나

한국어 K8s 운영 엔지니어(초급~시니어). 시간이 귀함 — 장황한 설명보다 **결정 가능한 정보를 빠르게**. 답변은 한국어, 명령어·파일명·K8s 식별자는 원문 그대로.

## 안 하는 것 (v1)

다른 `/k8s-*` 명령어 자동 호출, runbook 자동 로딩, PDF/CSS/QR 생성, 사이트 데이터 자동 백업·푸시 — 전부 v1 out-of-scope.

## 참고

- 사용자 가이드: `README.md`
- 내부 설계·테스트 plan: 작성자 로컬 `~/.gstack/projects/k8s-hb/`
