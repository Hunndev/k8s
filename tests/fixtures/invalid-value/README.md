# _TEMPLATE

신규 사이트 등록 시 이 디렉토리 전체를 복사해서 시작한다.

```bash
cp -r $K8S_HB_SITES_PATH/_TEMPLATE $K8S_HB_SITES_PATH/<customer-name>
```

복사 후:
1. `00-overview.md` frontmatter의 `customer` 값을 실제 고객사명으로 변경
2. `last_updated`를 오늘 날짜로
3. Claude Code에서 `/k8s-survey <customer-name>` 실행 → 인쇄 가능한 인터뷰 폼 출력
4. 종이 들고 사이트 방문 → 펜으로 답 채우기
5. 복귀 후 Claude에 결과 알려주면 → Claude가 각 파일을 채워줌

## 파일 6개

| 파일 | 역할 |
|---|---|
| `00-overview.md` | 한눈에 보기. Claude가 첫 진단 시 가장 먼저 읽는 파일 |
| `06-deployment-style.md` | 배포 도구 (Helm/ArgoCD/Flux/Kustomize/raw) + 비밀값 관리 |
| `07-stack.md` | 설치된 내부 컴포넌트 카탈로그 (있는 것만) |
| `13-known-issues.md` | 알려진 이슈 누적 |
| `14-history.md` | 작업 이력 |
| `README.md` | 이 안내 |

frontmatter 스키마는 `../SCHEMA.md` 참조.

## 원칙

- **있는 것만 기록한다.** 사용하지 않는 컴포넌트 섹션은 그냥 삭제하거나 "해당 없음" 명시.
- **의도(WHY)를 적는다.** "Cilium 선택 이유는 eBPF L7 정책이 필요했기 때문" 같은 결정 배경.
- **현재 상태(WHAT IS NOW)는 사이트 가서 직접 확인.** 마크다운은 메모리, 클러스터는 진실.
