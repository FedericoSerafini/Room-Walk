#!/bin/bash

# Compile.
gcc -g -Wall -Wextra -fsanitize=address room_gen.c -o room_gen

binary_walk="minizinc --solver Gecode --output-time -t 1200000 binary_room_walk.mzn"

max_size=18
instances=20

start=`date +%s`

# Create rooms with 2n walls.
for ((n=6; n<=max_size; n=n+2));
do
  for ((i=1; i<=instances; ++i));
  do
    echo 2nwalls: $n $i
    let x="2*n"
    ./room_gen $n $x $i > Rooms/2nwalls$n-$i.dzn;
    start_binary=`date +%s`
    $binary_walk Rooms/2nwalls$n-$i.dzn > Walks/2nwalls$n-$i.txt
    end_binary=`date +%s`
    if [ $((start_binary-end_binary)) -ge 1200 ]
    then
      echo "Warning: exceeded time limit"
      exit 1
    fi
  done
done

# Create rooms with n walls.
for ((n=6; n<=max_size; n=n+2));
do
  for ((i=1; i<=instances; ++i));
  do
    echo nwalls: $n $i
    ./room_gen $n $n $i > Rooms/nwalls$n-$i.dzn;
    start_binary=`date +%s`
    $binary_walk Rooms/nwalls$n-$i.dzn > Walks/nwalls$n-$i.txt
    end_binary=`date +%s`
    if [ $((end_binary-start_binary)) -ge 1200 ]
    then
      echo "Warning: exceeded time limit"
      exit 1
    fi
  done
done

end=`date +%s`
echo $((end-start))

python3 plot.py $max_size $instances
