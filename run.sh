#!/bin/bash

# Compile.
gcc -g -Wall -Wextra -fsanitize=address room_gen.c -o room_gen

minizinc="minizinc --solver Gecode -s -t 300000 binary_room_walk.mzn"

start=`date +%s`

# Create rooms with 2n walls.
for n in {6..20..2}
do
  for i in {1..5..1}
  do
    echo 2nwall: $n $i
    let x="2*n"
    ./room_gen $n $x $i > Rooms/2nwall$n-$i.dzn;
    startlocal=`date +%s`
    $minizinc Rooms/2nwall$n-$i.dzn > Walks/2nwall$n-$i.txt
    endlocal=`date +%s`
    if [ $((endlocal-startlocal)) -ge 299 ]
    then
      echo "exceeded time limit"
    fi
  done
done

# Create rooms with n walls.
for n in {6..20..2}
do
  for i in {1..5..1}
  do
    echo nwall: $n $i
    ./room_gen $n $n $i > Rooms/nwall$n-$i.dzn;
    startlocal=`date +%s`
    $minizinc Rooms/nwall$n-$i.dzn > Walks/nwall$n-$i.txt
    endlocal=`date +%s`
    if [ $((endlocal-startlocal)) -ge 299 ]
    then
      echo "exceeded time limit"
    fi
  done
done

end=`date +%s`
echo $((end-start))
