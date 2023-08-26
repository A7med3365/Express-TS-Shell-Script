#!/bin/bash

# Check if project name is provided
if [ $# -eq 0 ]; then
  echo "please provide a project name"
  exit 1
fi

# Check if project name is valid
if [[ ! $1 =~ ^[a-zA-Z0-9_]+$ ]]; then
  echo "project name must be alphanumeric"
  exit 1
fi

# Check if project name already exists
if [ -d "$1" ]; then
  echo "project name already exists"
  exit 1
fi

# Create project folder
./expts-app-boilerplate.sh "$1"

echo "installing dependencies..."
cd "$PWD/$1" || exit
npm install express @types/express body-parser @types/body-parser express-validator typescript ts-node-dev

# Get the line numbers of the import and mount lines
import_line=$(grep -n "<--import routers-->>" src/server.ts | cut -d: -f1)
mount_line=$(grep -n "<--mount routes-->>" src/server.ts | cut -d: -f1)

# Increment the line numbers by 1
import_line=$((import_line + 1))
mount_line=$((mount_line + 1))

# Write the line numbers to the express-project.json file
echo "{\"import_line\": \"$import_line\", \"mount_line\": \"$mount_line\"}" | jq '.' >"express-project.json"

jq '.scripts.start = "ts-node-dev --poll src/server.ts"' package.json >tmp.json && mv tmp.json package.json
