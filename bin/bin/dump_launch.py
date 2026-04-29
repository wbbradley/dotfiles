#!/usr/bin/env python3
"""Read argv/envp/cwd of a running pid on Darwin and emit a launch script."""
import ctypes, ctypes.util, shlex, sys, subprocess

CTL_KERN = 1
KERN_ARGMAX = 8
KERN_PROCARGS2 = 49

libc = ctypes.CDLL(ctypes.util.find_library("c"), use_errno=True)

def sysctl(mib_vals, buf, buflen):
    mib = (ctypes.c_int * len(mib_vals))(*mib_vals)
    sz = ctypes.c_size_t(buflen)
    rc = libc.sysctl(mib, len(mib_vals), buf, ctypes.byref(sz), None, 0)
    if rc != 0:
        raise OSError(ctypes.get_errno())
    return sz.value

def get_argmax():
    out = ctypes.c_int(0)
    sysctl([CTL_KERN, KERN_ARGMAX], ctypes.byref(out), ctypes.sizeof(out))
    return out.value

def get_procargs2(pid):
    n = get_argmax()
    buf = (ctypes.c_char * n)()
    used = sysctl([CTL_KERN, KERN_PROCARGS2, pid], buf, n)
    return bytes(buf[:used])

def parse(raw):
    argc = int.from_bytes(raw[:4], "little")
    i = 4
    end = raw.index(b"\0", i)
    exec_path = raw[i:end].decode("utf-8", "replace")
    i = end
    while i < len(raw) and raw[i] == 0:
        i += 1
    argv = []
    for _ in range(argc):
        e = raw.index(b"\0", i)
        argv.append(raw[i:e].decode("utf-8", "replace"))
        i = e + 1
    envp = []
    while i < len(raw):
        try:
            e = raw.index(b"\0", i)
        except ValueError:
            break
        s = raw[i:e]
        i = e + 1
        if not s:
            break
        envp.append(s.decode("utf-8", "replace"))
    return exec_path, argv, envp

def get_cwd(pid):
    out = subprocess.check_output(
        ["lsof", "-a", "-p", str(pid), "-d", "cwd", "-Fn"]
    ).decode()
    for line in out.splitlines():
        if line.startswith("n"):
            return line[1:]
    raise RuntimeError("cwd not found")

def main():
    pid = int(sys.argv[1])
    exec_path, argv, envp = parse(get_procargs2(pid))
    cwd = get_cwd(pid)

    out = ["#!/usr/bin/env bash", "# Reproduces launch of pid %d" % pid,
           "set -e", "", "# Working directory"]
    out.append("cd %s" % shlex.quote(cwd))
    out += ["", "# Environment (clears the inherited env, then sets exactly what the original process had)"]
    out.append("env -i \\")
    for kv in envp:
        out.append("  %s \\" % shlex.quote(kv))
    out.append("  %s \\" % shlex.quote(exec_path))
    # argv[0] is preserved as-is; the kernel replaces it with exec_path, but we
    # emit argv unchanged since most programs don't care, and `env` would
    # otherwise lose the original argv[0]. Use a subshell with exec -a to keep argv[0].
    # Replace last line: use bash exec -a "<argv0>" "<exec_path>" <argv[1:]>
    out.pop()  # drop the bare exec_path line
    out.pop()  # drop the trailing 'env -i \\'... actually keep it
    # Rebuild cleanly:
    out = ["#!/usr/bin/env bash",
           "# Reproduces launch of pid %d" % pid,
           "set -e",
           "",
           "cd %s" % shlex.quote(cwd),
           "",
           'exec env -i \\']
    for kv in envp:
        out.append("  %s \\" % shlex.quote(kv))
    # Use bash -c to preserve argv[0] distinct from exec path.
    bash_script = 'exec -a "$0" "$1" "${@:2}"'
    inner = [argv[0], exec_path] + argv[1:]
    out.append("  /bin/bash -c %s \\" % shlex.quote(bash_script))
    for a in inner:
        out.append("    %s \\" % shlex.quote(a))
    # strip trailing backslash
    out[-1] = out[-1].rstrip(" \\")
    out.append("")
    sys.stdout.write("\n".join(out))

if __name__ == "__main__":
    main()
