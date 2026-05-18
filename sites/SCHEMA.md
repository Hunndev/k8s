# sites/ frontmatter 스키마

이 문서는 `sites/<customer>/` 안의 모든 마크다운 파일이 따라야 하는 YAML frontmatter 키·타입·허용값의 **단일 진실 원천**이다.

`scripts/site-validate.sh`는 이 파일을 기준으로 검증한다.

새 키를 추가하거나 허용값을 바꿀 때는 이 파일을 먼저 수정하고, `_TEMPLATE/` 해당 파일도 같이 갱신해야 한다.

---

## 00-overview.md frontmatter

| 키 | 타입 | 필수 | 허용값 / 형식 | 예시 |
|---|---|---|---|---|
| `customer` | string | yes | 자유 (한글/영문) | `"고객-A"` |
| `risk_level` | enum | yes | `low` / `medium` / `high` / `critical` | `medium` |
| `last_updated` | date | yes | `YYYY-MM-DD` | `2026-05-14` |
| `contract` | enum | no | `maintenance` / `consulting` / `construction` / `other` | `maintenance` |
| `cni` | enum | no | `cilium` / `calico` / `flannel` / `weave` / `canal` / `other` | `cilium` |
| `cluster_version` | string | yes | `v?\d+\.\d+(\.\d+)?` | `v1.30.4` |
| `deployment_method` | enum | yes | `helm` / `argocd` / `flux` / `kustomize` / `raw` / `mixed` | `argocd` |
| `airgapped` | bool | yes | `true` / `false` | `true` |

## 06-deployment-style.md frontmatter

| 키 | 타입 | 필수 | 허용값 / 형식 | 예시 |
|---|---|---|---|---|
| `deployment_method` | enum | yes | `helm` / `argocd` / `flux` / `kustomize` / `raw` / `mixed` | `argocd` |
| `gitops_enabled` | bool | yes | `true` / `false` | `true` |
| `config_repo` | string | no | URL 또는 빈 문자열 | `"git@gitlab.internal:ops/k8s-config.git"` |
| `secret_management` | enum | yes | `sealed-secrets` / `external-secrets` / `vault` / `sops` / `plain` / `mixed` | `sealed-secrets` |

## 07-stack.md frontmatter

| 키 | 타입 | 필수 | 허용값 / 형식 | 예시 |
|---|---|---|---|---|
| `stack_summary` | string | yes | 자유 (주요 컴포넌트 + 구분자) | `"Cilium + CNPG + Harbor + Loki"` |

## 13-known-issues.md frontmatter

| 키 | 타입 | 필수 | 허용값 / 형식 | 예시 |
|---|---|---|---|---|
| `issue_count` | int | no | 0 이상 정수 | `2` |

(본문은 timestamp별 누적이라 frontmatter 최소화)

## 14-history.md frontmatter

| 키 | 타입 | 필수 | 허용값 / 형식 | 예시 |
|---|---|---|---|---|
| `last_entry` | date | no | `YYYY-MM-DD` | `2026-05-14` |

## README.md frontmatter

이 파일은 frontmatter를 가지지 않는다. 검증 대상에서 제외.

---

## 공통 검증 규칙

1. **알 수 없는 키**는 경고 (오타 가능성). 검증 실패.
2. **허용값 외 값**은 즉시 실패. 예: `deployment_method: hellm` (오타) → 거부.
3. **필수 키 누락**은 즉시 실패.
4. **빈 문자열**은 enum/date/int 타입에서 거부, string 타입에서만 허용.
5. **date** 형식 위반 (예: `2026/05/14`)은 거부.
6. **bool**은 YAML 표준 `true`/`false`만 허용. `yes`/`no`는 거부.

## 변경 이력

| 버전 | 날짜 | 변경 |
|---|---|---|
| 0.1.0 | 2026-05-14 | 최초 작성 (Phase 1 v1) |
