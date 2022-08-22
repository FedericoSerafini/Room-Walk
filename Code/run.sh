#!/bin/bash

# Compile.
gcc -g -Wall -Wextra -fsanitize=address room_gen.c -o room_gen

minizinc="minizinc --solver Gecode --output-time -t 600000 binary_room_walk.mzn"

start=`date +%s`

# Create rooms with 2n walls.
for n in {6..16..2}
do
  for i in {1..10..1}
  do
    echo 2nwalls: $n $i
    let x="2*n"
    ./room_gen $n $x $i > Rooms/2nwalls$n-$i.dzn;
    startWalk=`date +%s`
    $minizinc Rooms/2nwalls$n-$i.dzn > Walks/2nwalls$n-$i.txt
    endWalk=`date +%s`
    if [ $((endWalk-startWalk)) -ge 600 ]
    then
      echo "Warning: exceeded time limit"
      exit 1
    fi
  done
done

# Create rooms with n walls.
for n in {6..16..2}
do
  for i in {1..10..1}
  do
    echo nwalls: $n $i
    ./room_gen $n $n $i > Rooms/nwalls$n-$i.dzn;
    startWalk=`date +%s`
    $minizinc Rooms/nwalls$n-$i.dzn > Walks/nwalls$n-$i.txt
    endWalk=`date +%s`
    if [ $((endWalk-startWalk)) -ge 600 ]
    then
      echo "Warning: exceeded time limit"
      exit 1
    fi
  done
done

end=`date +%s`
echo $((end-start))

python3 plot.py
