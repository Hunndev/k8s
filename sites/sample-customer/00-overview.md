---
customer: "데모코퍼레이션 (가상)"
risk_level: "medium"
last_updated: "2026-05-14"
contract: "maintenance"
cni: "cilium"
cluster_version: "v1.30.4"
deployment_method: "argocd"
airgapped: true
---

# 데모코퍼레이션 K8s 환경 — 한눈에 보기

> ⚠️ 시연·검증용 가상 사이트입니다. 실제 데이터 아님.

## 한 줄 요약

> Air-gapped 환경의 kubeadm 클러스터 3 master + 5 worker. Cilium eBPF + CloudNativePG + Harbor + Loki 스택. ArgoCD GitOps 기반 배포.

## 핵심 정보

| 항목 | 값 |
|---|---|
| K8s 버전 | v1.30.4 |
| 배포판 | kubeadm |
| Air-gapped | 예 |
| 노드 수 | 총 8 (Master 3 / Worker 5) |
| CNI | Cilium v1.16 (eBPF, kube-proxy replacement) |
| CSI | Dell Unity XT CSI v2.x |
| 배포 도구 | ArgoCD + Helm |
| 비밀값 관리 | Sealed Secrets |
| 모니터링 | kube-prometheus-stack + Loki |

## 긴급 시 우선 확인

- **Harbor 장애 시 신규 Pod 모두 영향** (이미지 pull 불가, harbor.internal)
- **etcd가 stacked 구성** — master 노드 장애 = etcd 영향
- ArgoCD가 cert-manager 인증서 사용 → cert-manager 장애 시 ArgoCD UI 영향

## 연락처

- 1차: 김운영 / 010-0000-0001
- 2차: 이백엔드 / 010-0000-0002
- 긴급: 010-0000-9999 (24시간 핫라인)

## 자주 발생하는 이슈 TOP 3

1. payment-api ImagePullBackOff (regcred secret 만료, 2026-03-15 발생)
2. payment-api 간헐 crash (CNPG connection pool 고갈, 2026-02-02 발생)
3. ingress-nginx 인증서 갱신 시 일시 503 (cert-manager renewal race)

## 사이트 출입·작업 절차 메모

- 출입 신청 리드타임: 3 영업일 전
- 작업 가능 시간: 평일 09-18시 (주말·야간 사전 협의)
- 노트북 반입: 불가 (USB도 사전 신청)
- 망 구성: 완전 air-gapped (인터넷·외부 레지스트리 모두 차단)

## 상세 정보 위치

- 배포 스타일: `06-deployment-style.md`
- 내부 스택: `07-stack.md`
- 알려진 이슈: `13-known-issues.md`
- 작업 이력: `14-history.md`
