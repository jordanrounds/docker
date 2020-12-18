#!/bin/bash
INSTANCE_NAME='mosquitto'
PASSWD_FILE='/mosquitto/config/mosquitto.passwd'
LINE='-------------------------------------'

echo 'Mosquitto User Management'
echo
echo 'What would you like to do?'
echo $LINE
echo '1) Add User'
echo '2) Delete User'
echo '3) Change User Password'
echo $LINE

read -p 'Choose option: '
echo

if [ ${REPLY} -eq 1 ]; then
  echo "Adding New User"
  echo $LINE
  read -p 'Username: ' username
  read -sp 'Password: ' password
  echo
  echo "Adding user: $username"
  docker exec -d $INSTANCE_NAME mosquitto_passwd -b $PASSWD_FILE $username $password
  docker exec -d $INSTANCE_NAME kill -HUP 1
elif [ ${REPLY} -eq 2 ]; then
  echo "Deleting User"
  echo $LINE
  read -p 'Username: ' username
  docker exec -d $INSTANCE_NAME mosquitto_passwd -D $PASSWD_FILE $username
  docker exec -d $INSTANCE_NAME kill -HUP 1
elif [ ${REPLY} -eq 3 ]; then
  echo "Changing User Password"
  echo $LINE
  input="/home/docker/.local-persist/mosquitto/config/mosquitto.passwd"
  usernames=()
  index=1

  while IFS=':' read -r username password
  do
    usernames+=( "$username" )
    echo "$index) $username"
    ((index=index+1))
  done < $input

  echo $LINE
  read -p 'Choose option: ' user_i
  echo

  ((user_i=user_i-1))

  read -sp "Enter new password for ${usernames[user_i]}: " new_password
  echo
  echo
  echo "Password changed for user ${usernames[user_i]}"
  docker exec -d $INSTANCE_NAME mosquitto_passwd -D $PASSWD_FILE ${usernames[user_i]}
  docker exec -d $INSTANCE_NAME mosquitto_passwd -b $PASSWD_FILE ${usernames[user_i]} $new_password
  docker exec -d $INSTANCE_NAME kill -HUP 1
else
  echo "Please enter a valid option."
fi
exit 1
