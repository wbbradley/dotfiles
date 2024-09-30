#!/usr/bin/env python3
import sys
from subprocess import check_output
from datetime import datetime, timezone
try:
    ts = float(check_output('pbpaste').strip().decode('ascii'))
    dt = datetime.fromtimestamp(ts, timezone.utc).astimezone()
    print(dt.strftime('Clipped: %Y-%m-%d %l:%M:%S %p %Z'))
except Exception:
    pass
