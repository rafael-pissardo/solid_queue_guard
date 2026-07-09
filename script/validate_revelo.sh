#!/usr/bin/env bash
# frozen_string_literal: true

set -euo pipefail

GEM_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GEM_LINE="gem 'solid_queue_guard', path: '${GEM_ROOT}'"

validate_project() {
  local project_path="$1"
  local version_label="$2"
  local project_name
  project_name="$(basename "$project_path")"

  echo "=========================================="
  echo "Validating ${version_label} on ${project_name}"
  echo "=========================================="

  if [[ ! -d "${project_path}" ]]; then
    echo "SKIP: ${project_path} not found"
    return 1
  fi

  pushd "${project_path}" >/dev/null

  if grep -q "solid_queue_guard" Gemfile; then
    echo "Gemfile already contains solid_queue_guard"
  else
    cp Gemfile Gemfile.solid_queue_guard.bak
    echo "" >> Gemfile
    echo "${GEM_LINE}" >> Gemfile
  fi

  bundle install --quiet 2>&1 | tail -3 || true

  echo "--- solid_queue_guard:doctor (config) ---"
  bundle exec rails solid_queue_guard:doctor 2>&1 | tail -25

  echo "--- solid_queue_guard:health (runtime JSON) ---"
  bundle exec rails solid_queue_guard:health 2>&1 | tail -15

  if [[ -f Gemfile.solid_queue_guard.bak ]]; then
    mv Gemfile.solid_queue_guard.bak Gemfile
  fi

  popd >/dev/null
  echo ""
}

validate_project "/home/rpissardo/staff-backend" "v0.2"
validate_project "/home/rpissardo/companies-backend" "v0.3"
validate_project "/home/rpissardo/core" "v0.4"
validate_project "/home/rpissardo/central-candidates-backend" "v0.5"
