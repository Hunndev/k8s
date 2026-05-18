# k8s-hb — K8s 기술지원 플러그인

air-gapped 고객사 K8s 클러스터 운영팀을 위한 Claude Code 플러그인. 이메일로 받은 장애 의뢰를 사이트 컨텍스트(sites/)와 결합해 빠르게 분석하고, 출장이 필요하면 그 사이트에 맞는 종이 체크리스트를 출력한다.

## 두 가지 명령어

| 명령어 | 용도 | 동작 |
|---|---|---|
| `/k8s-survey [customer]` | 신규 사이트 등록 또는 기존 사이트 정보 갱신 | Claude가 항목별로 질문 → 답을 받아 `sites/<customer>/` 6개 파일을 직접 작성/갱신 |
| `/k8s-troubleshoot <customer>` | 이메일로 받은 의뢰 분석 | (a) 회신 초안 또는 (b) 출장 브리핑 + 종이 체크리스트 |

**종이 폼은 `/k8s-troubleshoot`의 출장 분기에서만 나온다.** `/k8s-survey`는 사무실에서 사용자가 알고 있는 정보를 대화로 정리하는 흐름이라 종이가 필요 없다.

## 설치

### 1) 플러그인 위치

`~/.claude/plugins/k8s-hb/`에 설치되어 있어야 Claude Code가 슬래시 명령어로 인식합니다. 구조:

```
~/.claude/plugins/k8s-hb/
├── .claude-plugin/plugin.json   ← Claude Code 매니페스트
├── commands/                    ← /k8s-survey, /k8s-troubleshoot
├── sites/                       ← 시연용 sample-customer만 포함. 실제 사이트는 K8S_HB_SITES_PATH 별도 경로 권장
├── scripts/                     ← site-validate.sh
├── tests/                       ← bats 자동 검사
├── README.md                    ← 이 파일
└── CLAUDE.md                    ← Claude 동작 규칙
```

### 2) `K8S_HB_SITES_PATH` 환경변수 설정 (필수)

사이트 데이터는 별도 디렉토리(또는 별도 Git 저장소)에 둔다:

```bash
# 옵션 A: 내부 Git 저장소를 클론
git clone <k8s-hb-sites-repo-url> ~/k8s-hb-sites
export K8S_HB_SITES_PATH=~/k8s-hb-sites

# 옵션 B: 플러그인 내장 sites/를 사용 (개발·시연용만 권장)
export K8S_HB_SITES_PATH=~/.claude/plugins/k8s-hb/sites
```

쉘 시작 파일(`.zshrc`/`.bashrc`)에 추가해두면 매번 설정할 필요 없음.

**미설정 시 두 명령어 모두 fail-loud로 종료**한다. 명시적 설정을 강제하여 사이트 데이터의 위치를 사용자가 항상 알게 함.

### 3) (선택) 자동 검증 도구

`scripts/site-validate.sh`는 `bats-core`로 테스트한다:

```bash
brew install bats-core           # macOS
# 또는
npm install -g bats              # Node 환경
```

설치 후:

```bash
cd ~/.claude/plugins/k8s-hb
bats tests/site-validate.bats
```

### 4) Claude Code에 plugin 인식 확인

설치 후 Claude Code를 재시작하거나 `/help` 등으로 `/k8s-survey`, `/k8s-troubleshoot` 슬래시 명령어가 노출되는지 확인합니다.

## 사이트 추가 흐름

```
# Claude Code에서 호출
/k8s-survey customer-a

# Claude가 차근차근 질문 시작:
#   "고객사 이름은? 위험도는? 계약 형태는?"
#   "K8s 배포판은? 노드 수는?"
#   "CNI는? 모드는?"
#   ... (6영역 인터뷰, 한 번에 2-3개씩)
#
# 사용자는 알고 있는 만큼만 답함. 모르면 "추후 보완"으로 표시됨.
#
# 인터뷰 완료 후 Claude가:
#   1. 생성 계획 요약 출력
#   2. 사용자 yes 답변 후
#   3. sites/customer-a/ 6개 파일 자동 생성

# 검증
bash scripts/site-validate.sh $K8S_HB_SITES_PATH/customer-a
```

`_TEMPLATE/`를 수동으로 복사할 필요는 없다 — `/k8s-survey`가 인터뷰 답을 마크다운으로 정리해 직접 작성한다.

## 의뢰 분석 흐름

```bash
# Claude Code: /k8s-troubleshoot customer-a
# 사용자: (이메일 내용 paste)
# Claude:
#   - 구조적 추론 (K8s 일반 패턴 + 사이트 특화)
#   - (a) 해결 가능: 회신 초안 출력
#   - (b) 정보 부족: 출장 전 브리핑 + 1~2장 짜리 종이 체크리스트
```

## 사이트 디렉토리 구조

`$K8S_HB_SITES_PATH/<customer>/` 안에 6개 파일:

```
00-overview.md           # 한눈에 보기 (Claude가 가장 먼저 읽음)
06-deployment-style.md   # Helm / ArgoCD / Flux / 비밀값 관리
07-stack.md              # 설치된 컴포넌트 카탈로그 (있는 것만)
13-known-issues.md       # 알려진 이슈 누적
14-history.md            # 작업 이력
README.md                # 이 사이트 안내
```

각 파일의 frontmatter 스키마는 `$K8S_HB_SITES_PATH/SCHEMA.md` 참조.

## 검증

```bash
# 특정 사이트 디렉토리 검증
bash scripts/site-validate.sh $K8S_HB_SITES_PATH/customer-a

# 시연용 sample-customer로 dry-run
/k8s-survey sample-customer
/k8s-troubleshoot sample-customer
```

## 디자인 결정 배경

- **모든 사이트 air-gapped 전제** — Claude는 항상 사무실에 있고, 클러스터 정보는 이메일 또는 종이로만 전달됨
- **명령어 2개만 v1** — 더 많은 자동화는 사이트 1~2곳 운영해본 뒤 v2에서
- **마크다운 인쇄 only** — CSS/PDF 변환 없이 브라우저 `Cmd+P`로 충분
- **사이트 데이터 분리** — plugin code 업데이트가 고객 정보에 영향 없도록 별도 경로

자세한 설계 배경: 내부 문서(office-hours + plan-eng-review 산출물) 참조.

## 라이선스

Proprietary. 내부 사용 한정.
