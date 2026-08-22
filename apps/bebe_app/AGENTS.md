# BebeApp executable rules

Inherits all rules from the repository root AGENTS.md.

## Ownership

This directory owns only application bootstrap and platform executable concerns:

- main entry points
- Flutter bootstrap
- flavors
- native configuration
- native splash
- platform initialization
- wiring required before app_base takes control

## MUST

- Keep business logic outside this application package.
- Delegate composition, routing and global application concerns to app_base.
- Keep bootstrap deterministic and observable.
- Preserve Crashlytics/Firebase initialization ordering when modified.
- Keep platform-specific configuration isolated.

## MUST NOT

- Add domain rules here.
- Add feature BLoCs here.
- Add repositories or datasources here.
- Access Supabase directly from bootstrap.
- Duplicate routing owned by app_base.
- Move functional startup-state resolution out of packages/splash.

## Validation

Changes to bootstrap must consider:

- startup failure behavior
- initialization order
- dependency registration
- Firebase/Crashlytics
- flavors/environment
- native vs Flutter splash responsibility
