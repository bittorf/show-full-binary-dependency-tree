show _full_ dependency tree for any binary:
-------------------------------------------

```
Usage: ./showdeps.sh <binary> <arg1> <argN>

 e.g.: ./showdeps.sh /usr/bin/ls -l
```

example output:
---------------

```
$ LC_ALL=C ./showdeps.sh /bin/true --foo
# running: strace --follow-forks -e trace=file /bin/true --foo
#     and: LC_ALL=C ldd '/bin/true'

-rwxr-xr-x      35664 2024-03-09 18:42 /usr/bin/true
lrwxrwxrwx     222968 2024-09-24 21:46 /lib64/ld-linux-x86-64.so.2 -> ../lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
-rwxr-xr-x    2003408 2024-09-24 21:46 /usr/lib/x86_64-linux-gnu/libc.so.6

list()       # deps for 'true' - generated with showdeps()
{
      echo "/usr/bin/true"
      echo "/lib64/ld-linux-x86-64.so.2"
      echo "/usr/lib/x86_64-linux-gnu/libc.so.6"
}
```
