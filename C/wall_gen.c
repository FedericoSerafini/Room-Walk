#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdbool.h>

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

int main ()
{
  for (int f = 0; f < 2; ++f)
  {
    for (int n = 6; n < 16; n +=  2)
    {
      int room[n][n];
      char filename[256];

      if (f == 0)
        snprintf(filename, sizeof(filename), "../Data/nwalls%d.dzn", n);
      else
        snprintf(filename, sizeof(filename), "../Data/2nwalls%d.dzn", n);

      FILE *fp = fopen(filename, "w");

      if (NULL != fp)
      {
        fprintf(fp, "array [1..%d, 1..%d] of int: w;\n\n", n, n);
        fprintf(fp, "w =\n");

        // Generate 5 rooms with n Rooms each.
        for (int r = 0; r < 5; ++r)
        {
          for (int i = 0; i < n; ++i)
            for (int j = 0; j < n; ++j)
              room[i][j] = 0;

          bool orientation = false;
          int w = 0;
          int x, y = 0;
          int wall_number;

          if (f == 0)
            wall_number = n;
          else
            wall_number = 2*n;

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

              orientation = !orientation;

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
                fprintf(fp, "%%[\n");

              if (j == 0)
                fprintf(fp, "%%|");

              fprintf(fp, "%d,", room[i][j]);
            }
            fprintf(fp, "\n");
          }

          fprintf(fp, "%%|];\n\n");
        }

        // Try also without walls.
        for (int i = 0; i < n; ++i)
        {
          for (int j = 0; j < n; ++j)
          {
            if (i == 0 && j == 0)
              fprintf(fp, "%%[\n");
            if (j == 0)
              fprintf(fp, "%%|");

            fprintf(fp, "0,");
          }

          fprintf(fp, "\n");
        }

        fprintf(fp, "%%|];\n\n");
        fclose(fp);
      }
      else
        printf("Cant open file \"%s\"\n", filename);
      }
  }

  return 0;
}
