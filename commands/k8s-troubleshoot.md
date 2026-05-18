---
description: K8s 유지보수 의뢰 분석. 이메일·로그 paste → sites/<customer>/ 컨텍스트 결합 → 구조적 추론 → (a) 회신 초안 또는 (b) 출장 브리핑 + 1~2장 종이 체크리스트.
argument-hint: "<customer> (사이트 식별자, 필수)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# /k8s-troubleshoot

이메일로 받은 고객사 장애·유지보수 의뢰를 사이트 컨텍스트(sites/<customer>/)와 결합해 빠르게 분석한다. 80% 케이스는 이메일 단계에서 해결안을 도출하고, 나머지는 출장용 종이 폼을 생성한다.

## 호출 형식

```
/k8s-troubleshoot <customer>
```

`<customer>`는 필수. `sites/<customer>/`가 존재해야 함 (없으면 fail — 먼저 `/k8s-survey`로 등록 권장).

## 진입 절차 (반드시 이 순서)

### 1) sites_path 해석

CLAUDE.md "sites_path 해석 규칙"을 따른다 (env → CLAUDE.md → fail-loud). `/k8s-survey`와 동일.

### 2) `<customer>` 인자 확인

- 없으면: "어느 사이트인가요? `/k8s-troubleshoot <customer>` 형식으로 호출해주세요." 출력 후 종료
- `sites/<customer>/`이 존재하지 않으면: 다음 메시지 출력
  ```
  [k8s-hb] 사이트 '<customer>'를 찾을 수 없습니다.

  - 신규 사이트면 먼저 등록하세요:
    /k8s-survey <customer>
  - 이름 오타가 아닌지 확인:
    ls $K8S_HB_SITES_PATH/
  ```
  종료.

### 3) 사이트 컨텍스트 로드

```
sites/<customer>/00-overview.md          (전체)
sites/<customer>/06-deployment-style.md  (전체)
sites/<customer>/07-stack.md             (전체)
sites/<customer>/13-known-issues.md      (있으면 전체)
sites/<customer>/14-history.md           (마지막 5건)
```

### 4) 사용자에게 이메일·로그 paste 요청

다음 안내 출력 후 사용자 입력 대기:

```
[k8s-hb] 사이트 '<customer>' 컨텍스트 로드 완료.

다음을 알려주세요:
1. 고객사가 보낸 이메일 본문 (paste OK)
2. 첨부된 로그·명령결과 (kubectl/helm/argocd 출력 등 — paste OK)
3. 발생 시각, 영향 범위 (이메일에 없으면)

준비되면 한 번에 붙여넣어 주세요.
```

## 분석 절차 (사용자 입력 수신 후)

### A. 모순 감지 (★ CLAUDE.md 핵심 규칙)

paste된 내용에서 사이트 컨텍스트와 명확히 모순되는 진술을 찾는다:

- `06-deployment-style.md`엔 ArgoCD인데 이메일에 `helm upgrade` 직접 사용 언급
- `07-stack.md`엔 Harbor인데 이메일에 다른 레지스트리 URL
- `06`에 sealed-secrets인데 이메일에 plain Secret YAML 첨부
- 등

모순이 발견되면 **추론을 멈추고** 사용자에게 즉시 확인 요청:

```
[k8s-hb] ⚠️ 사이트 기록과 이메일 사이에 모순이 보입니다:

  - sites/<customer>/06-deployment-style.md: deployment_method = "argocd"
  - 이메일 본문: "어제 helm upgrade payment-api ... 실행"

어느 쪽이 정확한가요?
  (a) 사이트 기록이 정확함 — 이메일이 잘못 작성됨
  (b) 이메일이 정확함 — 사이트 기록을 갱신해야 함
  (c) 둘 다 사실 — 보통 ArgoCD지만 이번엔 예외적 helm 사용

답변 후 분석을 계속 진행합니다.
```

사용자 답변 후 진행. (c)인 경우 분석에 반영, (b)인 경우 분석 후 sites/06-deployment-style.md 업데이트 제안.

