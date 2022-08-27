import matplotlib.pyplot as plt
import sys

unsat_times = []
sat_times = []

solve_times_n = []
solve_times_2n = []

max_size = int(sys.argv[1]) +2
instances = int(sys.argv[2]) +1

for n in range(6, max_size, 2):
  unsat_t = 0.0
  sat_t = 0.0
  solve_n = 0.0
  solve_2n = 0.0
  for i in range(1, instances):
    for w in range(1, 3):
      if w == 1:
        filename = "nwalls" + str(n) + "-" + str(i)
      else:
        filename = "2nwalls" + str(n) + "-" + str(i)
      filename = "Walks/" + filename + ".txt"
      file = open(filename)
      lines = []
      for line in file:
        lines.append(line)

      if len(lines) == 2:

        if(float(lines[1].split(':')[1].split('s')[0]) > unsat_t):
          unsat_t = float(lines[1].split(':')[1].split('s')[0])

        if w == 1:
          if(float(lines[1].split(':')[1].split('s')[0]) > solve_n):
            solve_n = float(lines[1].split(':')[1].split('s')[0])
          else:
            if(float(lines[1].split(':')[1].split('s')[0]) > solve_2n):
              solve_2n = float(lines[1].split(':')[1].split('s')[0])
      else:
        if(float(lines[n+1].split(':')[1].split('s')[0]) > sat_t):
          sat_t = float(lines[len(lines)-1].split(':')[1].split('s')[0])

        if w == 1:
          if(float(lines[n+1].split(':')[1].split('s')[0]) > solve_n):
            solve_n = float(lines[len(lines)-1].split(':')[1].split('s')[0])
          else:
            if(float(lines[n+1].split(':')[1].split('s')[0]) > solve_2n):
              solve_2n = float(lines[len(lines)-1].split(':')[1].split('s')[0])

  sat_times.append(sat_t)
  unsat_times.append(unsat_t)

  solve_times_n.append(solve_n)
  solve_times_2n.append(solve_2n)

x = []
for i in range(6, max_size, 2):
  x.append(i)

# n and 2n walls.
#plt.title("n vs 2n walls")
plt.xlabel("Room size")
plt.ylabel("Max time (s)")
plt.plot(x, solve_times_n, label="n walls", marker='o')
plt.plot(x, solve_times_2n, label="2n walls", marker='o')
plt.yscale('log', base=2)
plt.axhline(y=300, color = 'orange', linestyle = '--', label='5 min threshold')
plt.axhline(y=600, color = 'violet', linestyle = '--', label='10 min threshold')
plt.legend(loc='center left')
plt.savefig('n-2n.png', dpi=300)
plt.clf()

# Sat/unsat time.
#plt.title("Sat vs unsat")
plt.xlabel("Room size")
plt.ylabel("Max time (s)")
plt.plot(x, sat_times, label='Sat', marker='o')
plt.plot(x, unsat_times, "-r", label='Unsat', marker='o')
plt.yscale('log', base=2)
plt.axhline(y=300, color = 'orange', linestyle = '--', label='5 min threshold')
plt.axhline(y=600, color = 'violet', linestyle = '--', label='10 min threshold')
plt.legend(loc='center left')
plt.savefig('sat-unsat.png', dpi=300)
