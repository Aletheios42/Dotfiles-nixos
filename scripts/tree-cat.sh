#!/usr/bin/env bash

tree && fd -t f | while read -r f; do echo ""; echo "=== $f ==="; echo ""; cat "$f"; done
