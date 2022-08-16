include "Data/nwalls20.dzn";
include "globals.mzn";

%%%% Variables and parameters. %%%%

int: n = 20;                                       % Room size.
int: pad_n = n + 2;                                % Padded room size.
array [1..n, 1..n] of int: w;                      % Walls.
array [1..pad_n, 1..pad_n] of var 0..1: pad_path;  % Padded path (decision variables).
var 2*n-1..n^2-n: length;                          % Length of the path.
array [1..n-1, 1..n-1] of var 0..1: turns;         % Turns.

%%%% Constraints. %%%%

% Compute the path lenght.
constraint length = sum(i, j in 1..pad_n)(pad_path[i,j]);

constraint pad_path[2,2] = 1;     % Entering point.
constraint pad_path[n+1,n+1] = 1; % Exit point.

% Pad first row.
constraint forall(j in 1..pad_n)(pad_path[1,j] = 0);

% Pad first column.
constraint forall(i in 1..pad_n)(pad_path[i,1] = 0);

% Pad last row.
constraint forall(j in 1..pad_n)(pad_path[pad_n,j] = 0);

% Pad last column.
constraint forall(i in 1..pad_n)(pad_path[i,pad_n] = 0);

% Avoid walls.
constraint forall(i, j in 1..n)
(
   (w[i,j] > 0) -> (pad_path[i+1,j+1] = 0)
);

% Room walk.
constraint forall(i, j in 2..n+1)
(
  if(pad_path[i, j] > 0) then
    % Enter and exit points.
    if((i == 2 /\ j == 2) \/ (i == n+1 /\ j == n+1)) then
      pad_path[i-1, j] + pad_path[i, j-1] + pad_path[i+1, j] + pad_path[i, j+1] = 1
    else
      pad_path[i-1, j] + pad_path[i, j-1] + pad_path[i+1, j] + pad_path[i, j+1] = 2
    endif
  endif
);

% Avoid square loop around:
% the room-walk constraint alone allows things like that:
% 0 0 0 0
% 0 1 1 0
% 0 1 1 0
% 0 0 0 0
constraint forall(i, j in 2..n)
(
  pad_path[i,   j] + pad_path[i,   j+1]   +
  pad_path[i+1, j] + pad_path[i+1, j+1]   <= 3
);

% Counting turns.
constraint forall(i, j in 2..n)
(
  if(pad_path[i, j] + pad_path[i, j+1] + pad_path[i+1, j] + pad_path[i+1, j+1] == 3) then
    turns[i-1, j-1] = 1
  else
    turns[i-1, j-1] = 0
  endif
);

%%%% Redundant constraints helping the search procedure. %%%%

% The sum of each row must be greater than 0.
constraint forall(j in 2..n+1)
(
  sum(i in 2..n+1)(pad_path[i,j]) > 0
);

% The sum of each column must be greater than 0.
constraint forall(i in 2..n+1)
(
  sum(j in 2..n+1)(pad_path[i,j]) > 0
);

%%%% Search strategy. %%%%

solve::int_search
(
  pad_path,
  dom_w_deg,
  indomain_min,
  complete
)

minimize length + sum(i, j in 1..n-1)(turns[i, j]);

output [
         if fix(w[i,j]) > 0 then
          "W "
         else
          if fix(pad_path[i+1,j+1] == 1) then
            "1 "
          else
            ". "
          endif
         endif
         ++
         if j == n then "\n"
         else ""
         endif
         | i,j in 1..n
        ]
         ++ ["Length: " ++ show(length)]
         ++ [", Turns: " ++ show(sum(i, j in 1..n-1)(turns[i, j]))]