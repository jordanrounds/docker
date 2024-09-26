#!/bin/bash
INSTANCE_NAME='mosquitto'
PASSWD_FILE='/mosquitto/config/mosquitto.passwd'
LINE='-------------------------------------'

# Check if gum is installed
if ! command -v gum &> /dev/null
then
    echo "gum is not installed. Installing it now..."
    if [ "$(uname)" == "Darwin" ]; then
        brew install charmbracelet/gum/gum
    elif [ -x "$(command -v apt)" ]; then
        echo "Installing gum using apt."
        sudo apt update && sudo apt install -y gum
    elif [ -x "$(command -v dnf)" ]; then
        echo "Installing gum using dnf."
        sudo dnf install -y gum
    elif [ -x "$(command -v pacman)" ]; then
        echo "Installing gum using pacman."
        sudo pacman -S gum
    else
        echo "Cannot automatically install gum. Please install it manually: https://github.com/charmbracelet/gum"
        exit 1
    fi
fi

echo 'Mosquitto User Management'
gum style --border double --padding "1 2" --margin 1 --align center "Mosquitto User Management"
gum spin --spinner dot --title "Fetching Options" -- sleep 1
option=$(gum choose --cursor.foreground="#FF00FF" --cursor.background="#00FFFF" "Add User" "Delete User" "Change User Password" "Exit")

case $option in
  "Add User")
    gum style --border rounded --padding "1 2" --align center "Adding New User"
    username=$(gum input --placeholder "Username" --width 30)
    password=$(gum input --password --placeholder "Password" --width 30)
    
    gum confirm "Add user: $username?" && {
      gum spin --spinner dot --title "Adding user $username..." -- docker exec -d $INSTANCE_NAME mosquitto_passwd -b $PASSWD_FILE $username $password
      docker exec -d $INSTANCE_NAME kill -HUP 1
      gum style --foreground 212 "User $username added successfully!"
    } || gum style --foreground 160 "User creation canceled."
    ;;
    
  "Delete User")
    gum style --border rounded --padding "1 2" --align center "Deleting User"
    username=$(gum input --placeholder "Username" --width 30)
    
    gum confirm "Delete user: $username?" && {
      gum spin --spinner dot --title "Deleting user $username..." -- docker exec -d $INSTANCE_NAME mosquitto_passwd -D $PASSWD_FILE $username
      docker exec -d $INSTANCE_NAME kill -HUP 1
      gum style --foreground 212 "User $username deleted successfully!"
    } || gum style --foreground 160 "User deletion canceled."
    ;;
    
  "Change User Password")
    gum style --border rounded --padding "1 2" --align center "Changing User Password"
    input="/home/docker/.local-persist/mosquitto/config/mosquitto.passwd"
    usernames=()
    index=1

    while IFS=':' read -r username password
    do
      usernames+=( "$username" )
    done < $input

    selected_user=$(printf "%s\n" "${usernames[@]}" | gum choose)

    new_password=$(gum input --password --placeholder "Enter new password for $selected_user" --width 30)
    
    gum confirm "Change password for $selected_user?" && {
      gum spin --spinner dot --title "Changing password for $selected_user..." -- docker exec -d $INSTANCE_NAME mosquitto_passwd -D $PASSWD_FILE $selected_user
      docker exec -d $INSTANCE_NAME mosquitto_passwd -b $PASSWD_FILE $selected_user $new_password
      docker exec -d $INSTANCE_NAME kill -HUP 1
      gum style --foreground 212 "Password changed successfully for $selected_user!"
    } || gum style --foreground 160 "Password change canceled."
    ;;
    
  "Exit")
    gum style --foreground 160 "Exiting script..."
    exit 0
    ;;
    
  *)
    gum style --foreground 160 "Invalid option selected."
    ;;
esac

exit 1