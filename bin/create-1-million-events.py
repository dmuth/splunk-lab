#!/usr/bin/env python3
#
# Create 1 million events with the current timestamp and drop them into the current directory.
#


from datetime import datetime
from datetime import timezone 


num = 1000000
filename = "1-million-events.txt"
f = open(filename, "w")

print(f"Writing {num} fake events to file '{filename}'...")

for x in range(num):
	now = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3]

	line = (f"{now} Test event {x}/{num}\n")
	#print(line) # Debugging
	f.write(line)
	
f.close()

print("Done!")


