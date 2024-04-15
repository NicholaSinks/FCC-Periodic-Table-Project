#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --quiet --no-align -c "

echo -e "\n" > .error

GET_DATA () {
  INPUT=$1
  NAME_VALUE=$($PSQL "SELECT * FROM elements WHERE name='$INPUT'" 2>> .error) 
  CHECK_NAME_RESULT=$(echo $?)
  NUMBER_VALUE=$($PSQL "SELECT * FROM elements WHERE atomic_number=$INPUT" 2>> .error)
  CHECK_NUMBER_RESULT=$(echo $?)
  SYMBOL_VALUE=$($PSQL "SELECT * FROM elements WHERE symbol='$INPUT'" 2>> .error)
  CHECK_SYMBOL_RESULT=$(echo $?)


  TRUE_RESULT=""
  if [ $CHECK_NAME_RESULT == 0 ] && [[ -n $NAME_VALUE ]]
  then
    TRUE_RESULT=$NAME_VALUE
  elif [ $CHECK_NUMBER_RESULT == 0 ] && [[ -n $NUMBER_VALUE ]]
  then
    TRUE_RESULT=$NUMBER_VALUE
  elif [ $CHECK_SYMBOL_RESULT == 0 ] && [[ -n $SYMBOL_VALUE ]]
  then
    TRUE_RESULT=$SYMBOL_VALUE
  else
    echo "I could not find that element in the database."
    return
  fi

  echo "$TRUE_RESULT" | while IFS="|" read -r NUMBER SYMBOL NAME
  do
    MORE=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number=$NUMBER")
    echo "$MORE" | while IFS="|" read -r MASS MELTING BOILING TYPE_ID
    do
      TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
      echo -e "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  done
  
}


if [[ -n $1 ]]
then
  GET_DATA $1
else
  echo "Please provide an element as an argument."
fi