### B. 구조적 추론

다음 두 층의 추론을 항상 출력한다:

#### B.1 K8s 일반 패턴 (Layer 1)

이 증상이 K8s 일반적으로 어떤 원인 카테고리에서 발생하는지. 예:

```
ImagePullBackOff 일반 원인:
  (a) 레지스트리 접근 실패 — 네트워크, 인증 만료, 레지스트리 자체 장애
  (b) 이미지 미존재 — 잘못된 태그, push 실패
  (c) imagePullSecret 누락 — Pod spec 또는 namespace의 default secret
```

#### B.2 사이트 특화 (Layer 2 + Layer 3)

사이트 컨텍스트와 결합한 추론. 예:

```
이 사이트(데모코퍼레이션) 특화 분석:
  - 07-stack.md: 레지스트리는 Harbor (harbor.internal), air-gapped
  - 06-deployment-style.md: 비밀값은 sealed-secrets
  - 13-known-issues.md: 2026-03-15에 동일 증상 발생, 원인은 Harbor regcred secret 만료

  → (a) 가능성 70% (특히 regcred 만료, 90일 정책상 다시 만료될 시점)
  → (b) 가능성 10% (Harbor push 안정적, 최근 보고 없음)
  → (c) 가능성 20% (새 namespace에서 발생했다면 default secret 미설정 가능)
```

### C. 결과 분기

#### (a) 해결 가능 케이스

구조적 추론으로 90%+ 확신에 도달하고, 사용자가 사무실에서 안내할 수 있는 명령어로 검증 가능한 경우.

출력:
1. **확정 분석** (간략)
2. **검증 명령** (고객사 엔지니어에게 실행 요청할 것):
   ```
   확인 부탁드립니다:

   kubectl -n payment get secret regcred -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq '.auths."harbor.internal".auth' -r | base64 -d
   (출력의 만료일 부분 확인)
   ```
3. **회신 초안** (고객사 이메일 회신용, 정중한 톤):
   ```
   안녕하세요,

   payment-api Pod ImagePullBackOff 건 확인 부탁드립니다.

   2026-03-15에 발생했던 Harbor regcred 만료와 유사한 패턴으로 보입니다.
   현재 sealed-secrets로 관리되는 regcred는 90일 만료 정책이 있어,
   지난 갱신 후 90일이 다가오는 시점이라 확인이 필요합니다.

   다음 명령으로 만료일 확인 후 알려주세요:
   <명령어>

   만료가 임박했다면, 사내 Harbor robot account 갱신 후
   새 SealedSecret을 배포하는 절차로 진행할 수 있습니다 (소요 ~15분).

   추가 정보 필요하시면 회신 부탁드립니다.

   감사합니다.
   ```
4. **사후 기록 안내**:
   ```
   해결 후 sites/<customer>/14-history.md에 다음 한 줄 추가 권장:

   | 2026-05-14 09:30 | <작성자> | payment-api ImagePullBackOff | regcred 만료, secret 갱신으로 해결 | mail#<id> |

   추가할까요? (yes/no)
   ```
   `yes` 응답 시에만 14-history.md 수정.

#### (b) 정보 부족 — 출장 필요

구조적 추론 결과가 50-90% 사이거나, 검증에 클러스터 내부 명령이 필요한 경우.

