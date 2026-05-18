# sample-customer

**시연·검증용 가상 사이트. 실제 데이터 아님.**

가상의 회사 "데모코퍼레이션"(주식회사 데모, 가공의 이커머스 결제 플랫폼 운영사)을 모델로 작성. 다음 두 가지 용도:

1. **/k8s-survey** / **/k8s-troubleshoot** dry-run 시연
2. site-validate.sh 통과 여부 확인

## 가상 구성 요약

- K8s v1.30.4, kubeadm, 3 master + 5 worker
- air-gapped
- CNI: Cilium v1.16 eBPF
- 배포: ArgoCD + Helm
- 비밀값: sealed-secrets
- 레지스트리: Harbor (harbor.internal)
- DB: CloudNativePG (PostgreSQL operator)
- 관측성: kube-prometheus-stack + Loki

## 알려진 가상 이슈 (시연용)

- 2026-03-15: payment-api ImagePullBackOff — Harbor regcred secret 만료
- 2026-02-02: payment-api 간헐 crash — CNPG connection pool 고갈

`/k8s-troubleshoot sample-customer`로 위 이슈와 유사한 이메일을 paste하면 13-known-issues.md를 참조하는 추론을 볼 수 있다.
