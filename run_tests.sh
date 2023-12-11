#!/bin/bash
# https://github.com/cyberang3l/octavi-xplane-flywithlua
#
# Exit on error
set -e

# ./run_test
# ./run_test -p "string_to_filter_tests_by_name"

for f in octavilib/*_test.lua; do
  lua "${f}" -v "${@}"
done
