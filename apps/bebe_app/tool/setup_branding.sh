#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

flutter pub get

dart run flutter_native_splash:create   -p config/flutter_native_splash.yaml

echo "Splash nativo generado. Los launcher icons versionados ya estan listos."
