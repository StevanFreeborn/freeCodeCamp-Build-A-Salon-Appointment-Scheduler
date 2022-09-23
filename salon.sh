#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
SERVICE_ERROR="That is not a valid service. Please select one of the services listed below.\n"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "$SERVICE_ERROR"
  else
    VALID_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    
    if [[ -z $VALID_SERVICE ]]
    then
      MAIN_MENU "$SERVICE_ERROR"
    else
      MAKE_APPOINTMENT "$VALID_SERVICE"
    fi
  fi
}

MAKE_APPOINTMENT() {
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER ]]
  then
    echo -e "\nI could not find an existing customer with that phone number. What is your name?"
    read CUSTOMER_NAME

    $PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
    CUSTOMER=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  read SERVICE_ID BAR SERVICE_NAME <<< $1
  read CUSTOMER_ID BAR CUSTOMER_NAME <<< $CUSTOMER
  
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

  if [[ $APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo -e "\nI am sorry $CUSTOMER_NAME. I was unable to book you an appointment for a $SERVICE_NAME at $SERVICE_TIME."
  fi
}

MAIN_MENU