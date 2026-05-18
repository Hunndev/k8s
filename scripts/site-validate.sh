#!/usr/bin/env bash
# site-validate.sh — sites/<customer>/ 디렉토리의 frontmatter 검증
#
# 사용법:
#   bash scripts/site-validate.sh <site-directory>
#
# 종료 코드:
#   0 - 모든 검증 통과
#   1 - 검증 실패 (누락 / 오타 / 허용값 외)
#   2 - 사용법 오류 (잘못된 인자)
#
# 검증 대상 파일:
#   00-overview.md, 06-deployment-style.md, 07-stack.md,
#   13-known-issues.md, 14-history.md
#
# README.md는 검증 대상에서 제외 (SCHEMA.md 규정).

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# --- 종료 처리 ----------------------------------------------------------
ERRORS=0
WARNINGS=0
SITE_DIR=""

usage() {
    echo "Usage: $0 <site-directory>" >&2
    echo "  Example: $0 sites/sample-customer" >&2
    exit 2
}

error() {
    echo "  [ERROR] $1" >&2
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo "  [WARN]  $1" >&2
    WARNINGS=$((WARNINGS + 1))
}

ok() {
    echo "  [OK]    $1"
}

# --- 인자 처리 ----------------------------------------------------------
[ $# -eq 1 ] || usage
SITE_DIR="$1"

if [ ! -d "$SITE_DIR" ]; then
    echo "[FAIL] Directory not found: $SITE_DIR" >&2
    exit 1
fi

# --- frontmatter 추출 ---------------------------------------------------
# 파일 첫 줄이 '---'면 다음 '---'까지를 frontmatter로 본다.
extract_frontmatter() {
    local file="$1"
    awk '
        BEGIN { in_fm = 0; started = 0 }
        NR == 1 {
            if ($0 == "---") { in_fm = 1; started = 1; next }
            else { exit }
        }
        in_fm && $0 == "---" { exit }
        in_fm { print }
    ' "$file"
}

# frontmatter에서 특정 키의 값 추출 (따옴표 제거)
get_value() {
    local fm="$1"
    local key="$2"
    echo "$fm" | awk -v k="$key" '
        $0 ~ "^"k"[[:space:]]*:" {
            sub("^"k"[[:space:]]*:[[:space:]]*", "")
            gsub(/^"|"$/, "")
            gsub(/^'\''|'\''$/, "")
            print
            exit
        }
    '
}

# frontmatter의 모든 키 목록 추출
get_keys() {
    local fm="$1"
    echo "$fm" | awk '
        /^[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*:/ {
            sub(/[[:space:]]*:.*$/, "")
            print
        }
    '
}

# 값 검증 헬퍼
check_required() {
    local fm="$1"; local key="$2"; local file="$3"
    local val=$(get_value "$fm" "$key")
    if [ -z "$val" ]; then
        error "$file: required key '$key' missing or empty"
        return 1
    fi
    return 0
}

check_enum() {
    local fm="$1"; local key="$2"; local file="$3"; shift 3
    local val=$(get_value "$fm" "$key")
    [ -z "$val" ] && return 0  # required는 별도로 처리
    local allowed=" $* "
    if [[ " $allowed " != *" $val "* ]]; then
        error "$file: key '$key' has invalid value '$val' (allowed: $*)"
        return 1
    fi
    return 0
}

check_bool() {
    local fm="$1"; local key="$2"; local file="$3"
    local val=$(get_value "$fm" "$key")
    [ -z "$val" ] && return 0
    if [ "$val" != "true" ] && [ "$val" != "false" ]; then
        error "$file: key '$key' must be 'true' or 'false', got '$val'"
        return 1
    fi
    return 0
}

check_date() {
    local fm="$1"; local key="$2"; local file="$3"
    local val=$(get_value "$fm" "$key")
    [ -z "$val" ] && return 0
    if ! [[ "$val" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        error "$file: key '$key' must be YYYY-MM-DD format, got '$val'"
        return 1
    fi
    return 0
}

check_unknown_keys() {
    local fm="$1"; local file="$2"; shift 2
    local allowed=" $* "
    local key
    while IFS= read -r key; do
        [ -z "$key" ] && continue
        if [[ " $allowed " != *" $key "* ]]; then
            error "$file: unknown key '$key' (typo? allowed: $*)"
        fi
    done < <(get_keys "$fm")
}

# --- 파일별 검증 --------------------------------------------------------

validate_00_overview() {
    local file="$SITE_DIR/00-overview.md"
    if [ ! -f "$file" ]; then
        error "missing required file: 00-overview.md"
        return
    fi
    local fm=$(extract_frontmatter "$file")
    if [ -z "$fm" ]; then
        error "00-overview.md: missing frontmatter"
        return
    fi

    local allowed_keys="customer risk_level last_updated contract cni cluster_version deployment_method airgapped"
    check_unknown_keys "$fm" "00-overview.md" $allowed_keys

    check_required "$fm" "customer" "00-overview.md"
    check_required "$fm" "risk_level" "00-overview.md" \
        && check_enum "$fm" "risk_level" "00-overview.md" low medium high critical
    check_required "$fm" "last_updated" "00-overview.md" \
        && check_date "$fm" "last_updated" "00-overview.md"
    check_enum "$fm" "contract" "00-overview.md" maintenance consulting construction other
    check_enum "$fm" "cni" "00-overview.md" cilium calico flannel weave canal other
    check_required "$fm" "cluster_version" "00-overview.md"
    local cv=$(get_value "$fm" "cluster_version")
    if [ -n "$cv" ] && ! [[ "$cv" =~ ^v?[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        error "00-overview.md: cluster_version '$cv' does not match vX.Y[.Z]"
    fi
    check_required "$fm" "deployment_method" "00-overview.md" \
        && check_enum "$fm" "deployment_method" "00-overview.md" helm argocd flux kustomize raw mixed
    check_required "$fm" "airgapped" "00-overview.md" \
        && check_bool "$fm" "airgapped" "00-overview.md"

    ok "00-overview.md"
}

validate_06_deployment_style() {
    local file="$SITE_DIR/06-deployment-style.md"
    if [ ! -f "$file" ]; then
        error "missing required file: 06-deployment-style.md"
        return
    fi
    local fm=$(extract_frontmatter "$file")
    if [ -z "$fm" ]; then
        error "06-deployment-style.md: missing frontmatter"
        return
    fi

    local allowed_keys="deployment_method gitops_enabled config_repo secret_management"
    check_unknown_keys "$fm" "06-deployment-style.md" $allowed_keys

    check_required "$fm" "deployment_method" "06-deployment-style.md" \
        && check_enum "$fm" "deployment_method" "06-deployment-style.md" helm argocd flux kustomize raw mixed
    check_required "$fm" "gitops_enabled" "06-deployment-style.md" \
        && check_bool "$fm" "gitops_enabled" "06-deployment-style.md"
    check_required "$fm" "secret_management" "06-deployment-style.md" \
        && check_enum "$fm" "secret_management" "06-deployment-style.md" sealed-secrets external-secrets vault sops plain mixed

    ok "06-deployment-style.md"
}

validate_07_stack() {
    local file="$SITE_DIR/07-stack.md"
    if [ ! -f "$file" ]; then
        error "missing required file: 07-stack.md"
        return
    fi
    local fm=$(extract_frontmatter "$file")
    if [ -z "$fm" ]; then
        error "07-stack.md: missing frontmatter"
        return
    fi

    local allowed_keys="stack_summary"
    check_unknown_keys "$fm" "07-stack.md" $allowed_keys
    check_required "$fm" "stack_summary" "07-stack.md"

    ok "07-stack.md"
}

validate_13_known_issues() {
    local file="$SITE_DIR/13-known-issues.md"
    if [ ! -f "$file" ]; then
        warn "missing optional file: 13-known-issues.md"
        return
    fi
    local fm=$(extract_frontmatter "$file")
    if [ -n "$fm" ]; then
        local allowed_keys="issue_count"
        check_unknown_keys "$fm" "13-known-issues.md" $allowed_keys
        local ic=$(get_value "$fm" "issue_count")
        if [ -n "$ic" ] && ! [[ "$ic" =~ ^[0-9]+$ ]]; then
            error "13-known-issues.md: issue_count '$ic' must be non-negative integer"
        fi
    fi
    ok "13-known-issues.md"
}

validate_14_history() {
    local file="$SITE_DIR/14-history.md"
    if [ ! -f "$file" ]; then
        warn "missing optional file: 14-history.md"
        return
    fi
    local fm=$(extract_frontmatter "$file")
    if [ -n "$fm" ]; then
        local allowed_keys="last_entry"
        check_unknown_keys "$fm" "14-history.md" $allowed_keys
        check_date "$fm" "last_entry" "14-history.md"
    fi
    ok "14-history.md"
}

# --- 실행 ---------------------------------------------------------------
echo "[k8s-hb site-validate] Validating: $SITE_DIR"
echo ""

validate_00_overview
validate_06_deployment_style
validate_07_stack
validate_13_known_issues
validate_14_history

echo ""
if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo "[OK] All checks passed."
    else
        echo "[OK] Passed with $WARNINGS warning(s)."
    fi
    exit 0
else
    echo "[FAIL] $ERRORS error(s), $WARNINGS warning(s)."
    exit 1
fi
