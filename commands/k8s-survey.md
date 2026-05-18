---
description: K8s 사이트 등록/갱신 대화형 인터뷰. Claude가 항목별로 묻고 sites/<customer>/ 6개 파일을 직접 작성·갱신한다. 종이 폼은 출력하지 않음.
argument-hint: "[customer] (생략 시 첫 질문이 '고객사 이름은?')"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# /k8s-survey

K8s 기술지원 엔지니어가 운영 중인 air-gapped 고객사 사이트의 정보를 sites/<customer>/ 6개 마크다운 파일로 정리하는 도구. **Claude가 사용자에게 항목별로 질문하고 답을 받아 파일을 직접 작성한다.** 사용자가 이미 알고 있는 정보(사무실에서 머릿속에 있는 정보)를 마크다운으로 옮기는 흐름이라 종이 폼이 필요 없다.

종이 폼이 필요한 경우는 `/k8s-troubleshoot`의 출장 분기에서만 나온다.

## 호출 형식

```
/k8s-survey [<customer>]
```

- `<customer>` 없으면 → 인터뷰 첫 질문이 "고객사 이름은 무엇인가요?"
- `<customer>` 있고 `sites/<customer>/` 없으면 → **신규 모드** (전체 인터뷰)
- `<customer>` 있고 `sites/<customer>/` 있으면 → **갱신 모드** (변경분만 인터뷰)

## 진입 절차 (반드시 이 순서)

### 1) sites_path 해석

CLAUDE.md "sites_path 해석 규칙"을 따른다 (env → CLAUDE.md → fail-loud).

### 2) 모드 결정

- `<customer>` 인자가 주어졌고 `$sites_path/<customer>/`이 존재 → **갱신 모드**
- 그 외 → **신규 모드**

### 3) 갱신 모드일 때 기존 컨텍스트 로드

```
sites/<customer>/00-overview.md   (전체)
sites/<customer>/06-deployment-style.md   (전체)
sites/<customer>/07-stack.md   (전체)
sites/<customer>/13-known-issues.md   (있으면)
sites/<customer>/14-history.md   (마지막 5건)
```

---

## 신규 모드 — 대화형 인터뷰 절차

사용자에게 다음 6단계로 **순차적으로** 질문한다. 한 단계가 끝나면 다음 단계 안내 후 사용자 답변을 기다린다.

### Stage 1: 기본 정보 (00-overview.md용)

다음 항목을 한 번에 한두 개씩만 묻는다. 사용자가 "모르겠다"고 하면 "추후 보완"으로 표시.

질문 흐름 예시:

> "사이트 등록을 시작하겠습니다. 기본 정보부터 차근차근 묻겠습니다.
>
> 1) 고객사 이름은 무엇인가요? (예: '데모코퍼레이션', 'KB-payments')
> 2) 위험도는? `low` / `medium` / `high` / `critical` 중에서 선택해주세요. (보통은 medium)"

사용자 답변 후:

> "다음으로:
>
> 3) 계약 형태는? `maintenance` / `consulting` / `construction` / `other`
> 4) 주 담당자 이름과 연락처는?"

이런 식으로 **2~3개씩 묶어서** 묻는다. 6영역 인터뷰 동안 너무 자주 끊기지 않게.

Stage 1에서 받아야 할 정보:
- `customer` (frontmatter)
- `risk_level` (frontmatter)
- `contract` (frontmatter, optional)
- `cluster_version` (예: v1.30.4)
- `airgapped` (boolean, 기본 true)
- 주/부/긴급 연락처
- 출입 신청 리드타임, 작업 가능 시간, 노트북 반입 가능 여부

### Stage 2: 클러스터 기본

> "이제 클러스터 구성을 묻겠습니다.
>
> 1) K8s 배포판은? (kubeadm / kubespray / OpenShift / Rancher / 기타)
> 2) 노드 수는 총 몇 개? Master/Worker/GPU/Storage로 나눠 알려주세요.
> 3) OS와 kernel 버전은? (예: RHEL 9.4, kernel 5.14)
> 4) 컨테이너 런타임은? (containerd / cri-o / docker)"

### Stage 3: 네트워크 (CNI)

> "네트워크 쪽입니다.
>
> 1) CNI는? (Cilium / Calico / Flannel / Weave / Canal / 기타) — 이건 `00-overview.md` frontmatter에도 들어갑니다.
> 2) 모드는? (eBPF / iptables / IPVS)
> 3) Multus 같은 추가 CNI 사용하나요?
> 4) Pod CIDR / Service CIDR는?"

### Stage 4: 스토리지

> "스토리지 구성입니다.
>
> 1) 주요 StorageClass 이름과 provisioner는? (기억나는 것만, 1-3개)
> 2) CSI 드라이버 이름과 버전은? (예: Dell Unity XT CSI v2.x)"

### Stage 5: 배포 스타일 ★ (06-deployment-style.md용)

