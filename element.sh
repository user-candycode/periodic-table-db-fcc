#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only --no-align -c"

#Taking input from bash
INPUT=$1
#IF input is NAN
if [[ $INPUT ]]
  then
    #TRY TO MATCH DATA IN DB
    OUTPUT=-1
    if [[ $INPUT =~ ^[0-9]+ ]]
      then
        OUTPUT=$($PSQL "SELECT atomic_number from elements WHERE atomic_number=$INPUT")
      else
        WC=$(echo $INPUT | sed 's/^ *| *$//g' | wc -m )
        if [[ $WC -le 3 ]]
        then
          OUTPUT=$($PSQL "Select elements.atomic_number from elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE symbol='$INPUT' ORDER BY elements.atomic_number")
          else
            OUTPUT=$($PSQL "Select elements.atomic_number from elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE name='$INPUT' ORDER BY elements.atomic_number")
        fi
      
    fi

    #USING OUTPUT to GET DATA FROM DB
    FINAL_VALUES=$($PSQL "Select * from elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number=$OUTPUT ORDER BY elements.atomic_number")
    if [[ ! -z $FINAL_VALUES ]]
      then
        echo $FINAL_VALUES | while IFS='|' read TYPE ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE 
                    do 
                      #remolding the print statements
                      echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
                    done  
      else
        echo "I could not find that element in the database."      
    fi
  else
    #printing first statement
    echo "Please provide an element as an argument."
fi
