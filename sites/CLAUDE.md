# sites/ — 사이트 데이터 작성 규칙

K8s 고객사별 운영 정보의 마크다운 카탈로그. `/k8s-survey`가 작성·갱신, `/k8s-troubleshoot`가 읽는다. 실제 운영 데이터는 `$K8S_HB_SITES_PATH`에 분리 저장하며, 이 디렉토리엔 시연용 `sample-customer`와 `_TEMPLATE/`, `SCHEMA.md`만 둔다.

## 파일 구성 (사이트당 6개)

```
<customer>/
├── 00-overview.md           # 한눈에 보기 (가장 먼저 로드)
├── 06-deployment-style.md   # Helm/ArgoCD/Flux/비밀값 관리
├── 07-stack.md              # 설치 컴포넌트 카탈로그
├── 13-known-issues.md       # 이슈 누적
├── 14-history.md            # 작업 이력
└── README.md                # 이 사이트 안내
```

## 작성 원칙

- **frontmatter는 `SCHEMA.md`를 따른다** — 알 수 없는 키나 허용값 외 값 사용 금지
- **"있는 것만 기록"** — `07-stack.md`에서 사용 안 하는 카테고리는 섹션 자체를 제거하거나 한 줄로 "해당 없음". 빈 슬롯 나열 금지
- **인터뷰 답을 그대로 옮기지 말고 마크다운으로 정리** — 예: "Helm이랑 ArgoCD 섞어서 써요, 인프라는 Helm, 앱은 ArgoCD" → "메인 방식: ArgoCD(앱) + Helm 직접(인프라)" 식으로 구조화
- **모르면 `(TODO: 추후 보완)`** — 사용자에게 강요 금지
- **파일 생성·수정은 사용자 yes 후에만** — `/k8s-survey` 신규 생성, `/k8s-troubleshoot`의 14-history 1줄 추가, 모순 발견 후 갱신 모두 동일

## 14-history.md 한 줄 양식

```
| 2026-05-14 09:30 | <작성자> | <증상 한 줄> | <원인·해결 한 줄> | <레퍼런스> |
```

- `/k8s-survey` 등록·갱신 작업 자체도 한 줄 추가 (예: "사이트 정보 갱신 (07-stack 추가: External DNS) | k8s-hb /k8s-survey")
- `/k8s-troubleshoot` 해결 후에도 한 줄 추가 권장

## 13-known-issues.md 한 건 항목

발생 날짜 · 증상(짧게) · 원인 · 워크어라운드 · 영구 해결 여부(또는 진행 중).

## 갱신 모드 시

`/k8s-survey <customer>`가 기존 사이트면 "무엇이 바뀌었는지" 먼저 묻고 해당 영역만 갱신. 전체 재인터뷰 금지.