이게 가장 중요한 영역. 좀 더 자세히 묻는다.

> "이 사이트에서 가장 중요한 영역인 **배포 스타일**입니다.
>
> 1) 주 배포 도구는? Helm 직접 / ArgoCD / Flux / Kustomize / raw kubectl 중 선택. 여러 개 섞여 있다면 알려주세요.
> 2) GitOps 사용하시나요? 한다면 Git 저장소 URL은?
> 3) 비밀값 관리는? sealed-secrets / external-secrets / vault / sops / plain
> 4) values 파일은 어디에 있나요? 환경별로 어떻게 분리하나요?"

배포 도구별 추가 질문 (해당하는 것만):

**Helm 사용 시**:
> "Helm 관련 디테일:
> - 차트 저장소 위치 (예: Harbor 내 chartrepo)?
> - 차트 버전 핀 정책 (latest 금지 / 명시적)?
> - 업그레이드 절차 (CI/CD 자동 / 수동 helm upgrade)?
> - 주요 Release 3-5개만 알려주세요 (이름·namespace·chart 정도)."

**ArgoCD 사용 시**:
> "ArgoCD 관련:
> - 버전 / 설치 namespace / UI URL?
> - 인증 방식 (Dex+LDAP / OIDC / local)?
> - Application 구조 (App of Apps / ApplicationSet)?
> - sync 정책 (auto / manual)?
> - 주요 Application 3-5개?"

**Flux 사용 시**: 유사한 디테일

### Stage 6: 내부 스택 (07-stack.md용)

> "마지막 영역, 설치된 컴포넌트 카탈로그입니다. **있는 것만** 알려주세요. 카테고리별로 묻겠습니다.
>
> 1) Ingress Controller — 사용 중이라면 무엇? (예: ingress-nginx 1.11)
> 2) cert-manager — 사용 중이라면 버전?
> 3) Service Mesh — Istio / Linkerd / 사용 안 함?
> 4) DB Operator — PostgreSQL (CNPG, Stackgres), MySQL, MongoDB 중 사용 중인 것?
> 5) 레지스트리 — Harbor / Nexus / Quay / 클라우드?
> 6) 관측성 — Prometheus stack, Loki, Grafana 등?
> 7) 백업 — Velero / etcd 백업 스크립트 / 기타?
> 8) 보안 정책 엔진 — Kyverno / Gatekeeper / 사용 안 함?
> 9) GPU / 특수 워크로드 — 있나요?
> 10) 기타 중요한 Operator (External DNS, Reloader 등)?
>
> 사용하지 않는 카테고리는 그냥 '해당 없음'이라고 답해주시면 됩니다."

이어서 의존성 메모 질문:

> "이 사이트에서 **장애 시 연쇄 영향**이 있는 컴포넌트 관계가 있나요?
> 예: 'Harbor 장애 시 신규 Pod 모두 영향', 'ArgoCD가 cert-manager 인증서 사용' 같은 것들.
> 진단 시 참고할 가치 있는 것 1-3개 정도."

### Stage 7: 자주 발생하는 이슈

> "이 사이트에서 반복적으로 발생하거나 주의해야 할 이슈가 있나요? 모르면 비워둬도 됩니다. 나중에 의뢰가 들어오면 자연스럽게 누적됩니다."

### Stage 8: 사이트 특이사항

> "마지막으로, 이 사이트만의 특이사항이 있나요?
> 예: 'ingress-nginx 재시작 전 외부 LB health check 우회 필요', '주말 작업 불가' 같은 것들."

---

## 인터뷰 종료 후 — 파일 생성

모든 답이 모이면 다음 절차:

### 1) 생성 계획 요약 출력

```
[k8s-hb] 인터뷰 완료. 다음 파일들을 생성할 예정입니다:

sites/<customer>/
├── 00-overview.md          (기본 정보 + 핵심 정보 표 + 연락처 + TOP 3 이슈)
├── 06-deployment-style.md  (배포 도구, GitOps, 비밀값, Helm/ArgoCD 디테일)
├── 07-stack.md             (내부 스택 카탈로그 + 의존성 메모)
├── 13-known-issues.md      (빈 상태 또는 알려준 이슈)
├── 14-history.md           (오늘 등록 한 줄 기록)
└── README.md               (이 사이트 안내)

frontmatter 주요 값:
  customer: "____"
  risk_level: "____"
  cluster_version: "____"
  deployment_method: "____"
  airgapped: ____

생성을 진행할까요? (yes / no / 일부 수정)
```

### 2) 사용자 승인 시

- `sites_path/<customer>/` 디렉토리 생성
- 6개 파일 생성 (각 파일의 frontmatter는 SCHEMA.md를 따른다)
- 인터뷰에서 받은 답을 본문에 자연스럽게 정리해 채움
- "해당 없음" 답한 카테고리는 07-stack.md에서 섹션 자체를 제거 ("있는 것만" 원칙)
- 답하지 않은 항목은 `(TODO: 추후 보완)` 표시

