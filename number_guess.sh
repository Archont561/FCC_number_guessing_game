#!/bin/bash

echo "Enter your username:"
read USERNAME
while [[ "${#USERNAME}" -gt 22 ]]
do
  echo "Username should have no more than 22 characters"
  echo "Enter your username:"
  read USERNAME
done

# querying for rrecord
PSQL="psql --username=postgres --dbname=number_guess -t --no-align -c"
ROW=$($PSQL "SELECT username, COUNT(guess), MIN(trials) FROM user_scores WHERE username='$USERNAME' GROUP BY username")

if ! [[  -z "$ROW" ]]; then
  # Extracting information from the row
  USERNAME=$(echo "$ROW" | awk -F'|' '{print $1}')
  GAMES_PLAYED=$(echo "$ROW" | awk -F'|' '{print $2}')
  BEST_GAME=$(echo "$ROW" | awk -F'|' '{print $3}')
  
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi 

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
NUMBER_OF_GUESSES=1
echo "Guess the secret number between 1 and 1000:"
read GUESS
while [[ "$GUESS" -ne "$RANDOM_NUMBER" ]]
do
  (( NUMBER_OF_GUESSES++ ))
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
  else
    if (( $GUESS > $RANDOM_NUMBER )); then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi

  read GUESS
done


END=$($PSQL "INSERT INTO user_scores (username, guess, trials) VALUES ('$USERNAME', $RANDOM_NUMBER, $NUMBER_OF_GUESSES)")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
