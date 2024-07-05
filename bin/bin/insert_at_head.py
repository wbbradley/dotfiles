import os, sys
from collections import OrderedDict

var_name = sys.argv[1]
existing_values = OrderedDict((s.strip(), None)
                              for s in sys.argv[2].split(":")
                              if s)
inserting_values = OrderedDict((s.strip(), None)
                               for s in sys.argv[3:]
                               if s)

new_values = []
for key, _ in inserting_values.items():
    new_values.append(key)
for key, _ in existing_values.items():
    if key not in inserting_values:
        new_values.append(key)

print(":".join(new_values), end="")
