#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdbool.h>

bool
room_fits (const int n,
           const int room[n][n],
           const int x, const int y, const int k,
           const bool orientation)
{
  //printf("Room_fits\n");

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
room_build (const int n,
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
  for (int n = 6; n < 16; n +=  2)
  {
    int room[n][n];
    char filename[256];
    snprintf(filename, sizeof(filename), "nwalls%d.txt", n);
    FILE *fp = fopen(filename, "w");

    if (NULL != fp)
    {
      // Generate 5 rooms with n Rooms each.
      for (int r = 0; r < 5; ++r)
      {
        for (int i = 0; i < n; ++i)
          for (int j = 0; j < n; ++j)
            room[i][j] = 0;

        printf("n: %d, r: %d\n", n, r);
        bool orientation = false;
        int wall_count = 0;
        int x, y = 0;

        while (wall_count < n)
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

          while (!room_fits(n, room, x, y, k, orientation))
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

            for(int a = 0; a < n; ++a)
            {
              for(int b = 0; b < n; ++b)
                printf("%d, ", room[a][b]);
              printf("\n");
            }

            printf("k: %d, x: %d, y: %d\n", k, x, y);

          }

          room_build(n, room, x, y, k, orientation);
          orientation = !orientation;
          ++wall_count;
        }

        for (int i = 0; i < n; ++i)
        {
          for (int j = 0; j < n; ++j)
            fprintf(fp, "%d,", room[i][j]);
          fprintf(fp, "\n");
        }

        fprintf(fp, "\n");
      }

      fclose(fp);
    }
    else
    {
      printf("Cant open file\n");
      return 0;
    }

  }
}