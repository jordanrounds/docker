#!/bin/bash
newline() {
  echo ""
}

init() {
  local app=$1

  newline
  echo "$app Container Init"
}


create_directory() {
  local directory=$1
  if [ ! -d "$directory" ]; then
    newline
    echo "Creating directory: $directory"
    mkdir "$directory"
    if [ $? -eq 0 ]; then
      echo "Directory created successfully."
    else
      echo "Failed to create directory."
      return 1
    fi
  else
    echo "Directory already exists: $directory"
  fi
}

create_link() {
  local app=$1
  local path=$2

  newline
  echo "Creating link to $app data"
  newline

  # Check if the link already exists and points to the correct path
  if [ -L "persist-data" ]; then
    if [ "$(readlink persist-data)" = "$path" ]; then
      echo "persist-data link already exists and is correct."
      return 0  # exits the function successfully
    else
      echo "persist-data link exists but is incorrect, updating..."
      if ! ln -sf "$path" persist-data; then
        echo "Failed to update link"
        return 1  # returns error from the function
      fi
    fi
  else
    # Attempt to create the link
    if ! ln -sf "$path" persist-data; then
      echo "Failed to create link"
      return 1  # returns error from the function
    else
      echo "Link created successfully."
    fi
  fi
}

# Function to set environment variables in a .env file
# Example usage
# write_env DOWNLOADS /home/jordan/downloads
write_env() {
  local var_name=$1
  local var_path=$2
  newline

  # Ensure the .env file exists, create if it does not
  if [[ ! -f .env ]]; then
    echo "Creating .env file"
    touch .env
  else
    echo ".env file already exists, updating..."
  fi

  # Validate the input
  if [[ -z "$var_name" ]]; then
    echo "Error: Missing variable name. Please provide."
    return 1
  fi

  if [[ -z "$var_path" ]]; then
    read -p "Path to ${var_name}: " entered_path
    var_path=$entered_path
    if [[ -z "$var_path" ]]; then
      echo "No path entered. Exiting..."
      return 1
    fi
  fi

  # Check if the variable is already set in the .env file
  if grep -q "^${var_name}=" .env; then
    # Replace the existing entry
    sed -i "/^${var_name}=/c\\${var_name}=${var_path}" .env
    echo "Updated ${var_name} in .env file."
  else
    # Append the new variable and its value to the .env file
    echo "${var_name}=${var_path}" >> .env
    echo "Added ${var_name} to .env file."
  fi
}

start_container() {
  local app=$1
  newline
  docker-compose down
  echo "Starting $app Container"
  docker-compose up --force-recreate --build -d
}

cleanup_old_images() {
  newline 
  echo "Cleaning up old images"
  docker image prune -f
}