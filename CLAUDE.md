# CLAUDE PROJECT MEMORY

This repository uses strict AI development governance.

## Always read first

- `.ai/context/architecture.md`
- `.ai/context/design.md`
- `.ai/context/conventions.md`

## Roles

Use these role definitions when relevant:

- Architect: `.ai/agents/architect.agent.md`
- Feature Builder: `.ai/agents/feature-builder.agent.md`
- Reviewer: `.ai/agents/reviewer.agent.md`

## Workflows

For new features:

- `.ai/workflows/create-feature.workflow.md`

For bug fixing:

- `.ai/workflows/fix-bug.workflow.md`

## Non-negotiable rules

- UI must never access Data.
- Domain must never depend on Data or UI.
- DTOs must never leave Data.
- Cubits/Blocs must call UseCases only.
- RepositoryImpl must never be used from UI.
- GetIt must not be used inside UI, Bloc or Cubit.
- Bloc/Cubit must be registered with registerFactory.
- UseCases must return Either<Failure, T>.
- Design System and DSResponsive must be respected.

## Validation command

```bash
dart run tools/architecture_check.dart
```

If validation fails, fix it before finishing.
