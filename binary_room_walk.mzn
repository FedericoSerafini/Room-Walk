include "Rooms/2nwall22-3.dzn";

%%%% Variables and parameters. %%%%

int: n;                                                  % Room size.
int: pad_n = n + 2;                                      % Padded room size.
array [1..n, 1..n] of int: w;                            % Walls.
array [1..pad_n, 1..pad_n] of var 0..1: path;            % Path (decision variables).
array [1..pad_n, 1..pad_n] of var 0..n^2-n: chrono_path; % Our path with addtional chronological info.
%var 2*n-1..n*n-n: length;                                % Path length.
array [1..n-1, 1..n-1] of var 0..1: turns;               % Path turns.

%%%% Constraints. %%%%

% constraint length = sum(i, j in 1..pad_n)(path[i,j]);

% Entering point.
constraint path[2,2] = 1;
constraint chrono_path[2, 2] = 1;

% Exit point.
constraint path[n+1, n+1] = 1;
constraint chrono_path[n+1, n+1] = sum(i,j in 2..n+1)(path[i, j]); % length.

% Pad first row.
constraint forall(j in 1..pad_n)(path[1,j] = 0);

% Pad first column.
constraint forall(i in 1..pad_n)(path[i,1] = 0);

% Pad last row.
constraint forall(j in 1..pad_n)(path[pad_n,j] = 0);

% Pad last column.
constraint forall(i in 1..pad_n)(path[i,pad_n] = 0);

% Bind the path with the chrono_path.
constraint forall(i, j in 1..pad_n)
(
  (path[i, j] = 0 <-> chrono_path[i, j] = 0)
  /\
  (path[i, j] = 1 <-> chrono_path[i, j] > 0)
);

% Avoid walls.
constraint forall(i, j in 1..n)
(
   (w[i,j] > 0) -> (path[i+1,j+1] = 0)
);

% Room walk.
constraint forall(i, j in 2..n+1)
(
  if(path[i, j] > 0) then
    % For enter and exit points just one neighbour.
    if((i == 2 /\ j == 2) \/ (i == n+1 /\ j == n+1)) then
     path[i-1, j] + path[i, j-1] + path[i+1, j] + path[i, j+1] = 1
     %count([path[i-1, j], path[i, j-1], path[i+1, j], path[i, j+1]], 0, 3)
    else
      % Two neighbours.
      path[i-1, j] + path[i, j-1] + path[i+1, j] + path[i, j+1] = 2
      %count([path[i-1, j], path[i, j-1], path[i+1, j], path[i, j+1]], 0, 2)
    endif
  endif
);

% % Chrono walk.
% Room walk.
constraint forall(i, j in 2..n+1)
(
  if (chrono_path[i, j] > 0) then
    if (i == 2 /\ j == 2) then
      % One successor.
      count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], chrono_path[i,j] +1, 1)
      /\
      count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], 0, 3)
    else
      if (i == n+1 /\ j == n+1) then
        % One predecessor.
        count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], chrono_path[i,j] -1, 1)
        /\
        count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], 0, 3)
      else
        % One predecessor.
        count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], chrono_path[i,j] -1, 1)
        /\
        count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], chrono_path[i,j] +1, 1)
        /\
        count([chrono_path[i,j+1], chrono_path[i+1,j], chrono_path[i,j-1], chrono_path[i-1,j]], 0, 2)      
      endif
    endif      
  endif
);

% Turns count.
constraint forall(i, j in 2..n)
(
  %if(path[i, j] + path[i, j+1] + path[i+1, j] + path[i+1, j+1] == 3) then
  if(count([path[i, j], path[i, j+1], path[i+1, j], path[i+1, j+1]], 0, 1)) then
    turns[i-1, j-1] = 1
  else
    turns[i-1, j-1] = 0
  endif
);

%%%% Redundant constraints helping the search procedure. %%%%

% The sum of each row must be greater than 0.
constraint forall(j in 2..n+1)
(
  sum(i in 2..n+1)(path[i,j]) > 0
);

% The sum of each column must be greater than 0.
constraint forall(i in 2..n+1)
(
  sum(j in 2..n+1)(path[i,j]) > 0
);

% Turn bounds.
%constraint sum(i, j in 1..n-1)(turns[i, j]) <= sum(i, j in 2..n+1)(path[i, j]) - 2;
constraint sum(i, j in 1..n-1)(turns[i, j]) >= 1;

%%%% Search strategy. %%%%

solve
  ::int_search
  (
    path,
    first_fail,
    indomain_min,
    complete
  )
  %::restart_geometric(n, 1)
  minimize sum(i, j in 1..n-1)(turns[i, j]);
  %satisfy;

output [
         if fix(w[i,j]) > 0 then
          "W "
         else
          if fix(path[i+1,j+1] == 1) then
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
        ++
        ["Length: " ++ show(sum(i,j in 2..n+1)(path[i, j]))]
        ++
        [", turns: " ++ show(sum(i, j in 1..n-1)(turns[i, j]))]
        ++
        [", free variables: " ++ show(n*n - sum(i, j in 1..n)(w[i, j]))]