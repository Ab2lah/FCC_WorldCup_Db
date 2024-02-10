#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    # echo $YEAR $ROUND $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS

    # get winner_id and opponent_id
    WINNER_ID=$($PSQL "SELECT team_id from teams where name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id from teams where name = '$OPPONENT'")

    # if winner not found
    if [[ -z $WINNER_ID ]]
    then
      # insert winner 
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER');")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi  
    fi

    # if opponent not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert opponent
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT');")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi  
    fi
  fi
done

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    # get game_id
    WINNER_ID=$($PSQL "SELECT team_id from teams where name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id from teams where name = '$OPPONENT'")
    GAME_ID=$($PSQL "SELECT game_id from games where year=$YEAR and winner_id=$WINNER_ID and opponent_id=$OPPONENT_ID; ")

    # if game_id not found
    if [[ -z $GAME_ID ]]
    then
      # insert game 
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        GAME_ID=$($PSQL "SELECT game_id from games where year=$YEAR and winner_id=$WINNER_ID and opponent_id=$OPPONENT_ID; ")
        echo Inserted into games, $GAME_ID
      fi  
    fi
  fi
done
