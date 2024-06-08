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

# Example usage
#create_secret_file "secrets_directory" "mariadb.password.root" "Enter your MariaDB root password:"
create_secret_file() {
  local secrets_dir="$1"
  local filename="$2"
  local prompt="$3"

  # Ensure the secrets directory exists
  if [[ ! -d "$secrets_dir" ]]; then
    echo "The directory $secrets_dir does not exist."
    return 1  # Exit with a non-zero status to indicate failure
  fi

  local secret_file="${secrets_dir}/${filename}"

  echo
  echo "Attempting to create secret file at $secret_file"
  echo

  if [[ -f "$secret_file" ]]; then
    read -p "$secret_file already exists. Do you want to overwrite it? (y/n): " overwrite_response
    if [[ $overwrite_response == "y" ]]; then
      read -p "$prompt " value
    else
      echo "Skipping creation of $secret_file."
      return 2  # Exit with a specific status to indicate skipped operation
    fi
  else
    read -p "$prompt " value
  fi

  # Attempt to write the prompted value to the file
  if echo -n "$value" > "$secret_file"; then
    echo "Added $secret_file and populated with the value."
  else
    echo "Failed to write to $secret_file."
    return 3  # Exit with a different non-zero status to indicate write failure
  fi
}


# Function to ensure the .env file exists
ensure_env_file() {
  if [[ ! -f .env ]]; then
    echo "Creating .env file"
    touch .env
  else
    echo ".env file already exists, updating..."
  fi
}

# Function to write variable and its value to .env file
write_env() {
  local var_name=$1
  local var_value=$2

  newline

  ensure_env_file

  # Check if the variable is already set in the .env file
  if grep -q "^${var_name}=" .env; then
    # Replace the existing entry
    sed -i "/^${var_name}=/c\\${var_name}=${var_value}" .env
    echo "Updated ${var_name} in .env file."
  else
    # Append the new variable and its value to the .env file
    echo "${var_name}=${var_value}" >> .env
    echo "Added ${var_name} to .env file."
  fi
}

# Function to prompt user for variable value and write to .env file
write_env_prompt() {
  local var_name=$1
  local var_prompt=$2

  newline

  ensure_env_file

  # Validate the input
  if [[ -z "$var_name" ]]; then
    echo "Error: Missing variable name. Please provide."
    return 1
  fi

  if [[ -z "$var_prompt" ]]; then
    echo "Error: Missing prompt message. Please provide."
    return 1
  fi

  read -p "$var_prompt: " var_value
  if [[ -z "$var_value" ]]; then
    echo "No value entered. Exiting..."
    return 1
  fi

  # Check if the variable is already set in the .env file
  if grep -q "^${var_name}=" .env; then
    # Replace the existing entry
    sed -i "/^${var_name}=/c\\${var_name}=${var_value}" .env
    echo "Updated ${var_name} in .env file."
  else
    # Append the new variable and its value to the .env file
    echo "${var_name}=${var_value}" >> .env
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