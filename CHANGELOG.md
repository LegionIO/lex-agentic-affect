# Changelog

## [0.1.7] - 2026-03-31

### Added
- Empathy: `MentalModel` tracks `bond_role` and `channel`; partners start with 0.8 confidence
- Empathy: `ModelStore#update_from_human_observation` processes GAIA partner observation hashes
- Empathy: `ModelStore` Apollo Local persistence — `dirty?`, `mark_clean!`, `to_apollo_entries`, `from_apollo`
- Empathy runner: `observe_human_observations(human_observations:)` processes GAIA-passed obs arrays
- CognitiveEmpathy runner: `process_human_observations(human_observations:)` — perspective tracking + contagion (partner virulence 0.3, unknown 0.05)
- Valence: `:direct_address` source urgency 0.8 added to `SOURCE_URGENCY`
- MoodState: Apollo Local persistence — `dirty?`, `mark_clean!`, `to_apollo_entries`, `from_apollo`
- `PersonalityState`: new class modeling Big Five OCEAN traits with Apollo Local persistence

## [0.1.6] - 2026-03-30

### Changed
- update to rubocop-legion 0.1.7, resolve all offenses

## [0.1.5] - 2026-03-26

### Changed
- fix remote_invocable? to use class method for local dispatch

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
