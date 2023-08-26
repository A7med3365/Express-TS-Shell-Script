#!/bin/bash

# check if there is a project in the current directory
if [ ! -f "./express-project.json" ]; then
    echo "No project found in the current directory"

    projects="$(find . -type f -name "express-project.json" -printf '%h\n')"

    if [ -z "$projects" ]; then
        echo "No projects found in the subdirectories"
    else
        echo -e "\nProjects found in the subdirectories:"
        printf '%s\n' "$projects"
    fi
    exit 1
fi

# Print the list of existing collections with numbers
echo "Existing collections:"
mapfile -t collections < <(ls -1 "./src/controllers")
for i in "${!collections[@]}"; do
    echo "$((i + 1)). ${collections[$i]}"
done

# Prompt the user to choose a collection by number or create a new one
while true; do
    read -rp "Enter the number of an existing collection or enter a new collection name in camel case: " collection_input

    # Check if the user entered a number
    if [[ "$collection_input" =~ ^[0-9]+$ ]]; then
        # Subtract 1 from the number to get the index of the selected collection
        collection_index=$((collection_input - 1))
        # Check if the selected collection index is valid
        if ((collection_index >= 0 && collection_index < ${#collections[@]})); then
            # Use the selected collection
            collection_name="${collections[$collection_index]}"
            echo "Using existing collection $collection_name"
            break
        else
            echo "Invalid collection number"
        fi
    else
        # Check if the entered collection name is empty
        if [[ -z "$collection_input" || "$collection_input" =~ [[:space:]] ]]; then
            echo "Invalid collection name"
        else
            # Use the entered collection name
            collection_name="$collection_input"
            # Create the collection folder in the controllers folder
            mkdir -p "./src/controllers/$collection_name"
            echo "Created new collection $collection_name"
            break
        fi
    fi
done

# Prompt the user for the file name
read -rp "Enter file name in camel case (without the .ts extension): " filename
read -rp "Enter the method (get, post, put, delete): " method
read -rp "Enter the route (including root '/'): " route

# get the import and mount line numbers
import_line=$(jq '.import_line' express-project.json | tr -dc '0-9')
mount_line=$(jq '.mount_line' express-project.json | tr -dc '0-9')

jq ".collections.$collection_name.$filename.method=\"$method\"" express-project.json >tmp.json && mv tmp.json express-project.json
jq ".collections.$collection_name.$filename.route=\"$route\"" express-project.json >tmp.json && mv tmp.json express-project.json

# Create the routes file for the collection in the routes folder if it doesn't exist, if it does exist, insert the route into the file
if [ -f "./src/routes/$collection_name.ts" ]; then

    ctrl_import_line=$(grep -n "//<--import controllers-->>" "./src/routes/$collection_name.ts" | cut -d: -f1)
    ctrl_import_line=$((ctrl_import_line + 1))

    ctrl_router_line=$(grep -n "//<--make api routes-->>" "./src/routes/$collection_name.ts" | cut -d: -f1)
    ctrl_router_line=$((ctrl_router_line + 2))

    echo "import line: $ctrl_import_line"
    echo "router line: $ctrl_router_line"

    sed -i "${ctrl_import_line}i\\
import { ${filename}Ctrl } from \"../controllers/${collection_name}/${filename}\";" "./src/routes/$collection_name.ts"

    sed -i "${ctrl_router_line}i\\
router.${method}('${route}', ${filename}Ctrl);" "./src/routes/$collection_name.ts"

else
    # Create the collection folder in the controllers folder if it doesn't exist
    mkdir -p "./src/controllers/$collection_name"

    # touch "./.shell_variables/.$collection_name"
    # echo "$filename" >>"./.shell_variables/.$collection_name"

    touch "./src/routes/$collection_name.ts"
    echo "created new collection $collection_name"

    echo "import express from 'express';
    import { body } from 'express-validator';

    const router = express.Router();

    //<--import controllers-->>
    import { ${filename}Ctrl } from \"../controllers/${collection_name}/${filename}\"

    //<--make api routes-->>
    router.${method}('${route}', ${filename}Ctrl);

    export { router as ${collection_name}Router };" >"./src/routes/$collection_name.ts"

    # Add the import and mount lines to the server.ts file

    sed -i "${mount_line}i\\
app.use(${collection_name}Router);" "./src/server.ts"

    sed -i "${import_line}i\\
import { ${collection_name}Router } from './routes/${collection_name}';" "./src/server.ts"

    # Increment the import and mount line numbers
    import_line=$((import_line + 1))
    mount_line=$((mount_line + 2))

    # Save the import and mount line numbers to the .shell_variables folder
    jq ".import_line = ${import_line}" express-project.json >tmp.json && mv tmp.json express-project.json
    jq ".mount_line = ${mount_line}" express-project.json >tmp.json && mv tmp.json express-project.json

fi

# Create the controller file
touch "./src/controllers/$collection_name/$filename.ts"

# populate the controller file
echo "import { Request, Response } from 'express';
import { validationResult } from 'express-validator';

const ${filename}Ctrl = (req: Request, res: Response) => {
  res.send({});
};

export { ${filename}Ctrl };" >"./src/controllers/$collection_name/$filename.ts"
