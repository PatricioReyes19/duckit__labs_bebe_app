bootstrap:
	melos bs

analyze:
	melos run analyze

format:
	melos run format

test:
	melos run test

build_runner:
	description: Generate source code in selected packages.
	exec:
		command: dart run build_runner build --delete-conflicting-outputs
		concurrency: 1
		failFast: true
	packageFilters:
		dependsOn:
			- build_runner

run_app_android:
	melos run run:app:android

run_app_ios:
	melos run run:app:ios

run_widgetbook:
	melos run run:widgetbook

run_widgetbook_chrome:
	melos run run:widgetbook:chrome