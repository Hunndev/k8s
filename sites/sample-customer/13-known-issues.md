---
issue_count: 2
---

# 알려진 이슈 — 데모코퍼레이션 (가상)

이 사이트에서 발생한 이슈를 누적 기록. `/k8s-troubleshoot` 진단 시 참조.

## 이슈 기록 (최신이 위)

| 날짜 | 증상 | 원인 | 워크어라운드 | 영구 해결 |
|---|---|---|---|---|
| 2026-03-15 | payment-api Pod ImagePullBackOff | Harbor regcred secret 만료 (90일 만료 정책) | 새 secret 생성 후 namespace에 재적용, Pod 재시작 | Harbor robot account 만료 90일 전 Slack 자동 알림 (완료 2026-03-20) |
| 2026-02-02 | payment-api 간헐적 crash (1시간에 2-3회) | CNPG connection pool 고갈 (max=50, 피크 시 동시 60+) | pool max=100 상향, Pod 메모리 limit 1Gi → 2Gi | 앱 단에서 connection reuse 패턴 도입 (DAO 레벨 수정, 완료 2026-02-15) |

## 패턴 메모

- **Harbor 관련**: 이 사이트는 air-gapped라 Harbor가 단일 실패점. ImagePullBackOff 보이면 Harbor 상태 + regcred 만료 두 가지를 먼저 본다.
- **CNPG 관련**: payment-db는 트래픽 피크가 09-10시. 모니터링 알림은 이 시간대 connection 95% 초과 시.
