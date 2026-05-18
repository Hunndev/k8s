---
deployment_method: "argocd"
gitops_enabled: true
config_repo: ""
secret_management: "sealed-secrets"
---

# 배포 스타일

## 1. 주요 배포 도구

- **메인 방식**: (예: ArgoCD + Helm)
- **부차 방식**: (예: 일부 인프라 컴포넌트는 raw kubectl apply)
- **이유/배경**: (왜 이 방식을 선택했는지)

## 2. Helm 사용 현황 (해당 시)

- **Helm 버전**: 
- **차트 저장소**:

  | 저장소 이름 | URL | 인증 |
  |---|---|---|
  |  |  |  |

- **values 파일 관리 방식**:
  - 위치: (Git 저장소 경로)
  - 환경별 분리: (values-prod.yaml / values-stg.yaml 등)
  - 비밀값 처리: (SOPS / Sealed Secrets / 외부 Vault 참조)
- **차트 버전 핀 정책**: (latest 금지 / 명시적 버전 지정)
- **업그레이드 절차**: (helm upgrade 직접 / ArgoCD sync / CI/CD)

### 배포 중인 Helm Release 목록

| Release | Namespace | Chart | Version | Values 위치 | 비고 |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## 3. ArgoCD 사용 현황 (해당 시)

- **ArgoCD 버전**: 
- **설치 namespace**: argocd
- **UI URL**: 
- **인증 방식**: (Dex / OIDC / local)
- **Application 구조**: (App of Apps / ApplicationSet)
- **sync wave 사용**: (있다면 순서)
- **자동 sync 정책**: (auto-sync / manual)
- **prune 정책**: 

### 주요 Application 목록

| Application | Source | Destination | Sync 정책 |
|---|---|---|---|
|  |  |  |  |

## 4. Flux 사용 현황 (해당 시)

- **Flux 버전**: 
- **GitRepository 정의**: 
- **Kustomization / HelmRelease 개수**: 

## 5. Kustomize 사용 현황 (해당 시)

- **base / overlay 구조**: 
- **환경별 overlay 위치**: 

## 6. raw YAML 직접 적용 (해당 시)

- **언제 사용**: (긴급 패치 등 예외)
- **이력 추적 방식**: 

## 7. GitOps 저장소 구조

```
git@.../k8s-config/
├── clusters/
│   ├── prod/
│   └── stg/
├── apps/
└── infra/
```

## 8. CI/CD 파이프라인

- **CI 도구**: (GitLab CI / GitHub Actions / Jenkins)
- **배포 트리거**: (PR merge / tag / 수동)
- **이미지 빌드 / 푸시 위치**: 
- **이미지 태그 규칙**: (sha / semver / branch-sha)

## 9. 비밀값 관리

- **방식**: (sealed-secrets / external-secrets / vault / sops)
- **마스터 키 보관 위치**: 
- **로테이션 정책**: 
- **재해 시 복구 절차**: 

## 10. 배포 시 일반적인 절차

1. (이 사이트에서 워크로드 변경을 배포할 때 실제로 어떻게 하는가)
2. 
3. 

## 11. 알려진 배포 관련 이슈

- 
