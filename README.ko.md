# dev-clean

macOS/Linux 개발 캐시 및 빌드 아티팩트 정리 스크립트.

**차별점:** 기존 클리너가 건드리지 않는 **LLM 코딩 도구 캐시**(Claude Code, Codex, Cursor)를 함께 정리합니다.

## 정리 대상

| 카테고리 | 대상 | 보존 기간 |
|---------|------|----------|
| **Claude Code** | 디버그 로그, file-history, 프로젝트 캐시 | 1–14일 |
| **Codex** | 세션, 아카이브 세션, 로그, worktree | 7–14일 |
| **패키지 매니저** | npm, pnpm, bun, uv, conda, brew 캐시 | 전체 |
| **빌드 아티팩트** | Rust `target/`, `.next/`, `.turbo/cache` | 전체 |
| **브라우저** | Puppeteer, Playwright 다운로드 | 전체 |
| **macOS 전용** | Xcode DerivedData, Archives, 시뮬레이터 캐시 | 전체 |
| **기타 도구** | Cursor worktree, opencode 캐시 | 전체 |

## 설치

**원라이너:**

```bash
curl -fsSL https://raw.githubusercontent.com/eyejoker/dev-clean/main/install.sh | bash
```

**수동 설치:**

```bash
curl -fsSL https://raw.githubusercontent.com/eyejoker/dev-clean/main/dev-clean -o ~/.local/bin/dev-clean
chmod +x ~/.local/bin/dev-clean
```

## 사용법

```bash
# 미리보기 (기본값, 안전)
dev-clean

# 실제 정리
dev-clean --run
```

출력 예시:

```
=== dev-clean ===
(dry-run mode — nothing will be deleted)

[Claude Code]
  [DRY] debug logs (1d+)                              42 MB (>1d)
  [DRY] projects (14d+)                              180 MB (>14d)
[Package Managers]
  [DRY] npm cache                                    512 MB
  [DRY] pnpm store prune                             (prune unused)
[Build Artifacts]
  [DRY] .next: my-app/.next                          340 MB

=== Total: 1074 MB ===
```

## 설정

빌드 아티팩트를 스캔하는 기본 디렉토리:

- `~/Developer`
- `~/Projects`
- `~/Documents/GitHub`
- `~/src`
- `~/repos`
- `~/code`

`DEV_CLEAN_DIRS` 환경변수로 커스텀 (콜론으로 구분):

```bash
export DEV_CLEAN_DIRS="$HOME/work:$HOME/personal"
dev-clean --dry-run
```

## 스케줄링

### macOS (launchd)

설치 스크립트에서 주 1회 자동 실행을 설정할 수 있습니다. 수동 설정:

```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.eyejoker.dev-clean.plist
```

### Linux (cron)

```bash
# 매주 일요일 오전 3시 실행
(crontab -l 2>/dev/null; echo "0 3 * * 0 $HOME/.local/bin/dev-clean --run") | crontab -
```

## 왜 만들었나

`npx npkill`이나 macOS 클리너는 `node_modules`나 시스템 캐시를 잘 처리합니다. 하지만 LLM 코딩 도구들(Claude Code, Codex, Cursor)이 만드는 캐시는 아무도 건드리지 않습니다:

- `~/.claude/debug/`는 며칠 만에 수백 MB 쌓임
- `~/.codex/sessions/`는 전체 대화 이력 보관
- Playwright/Puppeteer 다운로드는 1 GB 초과 가능

dev-clean은 이 모든 것을 한 번에 정리하며, 활성 세션은 보존하는 합리적인 보존 정책을 적용합니다.

## 라이선스

[MIT](LICENSE)
