#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?" 
  
  SERVICES=$($PSQL "select service_id, name from services order by service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    MENU "I could not find that service. What would you like today?"
  else
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed 's/ //g')
    MAKE_APPOINTMENT "$SERVICE_ID_SELECTED" "$SERVICE_NAME_FORMATTED"
  fi
}

MAKE_APPOINTMENT(){
  SERVICE_ID_SEL=$1
  SERVICE_NAME_SEL=$2

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //g')

  echo -e "\nWhat time would you like your $SERVICE_NAME_SEL, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

 
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SEL, '$SERVICE_TIME')")

  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME_SEL at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

MENU