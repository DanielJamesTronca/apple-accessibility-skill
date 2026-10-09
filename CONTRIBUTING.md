# Contributing

Keep the entrypoint concise and route detailed guidance to its owning reference. Preserve the user's app architecture, visual design, deployment targets, and product choices unless a requested change requires otherwise.

For a publication update, keep the version consistent in root `plugin.json`, both compatibility manifests, and the Claude marketplace entry. Keep OpenAI presentation metadata consistent between the portable manifest and its compatibility fallback. The package validator checks these relationships and that installed skills don't depend on files outside their own folder.

For a factual update, link current official documentation, a session timestamp, an App Store Connect criteria page, or an Apple staff reply. Confirm symbol names, introduction versions, and platform availability in the selected SDK—type-check a probe against the lowest supported deployment target when availability matters. Update the research date and `source-index.json` for sources actually checked; don't mark an inaccessible source as read. Follow the [research maintenance rules](skills/apple-accessibility/references/sources.md).

Apple session sample code is evidence of intent, not of API correctness. When it disagrees with the SDK, record the correction in the [API catalog](skills/apple-accessibility/references/api-catalog.md) and the conflicts table.

Don't add copied session transcripts, Apple-bundled prompts, private documentation, or authenticated assets. Use original summaries and examples. Label unresolved reports and inference explicitly.

Run:

```sh
python3 -m unittest discover -s tests -v
python3 scripts/validate_package.py
./scripts/check_examples.sh
```

The compile check requires macOS and the Xcode version named in the ledger. CI runs the portable audit tests and package validator; it doesn't claim to exercise VoiceOver or rendered UI. Report real assistive-technology validation separately.

For substantial instruction changes, exercise the relevant scenarios in `tests/skill_evals.json` with only the skill and realistic app artifacts supplied to the evaluating agent. Inspect the result for actionable decisions, unsupported APIs, invented behavior, and scope drift. Add tests only for observable audit, tool, or package contracts, not for exact headings or skill wording.