출력:
1. **현재까지의 추론 요약** (가설 2-3개와 각각의 가능성)
2. **출장 전 브리핑** — 이 사이트의 핵심 특이사항 (Cilium eBPF, ArgoCD, Harbor 등):
   ```
   ## 출장 전 브리핑 — 데모코퍼레이션 / payment-api ImagePullBackOff

   ### 사이트 구조 핵심
   - K8s v1.30.4 kubeadm, air-gapped
   - **CNI: Cilium eBPF v1.16** — iptables 룰은 안 보임. cilium-dbg / hubble observe 사용.
   - **배포 도구: ArgoCD + Helm** — Pod 설정 확인은 `argocd app get` 부터.
   - **레지스트리: Harbor (harbor.internal)** — 단일 실패점. 이미지 풀 문제면 Harbor부터.
   - **비밀값: sealed-secrets** — controller가 cnpg-secrets-controller namespace에.

   ### 의심 가설
   1. Harbor regcred 만료 (가능성 70%) — 2026-03-15 동일 이력 있음
   2. ArgoCD sync 직후 NetworkPolicy race (가능성 15%) — 11번 known-issues 참조
   3. Harbor 자체 장애 (가능성 15%)

   ### 챙겨갈 명령 모음
   (아래 종이 폼에 명령어 박스로 정리됨)
   ```
3. **타겟 종이 폼** (1~2장, 출장용):
   ```markdown
   # 장애 진단 — 데모코퍼레이션 / payment-api / 2026-05-14

   **진단자**: ________________   **요청자**: ________________
   **시작 시각**: ____:____      **현장 도착**: ____:____

   ---

   ## [점검 1] Pod 현재 상태

   ```bash
   kubectl -n payment describe pod -l app=payment-api | tail -30
   ```
   주요 Event 메시지:
   ________________________________________________________________
   ________________________________________________________________

   ```bash
   kubectl -n payment get pod -l app=payment-api -o wide
   ```
   AGE: __________   RESTARTS: __________   STATUS: ____________________

   ## [점검 2] Harbor regcred 만료 (가설 #1)

   ```bash
   kubectl -n payment get secret regcred -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq -r '.auths."harbor.internal".auth' | base64 -d
   ```
   사용자명: __________   토큰 만료일 (Harbor UI 확인): ____________________

   만료 임박/만료됨? [ ] Y  [ ] N

   ## [점검 3] Harbor 자체 상태 (가설 #3)

   ```bash
   kubectl -n harbor get pods
   ```
   비정상 Pod: ____________________
   harbor.internal HTTPS 응답 (브라우저): [ ] 200 OK  [ ] 5xx  [ ] 타임아웃

   ## [점검 4] ArgoCD sync 이력 (가설 #2)

   ```bash
   argocd app get payment-prod
   ```
   Sync Status: [ ] Synced  [ ] OutOfSync   Health: [ ] Healthy  [ ] Degraded

   ```bash
   argocd app history payment-prod | head -5
   ```
   최근 sync 시각: ____________________   증상 시작과 일치? [ ] Y  [ ] N

   ## [잠정 가설 + 조치]

   가장 가능성 높은 원인: ________________________________________
   적용한 조치 (시각·내용·결과):
   1. ____:____ ________________________________________
   2. ____:____ ________________________________________
   3. ____:____ ________________________________________

   ---

   **복귀 후 액션**: Claude와 자연어로 결과 공유 → 14-history.md 기록 + (필요 시) 13-known-issues.md 업데이트
   ```

## 호출 예시

```
/k8s-troubleshoot sample-customer
(사용자가 이메일·로그 paste)
→ Claude: 모순 감지 / 구조적 추론 / (a) 회신초안 or (b) 출장폼
```

## Notes for Claude

- **항상 두 층 추론을 보여준다** (Layer 1 일반, Layer 2 사이트 특화). 사용자가 그 차이를 알 수 있게.
- **모순 감지는 절대 침묵하지 않는다.** 발견하면 즉시 정지 + 사용자 확인.
- **추론 가능성을 숫자로 보여준다** (70% / 15% / 15% 등). 명확한 우선순위 부여.
- **14-history.md 자동 수정 금지.** 사용자 yes 답변 후에만.
- **종이 폼은 A4 1~2장 분량.** 의심 가설 3개 이내, 각 가설당 점검 항목 2-4개.
- **회신 초안은 정중한 한국어 비즈니스 톤.** 너무 친근하거나 너무 딱딱하지 않게.
- **종이 폼의 모든 명령어는 ``` bash ``` 코드 펜스.** 손으로 옮길 때 오기 방지.
