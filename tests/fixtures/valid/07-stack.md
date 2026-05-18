---
stack_summary: "변경하세요 — 예: Cilium + CNPG + Harbor + Loki"
---

# 내부 스택 (설치된 컴포넌트 카탈로그)

> **원칙**: 이 사이트에 **실제로 설치되어 운영 중인 컴포넌트만** 기록한다.
> 사용하지 않는 카테고리는 섹션 자체를 삭제하거나 "해당 없음"을 명시.

## 네트워크 (CNI)

- **CNI**: (예: Cilium v1.16.x)
- **모드**: (예: eBPF, kube-proxy replacement)
- **L7 정책 사용**: 예 / 아니오
- **Hubble 활성화**: 예 / 아니오 (UI: ____)
- **추가 CNI**: (예: Multus + VLAN attachment)
- **알려진 제약**: 

## Ingress / Gateway

- **Ingress Controller**: (예: ingress-nginx v1.11.x)
- **Gateway API 사용 여부**: 예 / 아니오
- **인증서 관리**: (예: cert-manager + Let's Encrypt / 사내 CA)
- **WAF**: 

## Service Mesh

- (사용 안 함 / Istio 버전 X / Linkerd 등)

## 데이터베이스 Operator

- **PostgreSQL**: (예: CloudNativePG v1.24)
  - 운영 클러스터:
  - 백업 위치:
  - PITR: 활성화 / 비활성화
- **MySQL / MariaDB**: 
- **MongoDB**: 

## 메시징 / 큐

- (해당 시: Kafka Strimzi, RabbitMQ Cluster Operator 등)

## 캐시

- (Redis Operator 등)

## 레지스트리

- **Harbor / Nexus / Quay**: 
- **위치**: 
- **고가용성**: 
- **이미지 스캔**: (Trivy / Clair / 미사용)
- **프로젝트 / 접근권한**: 

## 관측성 (Observability)

### 메트릭
- **kube-prometheus-stack**: 
- **Prometheus 보존**: 
- **원격 저장**: (Thanos / Mimir / 미사용)
- **알림 채널**: 

### 로깅
- **Loki / EFK / etc**: 
- **로그 수집기**: (Grafana Alloy / Fluent Bit / Fluentd)
- **저장 백엔드**: 
- **보존 정책**: 

### 트레이싱
- (Tempo / Jaeger / 미사용)

### 대시보드
- **Grafana**: 
- **주요 대시보드**: 

## 백업

- **etcd**: (백업 방식, 주기, 보관)
- **Velero**: (버전, 백업 대상 namespace)

## 보안

- **PSA 레벨**: (baseline / restricted / privileged)
- **NetworkPolicy**: 
- **Falco**: 사용 / 미사용
- **OPA Gatekeeper / Kyverno**: 
- **이미지 서명**: (cosign / 미사용)

## 스토리지

- **CSI**: (자세한 것은 별도 메모 또는 외부 문서)
- **로컬 스토리지**: (local-path-provisioner 등)
- **스냅샷**: VolumeSnapshotClass 정의 / 미정의

## GPU / 특수 워크로드

- **NVIDIA GPU Operator**: 
- **MIG**: 사용 / 미사용
- **AI/ML 플랫폼**: (KServe / Kubeflow 등)

## 기타 Operator / Controller

- **External DNS**: 
- **Reloader**: 
- **Descheduler**: 

## 컴포넌트 간 의존성 메모

> 진단 시 참고할 중요한 의존 관계를 적는다.

- (예: ArgoCD가 cert-manager 인증서를 사용 → cert-manager 장애 시 ArgoCD UI 영향)
- (예: 모든 Pod이 Harbor에서 이미지 pull → Harbor 장애 시 신규 Pod 시작 불가)

## 알려진 호환성 이슈

- 
