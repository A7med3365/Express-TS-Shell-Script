#!/bin/bash

# Check if argument is provided, and if the argument is -h or --help
if [ $# -eq 0 ] || { [ $# -eq 1 ] && { [ "$1" = "-h" ] || [ "$1" = "--help" ]; }; }; then
  cat <<EOF


example usage:

# create a new express typescript project
  express-ts.sh init <project-name>

# create a new api endpoint
  express-ts.sh api add

# remove an existing api endpoint
  express-ts.sh api rm

# list existing api endpoints
  express-ts.sh api ls

# list existing api collections
  express-ts.sh collections ls

# show help
  express-ts.sh -h
  express-ts.sh --help
  
EOF
  exit 1
fi

# Check if the first argument is init
if [ "$1" == "init" ]; then
  ./expts-app-init.sh "$2"
  exit 1
fi

# Check if the first argument is api
if [ "$1" == "api" ]; then
  # Check if the second argument is add
  if [ "$2" == "add" ]; then
    ../expts-new_api.sh
    exit 1
  fi

  # Check if the second argument is rm
  if [ "$2" == "rm" ]; then
    ../expts-remove_api.sh
    exit 1
  fi

  # Check if the second argument is ls
  if [ "$2" == "ls" ]; then
    ../expts-list_api.sh
    exit 1
  fi

  # Check if the second argument is invalid
  if [ -n "$2" ]; then
    echo "invalid argument: $2"
    exit 1
  fi
fi
