# AI AGENTS PROJECT INSTRUCTIONS

## Source of truth

All AI tools, coding agents and LLMs working on this repository MUST follow the rules defined in:

- `.ai/context/architecture.md`
- `.ai/context/design.md`
- `.ai/context/conventions.md`

## Available agents

- `.ai/agents/architect.agent.md`
- `.ai/agents/feature-builder.agent.md`
- `.ai/agents/reviewer.agent.md`

## Available workflows

- `.ai/workflows/create-feature.workflow.md`
- `.ai/workflows/fix-bug.workflow.md`

## Mandatory rules

Before modifying code:

1. Read the context files.
2. Follow the appropriate workflow.
3. Respect Clean Architecture.
4. Never allow UI → Data access.
5. Never leak DTOs outside Data.
6. Never bypass UseCases.
7. Never use GetIt inside UI, Bloc or Cubit.
8. Never register Bloc/Cubit as singleton.

## Validation

Before finishing any implementation, run:

```bash
dart run tools/architecture_check.dart
```

If the architecture check fails, the task is NOT complete.

## Architecture validation

- During development, architecture must be validated using scoped checks:

```bash
dart run tools/architecture_check.dart --path lib/features/<feature_name>
```

Example:

```bash
dart run tools/architecture_check.dart --path lib/features/pokemon_list
```

- Full project validation (`dart run tools/architecture_check.dart`, no `--path`) is run as part of the feature workflow's validation step.

## Final rule

If code works but violates architecture, it is wrong.
