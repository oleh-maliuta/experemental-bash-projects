#!/bin/bash

is_positive_integer() {
  if [[
    -n "$1" &&
    "$1" =~ ^[0-9]+$
  ]]; then
    return 0
  else
    return 1
  fi
}
