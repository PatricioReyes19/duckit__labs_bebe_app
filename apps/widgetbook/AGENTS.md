# Widgetbook rules

Inherits all rules from the repository root AGENTS.md.

Widgetbook is a development and visual-validation application.

## Purpose

Widgetbook exists to expose and validate reusable Design System components and visual states.

## MUST

- Use public Design System APIs.
- Provide representative component states.
- Include relevant loading, empty, error, disabled and edge states when applicable.
- Keep use cases deterministic.
- Prefer realistic fixtures without introducing production dependencies.

## MUST NOT

- Implement business logic.
- Connect directly to production repositories or datasources.
- Require Supabase, Firebase or remote APIs for component rendering.
- Create Widgetbook-only duplicates of Design System components.
- modify production behavior solely to make a Widgetbook story easier.

## Atomic Design

When a component changes:

1. update the component at its correct Atomic Design level;
2. update or add the corresponding Widgetbook use case;
3. ensure the use case demonstrates important visual states;
4. keep fixtures separate from production state management.