### 3) 완료 안내

```
[k8s-hb] 사이트 '<customer>' 등록 완료.

다음을 확인해주세요:
1. 자동 검증:
   bash $K8S_HB_SITES_PATH/../scripts/site-validate.sh $K8S_HB_SITES_PATH/<customer>

2. 생성된 파일 검토:
   ls $K8S_HB_SITES_PATH/<customer>/

다음 단계:
- 의뢰가 들어오면 /k8s-troubleshoot <customer>로 분석
- 정보가 변경되면 /k8s-survey <customer>로 갱신 (변경분만 묻습니다)
```

---

## 갱신 모드 — 변경분만 인터뷰

기존 사이트의 정보를 갱신할 때. 한 번에 다 묻지 말고 **무엇이 바뀌었는지** 사용자에게 먼저 묻는다.

### 진입 메시지

```
[k8s-hb] 사이트 '<customer>' 갱신 모드.

현재 기록:
  - K8s: <cluster_version>
  - 배포: <deployment_method> (<gitops_enabled>)
  - 스택: <stack_summary>
  - 마지막 갱신: <last_updated>
  - 13-known-issues 건수: <issue_count>
  - 14-history 마지막 작업: <last_entry>

어느 영역을 갱신하시겠어요? (여러 개 선택 가능)
  (a) 기본 정보 / 클러스터 / 노드 (00-overview)
  (b) 배포 스타일 변경 (Helm/ArgoCD 디테일, 새 Release 등) (06)
  (c) 내부 스택 변경 (컴포넌트 추가/제거) (07)
  (d) 알려진 이슈 추가 (13)
  (e) 작업 이력 한 줄 추가 (14)
  (f) 전체 점검 — 모든 영역 한 번씩 확인
```

### 영역별 갱신 흐름

선택된 영역(들)에 대해서만 질문. 신규 모드의 해당 Stage 질문을 재사용하되, "기존 값은 X인데, 그대로인가요? 아니면 무엇으로 바뀌었나요?" 형태로 물음.

예시:
> "기존 cluster_version은 'v1.30.4'입니다. 변경 없으신가요? 변경되었다면 새 값을 알려주세요."

> "13-known-issues.md에 추가할 이슈가 있다고 하셨네요. 한 건씩 알려주세요:
> - 발생 날짜?
> - 증상 (짧게)?
> - 원인?
> - 워크어라운드?
> - 영구 해결 (또는 진행 중)?"

### 종료 후 처리

신규 모드와 동일 — 변경안 요약 → 사용자 승인 → 해당 파일들만 수정 → 완료 안내.

**14-history.md에 한 줄 추가 (자동 제안)**: 갱신 작업 자체도 이력에 기록.

```
| 2026-05-14 14:00 | <user> | 사이트 정보 갱신 (07-stack 추가: External DNS) | sites/<customer>/14-history.md | k8s-hb /k8s-survey |
```

---

## Notes for Claude

- **항상 한 번에 2-3개씩만 묻는다.** 한꺼번에 10개 질문은 사용자를 압도한다.
- **사용자가 "모르겠다"고 하면 `(TODO: 추후 보완)`으로 표시** — 강요하지 않음.
- **frontmatter는 반드시 SCHEMA.md를 따른다.** 알 수 없는 키나 허용값 외 값을 쓰지 않는다.
- **"있는 것만 기록한다" 원칙** — 07-stack.md에서 사용하지 않는 카테고리는 섹션 자체를 빼거나 한 줄로 "해당 없음" 명시.
- **사용자 답을 그대로 옮겨 적기보다 마크다운으로 정리해 넣는다.** 예: "Helm 직접이랑 ArgoCD 섞어서 써요. 인프라는 Helm, 앱은 ArgoCD"라는 답 → 06-deployment-style.md의 "1. 주요 배포 도구" 섹션에 "메인 방식: ArgoCD (앱) + Helm 직접 (인프라). 부차 방식: ..." 식으로 구조화.
- **파일 생성 전 반드시 사용자 승인.** CLAUDE.md "사이트 데이터 자동 수정 권한" 규칙 준수.
- **`14-history.md`에 등록/갱신 이력 한 줄 자동 추가** — 사용자 승인 후.
- **출력은 한국어. 명령어·파일명·K8s 식별자는 원문 그대로.**
- **종이 폼 출력 절대 금지.** 종이가 필요한 흐름은 `/k8s-troubleshoot`의 출장 분기에서만.

## 호출 예시

```
/k8s-survey                          → 신규 모드, 첫 질문이 사이트 이름
/k8s-survey customer-new             → 신규 모드 (sites/에 없는 이름)
/k8s-survey sample-customer          → 갱신 모드 (sites/에 존재)
```
