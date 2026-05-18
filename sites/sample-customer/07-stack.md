---
stack_summary: "Cilium + CNPG + Harbor + kube-prometheus + Loki + Sealed Secrets"
---

# 내부 스택 — 데모코퍼레이션 (가상)

## 네트워크 (CNI)

- **CNI**: Cilium v1.16.2
- **모드**: eBPF, kube-proxy replacement
- **L7 정책 사용**: 예 (HTTP 메서드 기반 namespace 격리)
- **Hubble 활성화**: 예 (hubble-relay + UI: hubble.internal)
- **추가 CNI**: 없음
- **알려진 제약**: kernel 5.10+ 필요 (모든 노드 RHEL 9.4 충족)

## Ingress / Gateway

- **Ingress Controller**: ingress-nginx v1.11.0
- **Gateway API 사용 여부**: 아니오
- **인증서 관리**: cert-manager v1.15 + 사내 CA (Let's Encrypt 사용 불가, air-gapped)
- **WAF**: 미사용

## Service Mesh

해당 없음.

## 데이터베이스 Operator

- **PostgreSQL**: CloudNativePG v1.24
  - 운영 클러스터: `payment-db` (3 replica), `analytics-db` (1 replica)
  - 백업 위치: 내부 MinIO (s3.internal/cnpg-backups)
  - PITR: 활성화 (7일 보존)

## 메시징 / 큐

해당 없음. (시연 사이트 simplification)

## 캐시

해당 없음.

## 레지스트리

- **Harbor**: v2.10.2
- **위치**: harbor.internal
- **고가용성**: 예 (replica 2)
- **이미지 스캔**: Trivy (자동)
- **프로젝트 / 접근권한**: payment, analytics, infra — 각각 별도 robot account

## 관측성 (Observability)

### 메트릭
- **kube-prometheus-stack**: v58.0.0
- **Prometheus 보존**: 30일 (PVC 200Gi)
- **원격 저장**: 미사용 (air-gapped 환경 단일 cluster)
- **알림 채널**: Slack #ops-alert (Alertmanager → webhook proxy)

### 로깅
- **Loki**: v3.0 (single binary 모드)
- **로그 수집기**: Grafana Alloy DaemonSet
- **저장 백엔드**: 내부 MinIO
- **보존 정책**: 14일

### 트레이싱
- 미사용.

### 대시보드
- **Grafana**: v11.0
- **주요 대시보드**: K8s Cluster Overview, CNPG, Cilium Hubble, Harbor

## 백업

- **etcd**: kubeadm 기반 스크립트 (`/etc/cron.d/etcd-backup`), 매일 02:00, 보관 GFS (일 7일 + 주 4주)
- **Velero**: 미사용

## 보안

- **PSA 레벨**: baseline 기본, 일부 namespace는 restricted
- **NetworkPolicy**: Cilium L3/L4 + L7 일부 (payment ↔ analytics 격리)
- **Falco**: 미사용
- **OPA Gatekeeper / Kyverno**: Kyverno v1.12 (이미지 출처 정책, replica 최소값)
- **이미지 서명**: cosign + Kyverno 검증 (Harbor 내부 이미지만 허용)

## 스토리지

- **CSI**: Dell Unity XT CSI v2.x
- **로컬 스토리지**: local-path-provisioner (테스트용 namespace만)
- **스냅샷**: VolumeSnapshotClass 정의됨 (Velero 미사용으로 활용도 낮음)

## GPU / 특수 워크로드

해당 없음.

## 기타 Operator / Controller

- **External DNS**: 사용 안 함 (사내 DNS 수동 관리)
- **Reloader**: 사용 (ConfigMap/Secret 변경 시 자동 Pod 재시작)
- **Descheduler**: 미사용

## 컴포넌트 간 의존성 메모

- **ArgoCD ← cert-manager 인증서**: cert-manager 장애 시 ArgoCD UI 영향 (kubectl로는 동작)
- **모든 Pod ← Harbor 이미지**: Harbor 장애 시 신규 Pod 시작 불가, 기존 Pod 영향 없음
- **payment-api ← CNPG payment-db**: DB 장애 시 즉시 readiness 실패
- **모든 Helm Release ← Sealed Secrets controller**: controller 장애 시 신규 secret 복호화 불가, 기존 secret은 정상

## 알려진 호환성 이슈

- Cilium 1.16과 Kyverno 1.12 충돌 보고된 이슈는 없음 (모니터링 중)
- CNPG operator 업그레이드 시 PG major version 자동 업그레이드 비활성 (수동 절차)
