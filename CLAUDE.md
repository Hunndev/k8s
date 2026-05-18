# k8s-hb — Claude 동작 가이드

이 파일은 Claude가 `/k8s-survey`와 `/k8s-troubleshoot`를 실행할 때 항상 참조하는 운영 규칙을 정의한다.

## 핵심 전제

- **모든 사이트가 air-gapped다.** Claude는 클러스터에 직접 접근하지 않는다. 데이터 채널은 둘 뿐: (1) 사용자가 paste한 이메일/로그/명령결과, (2) 사용자가 현장에서 종이로 채워와 자연어로 알려준 내용.
- **Claude는 항상 사무실 측에 있다.** 현장 엔지니어가 사이트에 들어가 있을 때 Claude는 부르지 못한다.
- **80%의 케이스는 이메일 분석만으로 해결되어야 한다.** 출장은 마지막 수단.

## `sites_path` 해석 규칙

두 명령어는 **반드시** 진입 시 다음 순서로 sites_path를 결정한다:

1. 환경변수 `K8S_HB_SITES_PATH` 확인
2. 없으면 이 CLAUDE.md의 `sites_path:` 설정값 확인 (아래)
3. 둘 다 없으면 **fail-loud**로 종료. 다음 메시지 출력 후 작업 중단:

```
[k8s-hb] sites/ 경로가 설정되지 않았습니다.

다음 중 하나로 설정해주세요:

  1) 환경변수:
     export K8S_HB_SITES_PATH=<경로>
     (.zshrc/.bashrc에 추가 권장)

  2) 이 CLAUDE.md의 sites_path 설정:
     sites_path: <경로>

설치 가이드: README.md
```

기본값 fallback 없음. 명시적 설정을 강제한다.

<!-- CLAUDE.md sites_path 설정 (env가 없을 때 사용. 주석 해제 후 경로 입력) -->
<!-- sites_path: /Users/yunhunbin/k8s-hb-sites -->

## 명령어 라우팅

| 명령어 | 파일 | 호출 형식 |
|---|---|---|
| `/k8s-survey` | `commands/k8s-survey.md` | `/k8s-survey [<customer>]` |
| `/k8s-troubleshoot` | `commands/k8s-troubleshoot.md` | `/k8s-troubleshoot <customer>` |

## 공통 동작 약속

### A. 사이트 컨텍스트 로딩 순서

`sites/<customer>/`가 존재할 때 두 명령어 모두 같은 순서로 읽는다:

```
1. 00-overview.md   (필수, 항상 로드. frontmatter + 본문)
2. 06-deployment-style.md  (필수)
3. 07-stack.md      (필수)
4. 13-known-issues.md  (있으면 로드)
5. 14-history.md    (마지막 5건만)
```

총 컨텍스트 사용량 목표: 1회 호출당 15-20KB 이하.

### B. 사이트 데이터 자동 수정 권한

- `/k8s-survey` 종료 후 사용자가 결과를 알려주면 → Claude는 변경안을 먼저 보여주고 **사용자 승인 후** sites/<customer>/ 파일을 수정한다. 무단 자동 갱신 금지.
- `/k8s-troubleshoot` 종료 후 14-history.md에 한 줄 추가도 마찬가지로 사용자 승인 후.

### C. 사이트 컨텍스트 vs 이메일 정보 모순 감지 (★)

`/k8s-troubleshoot` 실행 중 sites/<customer>/ 기록과 사용자가 paste한 이메일·로그 사이에 명확한 모순이 발견되면:

- 추론을 계속하지 말고 **즉시 사용자에게 확인 요청**한다
- 예: "이 사이트의 06-deployment-style.md엔 ArgoCD라고 적혀 있는데, 이메일에선 `helm upgrade` 직접 사용을 언급하셨습니다. 어느 쪽이 정확한가요?"
- 사용자 답변 후 진행. 필요 시 sites/06-deployment-style.md 업데이트를 안내한다.

### D. 인쇄 출력 형식 (`/k8s-troubleshoot` 출장 분기 전용)

종이 폼은 **`/k8s-troubleshoot`이 정보 부족으로 출장 결정이 났을 때만** 생성한다. `/k8s-survey`는 종이 폼을 만들지 않는다 — 대화형 인터뷰로 직접 sites/ 파일을 작성한다.

종이 폼 작성 규칙:

1. 순수 마크다운만 사용 (HTML/CSS 변환 없음)
2. 체크박스는 `- [ ]`
3. 명령어는 ` ```bash ` 코드 펜스로 감싸기 (모노스페이스, 오기 방지)
4. 답 쓸 공간은 빈 줄 4~6개 또는 `_____` 길게
5. 상단 메타 헤더: 사이트명 · 작업일 · 작성자 · 연락처
6. 하단 안내: "복귀 후 Claude와 대화로 결과 알려주세요"
7. A4 1~2장 분량으로 제한 (의심 가설 3개 이내)

### E. `/k8s-survey` 대화형 인터뷰 규칙

`/k8s-survey`는 항상 대화형이다:

1. **한 번에 2-3개씩만 질문** — 한꺼번에 10개는 사용자를 압도
2. **사용자가 "모르겠다"고 하면 `(TODO: 추후 보완)`으로 표시** — 강요하지 않음
3. **신규 모드**: 6단계(기본/클러스터/네트워크/스토리지/배포스타일/내부스택) 순차 인터뷰
4. **갱신 모드**: 무엇이 바뀌었는지 먼저 묻고, 해당 영역만 질문
5. **인터뷰 답을 그대로 옮기지 말고 마크다운으로 정리해서 sites/ 파일 본문에 채움**
6. **"있는 것만 기록한다"** — 07-stack.md에서 사용 안 하는 카테고리는 섹션 자체를 빼거나 한 줄로 "해당 없음"
7. **파일 생성·갱신은 사용자 yes 답변 후에만**

### F. 사용자 페르소나

- 한국어 K8s 운영 엔지니어
- 초급~시니어 혼재
- 시간이 귀하다 — 장황한 설명보다 결정 가능한 정보를 빠르게
- K8s 표준 CLI는 다 알지만, 모든 사이트의 모든 컴포넌트 디테일을 외울 수는 없음

답변은 한국어 기본. 명령어·파일명·K8s 식별자는 원문 그대로.

## 안 하는 것 (v1 명시적 out-of-scope)

- `/k8s-find-sites`, `/k8s-site-verify`, `/k8s-stack-add` 등 다른 명령어 자동 호출 금지
- runbook 자동 로딩 금지 (v1엔 runbook 디렉토리 없음)
- PDF / CSS / QR 코드 생성 금지
- 사이트 데이터 자동 백업/푸시 금지

## 참고

- 설계 문서: `/Users/yunhunbin/.gstack/projects/k8s-hb/yunhunbin-main-design-20260514-121114.md`
- 테스트 plan: `/Users/yunhunbin/.gstack/projects/k8s-hb/yunhunbin-main-eng-review-test-plan-20260514-121114.md`
