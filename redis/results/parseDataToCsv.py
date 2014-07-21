#!/usr/bin/python

import sys;
import re;

if len(sys.argv) < 2:
  print "Usage: %s <filename>"
  sys.exit()

filename = sys.argv[1]

f = open(filename, 'r')

run = "?"
conn = "?"
experiment = "?"
rps = "?"

reCurses = re.compile(r'^.*\r')
reRunCon = re.compile(r'Run #([0-9]+): Connections ([0-9]+)')
reExpt   = re.compile(r'===== ([A-Z_]+) =====')
reRPS    = re.compile(r'([0-9.]+) requests per second')

for line in f:

  # Remove curses crazyness
  line = reCurses.sub("",line)

  # Strip out end-of-line
  line = line.replace("\n", "")

  # See if line contains "Run" and "Connection" number
  match = reRunCon.search(line)
  if match:
    run = match.group(1)
    conn = match.group(2)

  # See if line contains "Experiment" name
  match = reExpt.search(line)
  if match:
    experiment = match.group(1)

  # See if line contains "Requests per second" value
  match = reRPS.search(line)
  if match:
    rps = match.group(1)

    print "%s, %s, %s, %s, %s" % (filename, run, conn, experiment, rps)



f.close()

