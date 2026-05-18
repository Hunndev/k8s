---
customer: "고객사명-여기에-입력"
risk_level: "medium"
last_updated: "2026-01-01"
contract: "maintenance"
cni: "cilium"
cluster_version: "v1.30.0"
deployment_method: "argocd"
airgapped: true
---

# [고객사명] K8s 환경 — 한눈에 보기

## 한 줄 요약

> (예: Air-gapped 환경의 kubeadm 클러스터 3 master + 5 worker. Cilium eBPF, CloudNativePG, Harbor, Loki 스택. ArgoCD GitOps 기반 배포.)

## 핵심 정보

| 항목 | 값 |
|---|---|
| K8s 버전 | (예: v1.30.4) |
| 배포판 | (예: kubeadm / kubespray / OpenShift) |
| Air-gapped | 예 |
| 노드 수 | 총 ___ (Master ___ / Worker ___ / GPU ___) |
| CNI | (예: Cilium eBPF) |
| CSI | (예: Dell Unity XT CSI) |
| 배포 도구 | (예: ArgoCD + Helm) |
| 비밀값 관리 | (예: Sealed Secrets) |
| 모니터링 | (예: kube-prometheus-stack + Loki) |

## 긴급 시 우선 확인

- (이 사이트만의 주의사항. 예: "Harbor 장애 시 신규 Pod 모두 영향 — 이미지 pull 불가")
- (예: "etcd가 stacked 구성 — master 노드 장애 = etcd 영향")
- 

## 연락처

- 1차: ___________________ / ____________________
- 2차: ___________________ / ____________________
- 긴급: ___________________

## 자주 발생하는 이슈 TOP 3

1. (이 사이트에서 반복되는 이슈, 없으면 비워둠)
2. 
3. 

## 사이트 출입·작업 절차 메모

- 출입 신청 리드타임: (예: 3일 전)
- 작업 가능 시간: (예: 평일 09-18시)
- 노트북 반입: 가능 / 불가
- 망 구성: air-gapped (확정)

## 상세 정보 위치

- 배포 스타일: `06-deployment-style.md`
- 내부 스택: `07-stack.md`
- 알려진 이슈: `13-known-issues.md`
- 작업 이력: `14-history.md`
