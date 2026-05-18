#!/usr/bin/env bats
# tests/site-validate.bats — site-validate.sh 자동 검증
#
# 실행: bats tests/site-validate.bats
# 설치: brew install bats-core (macOS) 또는 npm install -g bats

setup() {
    PLUGIN_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    VALIDATE="$PLUGIN_ROOT/scripts/site-validate.sh"
    FIXTURES="$PLUGIN_ROOT/tests/fixtures"
}

@test "valid site directory passes" {
    run bash "$VALIDATE" "$FIXTURES/valid"
    [ "$status" -eq 0 ]
    [[ "$output" == *"All checks passed"* ]]
}

@test "missing required key fails with clear error" {
    run bash "$VALIDATE" "$FIXTURES/missing-required-key"
    [ "$status" -eq 1 ]
    [[ "$output" == *"required key 'customer' missing"* ]]
}

@test "unknown frontmatter key is flagged as typo" {
    run bash "$VALIDATE" "$FIXTURES/unknown-key"
    [ "$status" -eq 1 ]
    [[ "$output" == *"unknown key 'typo_key'"* ]]
}

@test "invalid enum value is rejected" {
    run bash "$VALIDATE" "$FIXTURES/invalid-value"
    [ "$status" -eq 1 ]
    [[ "$output" == *"deployment_method"* ]]
    [[ "$output" == *"hellm"* ]]
}

@test "empty directory fails with missing-file errors" {
    run bash "$VALIDATE" "$FIXTURES/empty-dir"
    [ "$status" -eq 1 ]
    [[ "$output" == *"missing required file: 00-overview.md"* ]]
}

@test "nonexistent directory fails with code 1" {
    run bash "$VALIDATE" "/tmp/does-not-exist-$$"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Directory not found"* ]]
}

@test "wrong argument count exits with code 2" {
    run bash "$VALIDATE"
    [ "$status" -eq 2 ]
}
