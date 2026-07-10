# Contributing

Issues and PRs welcome. Keep changes focused on **production safety**, not another job dashboard.

## Setup

```bash
git clone https://github.com/rafael-pissardo/solid_queue_guard.git
cd solid_queue_guard
bundle install
cd test/dummy && bin/setup
cd ../..
bundle exec rake test
bundle exec rubocop
bundle exec appraisal install
bundle exec appraisal rake test
```

Interactive console against the dummy app:

```bash
bin/console
```

## Adding a check

1. Create `lib/solid_queue_guard/checks/config/my_check.rb` or `checks/runtime/my_check.rb`
2. Register it in `lib/solid_queue_guard/checks/registry.rb`
3. Add tests under `test/solid_queue_guard/checks/`
4. Document the check ID in [docs/checks.md](docs/checks.md)

Check IDs are derived from the class name (`MyFeatureCheck` → `my_feature`).

## Testing against Revelo-style apps

Use `script/validate_revelo.sh` to run the doctor and health tasks against local Revelo backends with a path gem:

```bash
./script/validate_revelo.sh
```

Edit the script to point at your checkout paths. The script temporarily adds a `path:` gem line, runs `solid_queue_guard:doctor` and `solid_queue_guard:health`, then restores the Gemfile.

## Release checklist

- [ ] Tests pass locally and in CI (matrix + Appraisal + `gem build`)
- [ ] RuboCop clean
- [ ] CHANGELOG updated
- [ ] Version bumped in `lib/solid_queue_guard/version.rb` and lockfiles synced
- [ ] README / docs updated for public API changes
- [ ] Tag matches gem version: `git tag vX.Y.Z && git push origin vX.Y.Z`

## Code style

- Follow existing patterns: small checks, `Check::Result`, registry-driven runner
- Mark internal APIs with `# @api private`
- Public API changes require semver discipline (see README)
