%include "Rooms/nwalls16-8.dzn";

%%%% Variables and parameters. %%%%

int: n;                                                   % Room size.
int: pad_n = n + 2;                                       % Padded room size.
array [1..n, 1..n] of int: w;                             % Walls.
array [1..pad_n, 1..pad_n] of var 0..1: path;             % Path (decision variables).
%array [1..pad_n, 1..pad_n] of var 0..n^2-n: chrono_path; % Our path with addtional chronological info.
var 2*n-1..n^2-n: length;                                 % Path length.
var 1..n^2-n: turns;                                      % Path turns.
array [1..n-1, 1..n-1] of var 0..1: turn_counter;

%%%% Constraints. %%%%

% Entering point.
constraint path[2,2] = 1;
%constraint chrono_path[2, 2] = 1;

% Exit point.
constraint path[n+1, n+1] = 1;
%constraint chrono_path[n+1, n+1] = length;

% Pad first row.
constraint forall(j in 1..pad_n)(path[1,j] = 0);

% Pad first column.
constraint forall(i in 1..pad_n)(path[i,1] = 0);

% Pad last row.
constraint forall(j in 1..pad_n)(path[pad_n,j] = 0);

% Pad last column.
constraint forall(i in 1..pad_n)(path[i,pad_n] = 0);

% Avoid walls.
constraint forall(i, j in 1..n)
(
  (w[i,j] > 0) -> (path[i+1,j+1] = 0)
);

% Binary room walk.
constraint forall(i, j in 2..n+1)
(
  if(path[i, j] > 0) then
    % Enter and exit points of the path have just 1 neighbour.
    if ((i == 2 /\ j == 2) \/ (i == n+1 /\ j == n+1)) then
      path[i-1,j] + path[i,j-1] + path[i+1,j] + path[i,j+1] = 1
    else
      % Other points in the path have two neighbours.
      path[i-1,j] + path[i,j-1] + path[i+1,j] + path[i,j+1] = 2
    endif
  endif
);

% Length.
constraint sum(i,j in 2..n+1)(path[i, j]) = length;

% Turns count.
constraint forall(i,j in 2..n)
(
  if(path[i,j] + path[i,j+1] + path[i+1,j] + path[i+1,j+1] == 3) then
    turn_counter[i-1,j-1] = 1
  else
    turn_counter[i-1,j-1] = 0
  endif
);

constraint turns = sum(i, j in 1..n-1)(turn_counter[i, j]);

%%%% Additional constraints to help during search. %%%%

% Avoid squares: 
% 0 0 0 0
% 0 1 1 0
% 0 1 1 0
% 0 0 0 0
constraint forall(i, j in 2..n)
(
  path[i,j]   + path[i,j+1]   + 
  path[i+1,j] + path[i+1,j+1] <= 3
);

% Points not in the path (that are not walls) have at most 2 neighbours.
constraint forall(i, j in 2..n+1)
(
  if (path[i,j] == 0 /\ w[i-1,j-1] == 0) then
    path[i-1,j] + path[i,j-1] + path[i+1,j] + path[i,j+1] <= 2
  endif
);

%%%% Chrono walk. %%%%

% % Bind the path with the chrono_path.
% constraint forall(i, j in 1..pad_n)
% (
%   path[i, j] = 1 <-> chrono_path[i, j] > 0

% );

% % Chrono room walk.
% constraint forall(i, j in 2..n+1)
% (
%   if (chrono_path[i, j] > 0) then
%     if (i == 2 /\ j == 2) then
%       % One successor.
%       count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], chrono_path[i,j] +1, 1)
%       /\
%       count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], 0, 3)
%     else
%       if (i == n+1 /\ j == n+1) then
%         % One predecessor.
%         count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], chrono_path[i,j] -1, 1)
%         /\
%         count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], 0, 3)
%       else
%         % One predecessor.
%         count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], chrono_path[i,j] -1, 1)
%         /\
%         count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], chrono_path[i,j] +1, 1)
%         /\
%         count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], 0, 2)
%       endif
%     endif
%   endif
% );

%%%% Search strategy. %%%%

solve::
  int_search
  (
    path,
    dom_w_deg,
    indomain_min,
    complete
  )
  ::restart_geometric(n, 1)
  minimize length^2 + turns;

output [
         if fix(w[i, j]) > 0 then
          "W "
         else
          if fix(path[i+1, j+1] == 1) then
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
       [", turns: " ++ show(turns)]