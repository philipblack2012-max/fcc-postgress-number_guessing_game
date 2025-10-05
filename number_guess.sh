#!/bin/bash
# number_guess.sh - step 1 skeleton

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Buscar usuario en la base

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  # Usuario nuevo: insertar en DB
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Usuario existente: obtener estadísticas
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generar número secreto entre 1 y 1000
SECRET=$(( RANDOM % 1000 + 1 ))

echo "Guess the secret number between 1 and 1000:"

GUESSES=0
while true
do
  read GUESS

  # Validar que sea un número entero
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((GUESSES++))

  if (( GUESS < SECRET ))
  then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET ))
  then
    echo "It's lower than that, guess again:"
  else
  echo "You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!"
  
  # Guardar el juego en la base de datos
  $PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)" > /dev/null
  break

  fi
done
