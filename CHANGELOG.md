# Changelog

## [0.1.4] - 2026-03-23

### Changed
- route llm calls through pipeline when available, add caller identity for attribution

## [0.1.3] - 2026-03-22

### Changed
- Add 7 runtime sub-gem dependencies to gemspec (legion-cache, legion-crypt, legion-data, legion-json, legion-logging, legion-settings, legion-transport)
- Replace stubbed spec_helper with real sub-gem helpers and proper Helpers::Lex wiring

## [0.1.1] - 2026-03-18

### Fixed
- Validate `channel` against `VITAL_CHANNELS` in `Interoception::BodyBudget#report_vital` — rejects unknown channel keys
- Validate `coping_type` against `COPING_TYPES` in `Appraisal::AppraisalEngine#add_coping_strategy` — rejects invalid coping types

## [0.1.0] - 2026-03-18

### Added
- Initial release as domain consolidation gem
- Consolidated source extensions into unified domain gem under `Legion::Extensions::Agentic::<Domain>`
- All sub-modules loaded from single entry point
- Full spec suite with zero failures
- RuboCop compliance across all files
