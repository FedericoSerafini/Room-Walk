#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>
#include <time.h>

bool
wall_fits (const int n,
           const int room[n][n],
           const int x, const int y, const int k,
           const bool orientation)
{

  if (x == 0 && y == 0)
    return false;

  if (orientation) // Horizontal orientation.
  {
    for (int j = 0; j < k; ++j)
      if (room[x][y +j] > 0)
        return false;
  }
  else // Vertical orientation.
  {
    for (int i = 0; i < k; ++i)
      if (room[x + i][y] > 0)
        return false;
  }

  return true;
}

void
wall_build (const int n,
            int room[n][n],
            const int x, const int y, const int k,
            const bool orientation)
{

  if (orientation) // Horizontal orientation.
  {
    for (int j = 0; j < k; ++j)
      room[x][y + j] = k;
  }
  else // Vertical orientation.
  {
    for (int i = 0; i < k; ++i)
      room[x + i][y] = k;
  }
}

int main (int argc, char **argv)
{
  if (argc != 4)
  {
    printf("Error: expected 3 input arguments (size, wall number, room instance)\n");
    return 0;
  }

  int n = atoi(argv[1]);
  int wall_number = atoi(argv[2]);
  int instance = atoi(argv[3]);
  int room[n][n];

  srand(n + wall_number + instance);

  printf("n = %d;\n\n", n);
  printf("w =\n");


  for (int i = 0; i < n; ++i)
    for (int j = 0; j < n; ++j)
      room[i][j] = 0;

  // Randomly select the initial wall orientation.
  bool orientation = false;

  if ((rand() / (double) INT_MAX) > 0.5)
    orientation = true;
  else
    orientation = false;

  int w = 0;
  int x, y = 0;

  while (w < wall_number)
  {
    int k = rand() % (n / 2) + 1;
    if (orientation) // Horizontal.
    {
      x = rand() % n; // Room starting row.
      y = rand() % (n - k); // Room starting column.
    }
    else // Vertical.
    {
      x = rand() % (n - k); // Room starting row.
      y = rand() % n; // Room starting column.
    }

    while (!wall_fits(n, room, x, y, k, orientation))
    {
      if (k > 1)
        --k;

      // Flip the orientation.
      orientation = !orientation;

      // Get new coordinates.
      if (orientation) // Horizontal.
      {
        x = rand() % n; // Room starting row.
        y = rand() % (n - k); // Room starting column.
      }
      else // Vertical.
      {
        x = rand() % (n - k); // Room starting row.
        y = rand() % n; // Room starting column.
      }
    }

    wall_build(n, room, x, y, k, orientation);
    orientation = !orientation;
    ++w;
  }

  for (int i = 0; i < n; ++i)
  {
    for (int j = 0; j < n; ++j)
    {
      if (i == 0 && j == 0)
        printf("[|");
      if (i != 0 && j == 0)
        printf(" |");
      printf("%d,", room[i][j]);
    }
    printf("\n");
  }
  printf(" |];\n\n");

  return 0;
}
