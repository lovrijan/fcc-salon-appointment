#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~\n"

echo "Welcome to My Salon, how can I help you?"

SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")


CREATE_APPOINTMENT(){
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'");
    CUST_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'");
    CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'");
    SERVICE_NAME_FORMAT=$(echo $SERVICE_NAME | sed -E 's/\s//g');
    CUST_NAME_FORMAT=$(echo $CUST_NAME | sed -E 's/\s//g');
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMAT, $CUST_NAME_FORMAT?"
    read SERVICE_TIME
    INSERT_TIME=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUST_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMAT at $SERVICE_TIME, $CUST_NAME_FORMAT."
}

MAIN_MENU(){
  # Phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  HAVE_CUSTOMER=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'");

  if [[ -z $HAVE_CUSTOMER ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE')");
    CREATE_APPOINTMENT
    else

    CREATE_APPOINTMENT
  fi
}

LIST_SERVICES(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  # If input not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    LIST_SERVICES "I could not find that service. What would you like today?"
  else
    HAVE_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'");

    # If service option doesn't exist
    if [[ -z $HAVE_SERVICE ]]
    then
      LIST_SERVICES "I could not find that service. What would you like today?"
    else
      MAIN_MENU
    fi
  fi
}
LIST_SERVICES