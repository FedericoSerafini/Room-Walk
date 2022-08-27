int: n;                                % Room size.
array [1..n, 1..n] of int: R;          % Room.
array [1..n+2, 1..n+2] of var 0..1: P; % Path (decision variables).

% Pad first row.
constraint forall(j in 1..n+2)(P[1,j] = 0);

% Pad first column.
constraint forall(i in 1..n+2)(P[i,1] = 0);

% Pad last row.
constraint forall(j in 1..n+2)(P[n+2,j] = 0);

% Pad last column.
constraint forall(i in 1..n+2)(P[i,n+2] = 0);

% % Enter and exit cells.
constraint P[2,2] = 1;
constraint P[n+1, n+1] = 1;

% Enter and exit cells have exactly one neighbor each.
constraint P[2,3] + P[3,2] = 1;
constraint P[n+1,n] + P[n,n+1] = 1;

% % Avoid walls.
constraint forall(i, j in 1..n)
(
  R[i,j] > 0 -> P[i+1,j+1] = 0
);

% Neighborhood for all the other cells.
constraint forall(i, j in 2..n+1)
(
  P[i, j] > 0 ->
  (
    not((i = 2 /\ j = 2) \/ (i = n+1 /\ j = n+1)) ->
      P[i-1,j] + P[i,j-1] + P[i+1,j] + P[i,j+1] = 2
  )
);

% Length.
var 2*n-1..n^2-n: length;                          % Path length.
constraint sum(i,j in 2..n+1)(P[i, j]) = length;

% Turns.
var 1..n^2-n: turns;                               % Path turns.
array [1..n-1, 1..n-1] of var 0..1: turn_counter;

constraint forall(i,j in 2..n)
(
  sum(s, t in 0..1)(P[i+s,j+t]) >= 3 <-> turn_counter[i-1,j-1] = 1
);

constraint turns = sum(i, j in 1..n-1)(turn_counter[i, j]);

%%%% Additional constraints to help during search. %%%%

% Avoid 2x2 loop.
constraint forall(i, j in 2..n)
(
  sum(s, t in 0..1)(P[i+s,j+t]) <= 3
);

% Avoid 3x3 loop.
constraint forall(i, j in 2..n+1)
(
  (P[i,j] = 0 /\ R[i-1,j-1] = 0) ->
    P[i-1,j] + P[i,j-1] + P[i+1,j] + P[i,j+1] <= 2
);

% Avoid 4x4 loop.
constraint forall(i, j in 2..n)
(
  sum(s, t in 0..1)(P[i+s,j+t] + R[i+s-1,j+t-1]) = 0 ->
    P[i-1,j] + P[i-1,j+1] +
    P[i,j+2] + P[i+1,j+2] +
    P[i+2,j] + P[i+2,j+1] +
    P[i,j-1] + P[i+1,j-1] <= 4
);

%%%% Search strategy. %%%%

solve
::
int_search(
  P,
  dom_w_deg,
  indomain_min
)::restart_geometric(n, 1)
minimize length^2 + turns;

output [
         if fix(R[i, j]) > 0 then
          "W "
         else
          if fix(P[i+1, j+1] == 1) then
            "1 "
          else
            ". "
          endif
         endif
         ++
         if j == n then
          "\n"
         else
          ""
         endif
         | i,j in 1..n
       ]
       ++
       ["Length: " ++ show(length)]
       ++
       [", turns: " ++ show(turns)];

%%%% Chrono walk. %%%%

% array [1..n+2, 1..n+2] of var 0..n^2-n: chrono_P; % Our P with addtional chronological info.

% constraint chrono_P[2, 2] = 1;

% constraint chrono_P[n+1, n+1] = length;

% % Pad first row.
% constraint forall(j in 1..n+2)(chrono_P[1,j] = 0);

% % Pad first column.
% constraint forall(i in 1..n+2)(chrono_P[i,1] = 0);

% % Pad last row.
% constraint forall(j in 1..n+2)(chrono_P[n+2,j] = 0);

% % Pad last column.
% constraint forall(i in 1..n+2)(chrono_P[i,n+2] = 0);

% % Avoid walls.
% constraint forall(i, j in 1..n)
% (
%   R[i,j] > 0 -> chrono_P[i+1,j+1] = 0
% );

% % Bind the P with the chrono_P.
% constraint forall(i, j in 1..n+2)
% (
%   P[i, j] = 1 <-> chrono_P[i, j] > 0
% );

% constraint chrono_P[2,3] + chrono_P[3,2] = 2;
% constraint chrono_P[n+1,n] + chrono_P[n,n+1] = chrono_P[n+1,n+1]-1;

% % Chrono room walk.
% constraint forall(i, j in 2..n+1)
% (
%   if (P[i, j] > 0) then
%     if (not((i == 2 /\ j == 2) \/ (i == n+1 /\ j == n+1))) then
%       count([chrono_P[i,j+1], chrono_P[i+1,j], chrono_P[i,j-1], chrono_P[i-1,j]], chrono_P[i,j] -1, 1)
% %       /\
% %       count([chrono_P[i,j+1], chrono_P[i+1,j], chrono_P[i,j-1], chrono_P[i-1,j]], chrono_P[i,j] +1, 1)
% %       /\
% %       count([chrono_P[i,j+1], chrono_P[i+1,j], chrono_P[i,j-1], chrono_P[i-1,j]], 0, 2)
%     endif
%   endif
% );
