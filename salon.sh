#! /bin/bash

# initialization, define function
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU () {
  # Print 1st argument if given
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi
  # Show services list
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES_LIST" | while read SID BAR SERVICE_NAME
  do
    echo "$SID) $SERVICE_NAME"
  done

  # go to select_service
  SELECT_SERVICE
}

SELECT_SERVICE () {
  # get service id from user
  read SERVICE_ID_SELECTED

  # check if service_id_selected is valid
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    # if service_id_selected is not a number, then show list again
    MAIN_MENU "I could not find that service. What would you like today?"
  else  
    # check if service_id_selected exist
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'" | sed -E 's/^ //g')
    # echo "$SERVICE_NAME"

    if [[ -z $SERVICE_NAME ]]; then
      # if service_id_selected is a number but outside of list, then show list again
      MAIN_MENU "I could not find that service. What would you like today?"
    else :
      # break from loop
    fi
  fi
}

INSERT_NEW_CUSTOMER () {
  # query to insert
  INSERT_CUST_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
}

CREATE_APPOINTMENT () {
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^ +| +$//g')
  
  # insert to appointments table
  INSERT_APT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # print message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
}

# ------------------- Main Program Starts Here
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU

# get customer's phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# query for customer name by phone
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^ +| +$//g')

if [[ -z $CUSTOMER_NAME ]]; then
  # if not exist in customers table, then ask for new customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  INSERT_NEW_CUSTOMER
fi

# ask for service time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

CREATE_APPOINTMENT