include "Data/2nwalls6.dzn";
include "globals.mzn";

int: n = 6; % Room size.
int: pad_n = n + 2; % Padded room size.
array [1..n, 1..n] of int: w; % Walls.
array [1..n, 1..n] of var 0..1: path;
array [1..pad_n, 1..pad_n] of var 0..1: pad_path; % Our path (decision variables).
var 2*n..(n+1)*(n): length;

% Bind the padded path with a the normal path.
constraint forall(i, j in 1..n)(pad_path[i+1,j+1] = path[i,j]);

constraint length = sum(i, j in 1..pad_n)(pad_path[i,j]);

constraint pad_path[2,2] = 1;     % Entering point.
constraint pad_path[n+1,n+1] > 0; % Exit point.

% Do not step over walls.
constraint forall(i, j in 1..n)
(
  (pad_path[i+1,j+1] > 0) -> (w[i,j] = 0)
);

% Pad first row.
constraint sum(j in 1..pad_n)(pad_path[1,j]) = 0;

% Pad first column.
constraint sum(i in 1..pad_n)(pad_path[i,1]) = 0;

% Pad last row.
constraint sum(j in 1..pad_n)(pad_path[pad_n,j]) = 0;

% Pad last column.
constraint sum(i in 1..pad_n)(pad_path[i,pad_n]) = 0;

% Room walk.
constraint forall(i, j in 2..n+1)
(
  if(pad_path[i, j] > 0) then
    if(not ((i == 2 /\ j == 2) \/ (i == n+1 /\ j == n+1))) then
      pad_path[i-1, j] + pad_path[i, j-1] + pad_path[i+1, j] + pad_path[i, j+1] = 2
    else
      pad_path[i-1, j] + pad_path[i, j-1] + pad_path[i+1, j] + pad_path[i, j+1] >= 1
    endif
  endif
);

% constraint alldifferent_except_0(path);

% Row sum.
constraint forall(i in 2..n+1)
(
  sum(j in 2..n+1)(pad_path[i,j]) > 0
);

% Column sum.
constraint forall(j in 2..n+1)
(
  sum(i in 2..n+1)(pad_path[i,j]) > 0
);

solve minimize length;

% [|0,1,0,0,0,0
%  |0,1,0,0,1,0
%  |0,1,1,1,1,0
%  |0,1,1,1,1,0
%  |0,1,0,0,1,0
%  |0,0,0,0,1,0
%  |]