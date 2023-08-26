#!/bin/bash

read -rp "enter the server port:[default: 4000] " port
port=${port:-4000}

current_dir="$PWD"

mkdir -p "$current_dir/$1/src/models" "$current_dir/$1/src/routes" "$current_dir/$1/src/controllers"
touch "$current_dir/$1/src/server.ts" "$current_dir/$1/express-project.json" "$current_dir/$1/.env" "$current_dir/$1/.gitignore" "$current_dir/$1/README.md"
touch "$current_dir/$1/Dockerfile" "$current_dir/$1/.dockerignore"

#change directory to the project folder
cd "$current_dir/$1" || exit
echo "$PWD"

{
  echo "node_modules/"
  echo ".env"
  echo ".gitignore"
} >>"$current_dir/$1/.gitignore"

echo "# express-typescript" >>"README.md"

npm init -y
tsc --init

# echo "SESSION_SECRET=thisisasecret" >>".env"

# Code snippet to add to the server.ts file
code_snippet=$(
  cat <<EOF
import express from 'express';
import { json } from 'body-parser';


//<--import routers-->>


const app = express();
app.use(json());


//<--mount routes-->>


const port = ${port};

app.listen(port, () => {
  console.log('Server running on port ${port}');
});


EOF
)

# Append the code snippet to the file
echo "$code_snippet" >>"$current_dir/$1/src/server.ts"

# code snippet to add to the Dockerfile
dockerfile_code=$(
  cat <<EOF
FROM node:alpine

WORKDIR /app
COPY package.json .
RUN npm install
COPY . .

CMD ["npm", "start"]
EOF
)

# Append the code snippet to the file
echo "$dockerfile_code" >>"$current_dir/$1/Dockerfile"

# code snippet to add to the .dockerignore file
dockerignore_code=$(
  cat <<EOF
node_modules
express-project.json
EOF
)

# Append the code snippet to the file
echo "$dockerignore_code" >>"$current_dir/$1/.dockerignore"

echo "Folders created successfully in $current_dir/$1!"
