# commands/ — 슬래시 커맨드 진입 규칙

`/k8s-survey`와 `/k8s-troubleshoot`가 공통으로 따르는 진입 절차. 각 명령어의 본체 동작은 `k8s-survey.md`, `k8s-troubleshoot.md` 참조.

## sites_path 해석 (양 명령어 공통, 진입 첫 단계)

1. 환경변수 `K8S_HB_SITES_PATH` 확인
2. 루트 `CLAUDE.md`의 `<!-- sites_path: ... -->` 주석 라인 확인 (주석 해제 시 활성)
3. 둘 다 없으면 다음 메시지 출력 후 **fail-loud 종료**:

```
[k8s-hb] sites/ 경로가 설정되지 않았습니다.

다음 중 하나로 설정해주세요:

  1) 환경변수:
     export K8S_HB_SITES_PATH=<경로>
     (.zshrc/.bashrc에 추가 권장)

  2) 이 CLAUDE.md의 sites_path 설정:
     sites_path: <경로>

설치 가이드: README.md
```

기본값 fallback 없음. 명시적 설정을 강제한다.

## 사이트 컨텍스트 로딩 순서 (양 명령어 공통)

`sites/<customer>/`가 존재할 때:

```
1. 00-overview.md          (필수, frontmatter+본문)
2. 06-deployment-style.md  (필수)
3. 07-stack.md             (필수)
4. 13-known-issues.md      (있으면)
5. 14-history.md           (마지막 5건만)
```

목표 컨텍스트 사용량: 1회 호출당 15-20KB 이하.

## 모순 감지 예시 (`/k8s-troubleshoot`)

sites/<customer>/ 기록과 paste된 이메일·로그 사이에 명확한 모순이 있으면 추론을 멈추고 사용자에게 확인 요청.

예: "이 사이트의 06-deployment-style.md엔 ArgoCD라고 적혀 있는데, 이메일에선 `helm upgrade` 직접 사용을 언급하셨습니다. 어느 쪽이 정확한가요?"

답변 후 진행. 사이트 기록이 틀렸으면 `sites/<customer>/06-deployment-style.md` 업데이트를 안내(사용자 승인 후 수정).

## 출력 규약

- 한국어 기본
- 명령어·파일명·K8s 식별자는 원문 그대로
- 모든 파일 생성·수정 전에 변경안 요약 + 사용자 yes 답변 필수 — 무단 자동 갱신 금지
