#pragma once

#include <stdbool.h>

/*
  Check if a wall of dimension k fits at coordinates x,y with the specified
  orientation.
*/
bool
wall_fits (const int n,
           const int room[n][n],
           const int x, const int y,
           const int k,
           const bool orientation);

/*
  Build a wall of dimension k at coordinates x,y with the specified
  orientation.
*/
void
wall_build (const int n,
            int room[n][n],
            const int x, const int y,
            const int k,
            const bool orientation);
