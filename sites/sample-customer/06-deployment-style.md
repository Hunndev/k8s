---
deployment_method: "argocd"
gitops_enabled: true
config_repo: "git@gitlab.internal:demo-corp/k8s-config.git"
secret_management: "sealed-secrets"
---

# 배포 스타일 — 데모코퍼레이션 (가상)

## 1. 주요 배포 도구

- **메인 방식**: ArgoCD + Helm
- **부차 방식**: 일부 cluster-level 리소스(예: CRD, namespace)는 raw kubectl apply
- **이유/배경**: GitOps 표준화 + 다중 클러스터(prod/stg) 동기화 필요

## 2. Helm 사용 현황

- **Helm 버전**: v3.14
- **차트 저장소**:

  | 저장소 이름 | URL | 인증 |
  |---|---|---|
  | internal-harbor | https://harbor.internal/chartrepo/k8s-charts | basic auth |

- **values 파일 관리 방식**:
  - 위치: `git@gitlab.internal:demo-corp/k8s-config.git` 내 `apps/<release>/values.yaml`
  - 환경별 분리: `values-prod.yaml`, `values-stg.yaml`
  - 비밀값 처리: Sealed Secrets (별도 파일 `secrets.sealed.yaml`)
- **차트 버전 핀 정책**: 모든 release에 명시적 버전. `latest` 사용 금지.
- **업그레이드 절차**: Git 저장소 PR merge → ArgoCD auto-sync

### 배포 중인 Helm Release 목록 (주요 3개)

| Release | Namespace | Chart | Version | Values 위치 | 비고 |
|---|---|---|---|---|---|
| ingress-nginx | ingress-nginx | ingress-nginx/ingress-nginx | 4.10.0 | k8s-config/infra/ingress/values.yaml | |
| cnpg-operator | cnpg-system | cloudnative-pg/cloudnative-pg | 0.22.1 | k8s-config/infra/cnpg/values.yaml | |
| kube-prometheus-stack | monitoring | prometheus-community/kube-prometheus-stack | 58.0.0 | k8s-config/infra/monitoring/values.yaml | 보존 30일 |

## 3. ArgoCD 사용 현황

- **ArgoCD 버전**: v2.12.0
- **설치 namespace**: argocd
- **UI URL**: https://argocd.internal (사내망 only)
- **인증 방식**: Dex + LDAP
- **Application 구조**: App of Apps
- **sync wave 사용**: 예 — infra(0) → platform(1) → apps(2)
- **자동 sync 정책**: auto-sync 활성화 (prune=true, selfHeal=true)
- **prune 정책**: 자동 prune. 단 PVC는 prune 제외 (보호용 annotation)

### 주요 Application 목록

| Application | Source | Destination | Sync 정책 |
|---|---|---|---|
| platform-infra | k8s-config/infra | in-cluster | auto |
| payment-prod | k8s-config/apps/payment/prod | in-cluster | auto |
| analytics-prod | k8s-config/apps/analytics/prod | in-cluster | auto |

## 4. Flux 사용 현황

해당 없음.

## 5. Kustomize 사용 현황

- ArgoCD가 일부 base/overlay 구조 처리. namespace별 라벨 주입에 사용.

## 6. raw YAML 직접 적용

- CRD 설치 시에만 (예: cert-manager CRD)
- Git 추적: `k8s-config/bootstrap/crds/` 디렉토리

## 7. GitOps 저장소 구조

```
gitlab.internal/demo-corp/k8s-config/
├── bootstrap/
│   └── crds/
├── infra/
│   ├── ingress/
│   ├── cnpg/
│   ├── monitoring/
│   └── argocd/
├── platform/
│   └── harbor/
└── apps/
    ├── payment/
    │   ├── prod/
    │   └── stg/
    └── analytics/
        ├── prod/
        └── stg/
```

## 8. CI/CD 파이프라인

- **CI 도구**: GitLab CI (gitlab.internal)
- **배포 트리거**: MR merge → main 브랜치 push → ArgoCD가 1분 내 sync
- **이미지 빌드/푸시**: GitLab CI → Harbor (harbor.internal)
- **이미지 태그 규칙**: `<branch>-<short-sha>` (예: `main-abc1234`)

## 9. 비밀값 관리

- **방식**: Sealed Secrets v0.27
- **마스터 키 보관 위치**: HashiCorp Vault (vault.internal), namespace `sealed-secrets/secret-key`
- **로테이션 정책**: 6개월
- **재해 시 복구 절차**: Vault에서 master key 복원 → controller 재배포 → 기존 SealedSecret 모두 재복호화

## 10. 배포 시 일반적인 절차

1. 개발자가 GitLab MR 생성 (k8s-config repo)
2. 운영팀 리뷰 → MR merge
3. ArgoCD가 약 1분 내 sync 감지
4. ArgoCD UI에서 sync 진행 확인
5. 실패 시 Slack #ops-alert 채널 알림

## 11. 알려진 배포 관련 이슈

- ArgoCD sync 직후 NetworkPolicy 갱신 race로 일시 pod readiness 실패 (재시도로 자동 복구)
- Helm chart 버전 업그레이드 시 CRD 변경은 별도 PR (raw apply)
