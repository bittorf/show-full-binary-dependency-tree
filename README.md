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

list()       # all 3 deps for 'true' - generated with showdeps()
{
      echo "/usr/bin/true"
      echo "/lib64/ld-linux-x86-64.so.2"
      echo "/usr/lib/x86_64-linux-gnu/libc.so.6"
}
```

example output (more complex, a python program):
------------------------------------------------

```
$ cat test.py 
#!/usr/bin/env python
print('Hello, world!')

$ LC_ALL=C ./showdeps.sh ./test.py
# running: strace --follow-forks -e trace=file ./test.py
#     and: LC_ALL=C ldd './test.py'

-rwxrwxr-x         45 2024-11-02 16:36 /home/user/test.py  
lrwxrwxrwx     174176 2024-10-27 17:58 /lib/x86_64-linux-gnu/libexpat.so.1 -> libexpat.so.1.9.3
lrwxrwxrwx     125376 2024-10-29 11:32 /lib/x86_64-linux-gnu/libz.so.1 -> libz.so.1.3.1
lrwxrwxrwx    8078272 2023-06-13 12:17 /usr/bin/python -> python3
lrwxrwxrwx    8078272 2024-09-16 17:21 /usr/bin/python3 -> python3.12
-rwxr-xr-x    8078272 2024-09-07 16:20 /usr/bin/python3.12  
-rw-r--r--        300 2024-09-13 21:36 /usr/lib/python3.12/__pycache__/sitecustomize.cpython-312.pyc  
-rw-r--r--      14945 2024-09-13 21:36 /usr/lib/python3.12/__pycache__/types.cpython-312.pyc  
-rw-r--r--      23818 2024-09-13 21:36 /usr/lib/python3.12/__pycache__/warnings.cpython-312.pyc  
-rw-r--r--       5884 2024-09-07 16:20 /usr/lib/python3.12/encodings/__init__.py  
-rw-r--r--       5775 2024-09-13 21:36 /usr/lib/python3.12/encodings/__pycache__/__init__.cpython-312.pyc  
-rw-r--r--      12408 2024-09-13 21:36 /usr/lib/python3.12/encodings/__pycache__/aliases.cpython-312.pyc  
-rw-r--r--       2147 2024-09-13 21:36 /usr/lib/python3.12/encodings/__pycache__/utf_8.cpython-312.pyc  
-rw-r--r--       6745 2024-09-13 21:36 /usr/lib/python3.12/encodings/__pycache__/utf_8_sig.cpython-312.pyc  
-rw-r--r--      15677 2024-09-07 16:20 /usr/lib/python3.12/encodings/aliases.py  
-rw-r--r--       1005 2024-09-07 16:20 /usr/lib/python3.12/encodings/utf_8.py  
-rw-r--r--       4133 2024-09-07 16:20 /usr/lib/python3.12/encodings/utf_8_sig.py  
-rw-r--r--       4774 2024-09-07 16:20 /usr/lib/python3.12/importlib/__init__.py  
-rw-r--r--       4555 2024-09-13 21:36 /usr/lib/python3.12/importlib/__pycache__/__init__.cpython-312.pyc  
-rw-r--r--       1643 2024-09-13 21:36 /usr/lib/python3.12/importlib/__pycache__/_abc.cpython-312.pyc  
-rw-r--r--       1354 2024-09-07 16:20 /usr/lib/python3.12/importlib/_abc.py  
-rw-r--r--      40777 2024-09-07 16:20 /usr/lib/python3.12/os.py  
-rw-r--r--      10993 2024-09-07 16:20 /usr/lib/python3.12/types.py  
-rw-r--r--      21902 2024-09-07 16:20 /usr/lib/python3.12/warnings.py  
-rw-r--r--       6715 2024-07-09 18:07 /usr/lib/python3/dist-packages/_distutils_hack/__init__.py  
-rw-r--r--      10469 2024-07-30 18:01 /usr/lib/python3/dist-packages/_distutils_hack/__pycache__/__init__.cpython-312.pyc  
-rw-r--r--        151 2024-07-13 10:20 /usr/lib/python3/dist-packages/distutils-precedence.pth  
-rw-r--r--        544 2024-04-07 17:20 /usr/lib/python3/dist-packages/logilab_common-2.0.0-nspkg.pth  
-rwxr-xr-x    2003408 2024-09-24 21:46 /usr/lib/x86_64-linux-gnu/libc.so.6  
-rw-r--r--     936152 2024-09-24 21:46 /usr/lib/x86_64-linux-gnu/libm.so.6  

list()       # all 28 deps for 'test.py' - generated with showdeps()
{
    echo "/home/user/test.py"
    echo "/lib/x86_64-linux-gnu/libexpat.so.1"
    echo "/lib/x86_64-linux-gnu/libz.so.1"
    echo "/usr/bin/python"
    echo "/usr/lib/python3.12/__pycache__/sitecustomize.cpython-312.pyc"
    echo "/usr/lib/python3.12/__pycache__/types.cpython-312.pyc"
    echo "/usr/lib/python3.12/__pycache__/warnings.cpython-312.pyc"
    echo "/usr/lib/python3.12/encodings/__init__.py"
    echo "/usr/lib/python3.12/encodings/__pycache__/__init__.cpython-312.pyc"
    echo "/usr/lib/python3.12/encodings/__pycache__/aliases.cpython-312.pyc"
    echo "/usr/lib/python3.12/encodings/__pycache__/utf_8.cpython-312.pyc"
    echo "/usr/lib/python3.12/encodings/__pycache__/utf_8_sig.cpython-312.pyc"
    echo "/usr/lib/python3.12/encodings/aliases.py"
    echo "/usr/lib/python3.12/encodings/utf_8.py"
    echo "/usr/lib/python3.12/encodings/utf_8_sig.py"
    echo "/usr/lib/python3.12/importlib/__init__.py"
    echo "/usr/lib/python3.12/importlib/__pycache__/__init__.cpython-312.pyc"
    echo "/usr/lib/python3.12/importlib/__pycache__/_abc.cpython-312.pyc"
    echo "/usr/lib/python3.12/importlib/_abc.py"
    echo "/usr/lib/python3.12/os.py"
    echo "/usr/lib/python3.12/types.py"
    echo "/usr/lib/python3.12/warnings.py"
    echo "/usr/lib/python3/dist-packages/_distutils_hack/__init__.py"
    echo "/usr/lib/python3/dist-packages/_distutils_hack/__pycache__/__init__.cpython-312.pyc"
    echo "/usr/lib/python3/dist-packages/distutils-precedence.pth"
    echo "/usr/lib/python3/dist-packages/logilab_common-2.0.0-nspkg.pth"
    echo "/usr/lib/x86_64-linux-gnu/libc.so.6"
    echo "/usr/lib/x86_64-linux-gnu/libm.so.6"
}
```

build a minimal docker container from scratch:
----------------------------------------------

this does not make much sense, busybox is only included,  
so that one can walk around and watch from inside the container:

```
$ sudo ./build.sh "helloworld busybox"

# generating Dockerfile:
# syntax=docker/dockerfile:1
FROM scratch
COPY rootfs/ /
CMD ["/bin/echo", "Hallo Welt..."]
COPY busybox /bin
RUN ["./bin/busybox", "--install", "-s", "/bin"]
CMD ["/bin/sh"]

# generated docker image:
REPOSITORY                    TAG       IMAGE ID       CREATED                  SIZE
hello                         latest    f376832aed33   Less than a second ago   5.52MB

# content of docker image:
-rwxr-xr-x 0/0               0 2024-11-05 21:50 .dockerenv
-rwxrwxr-x 0/0         1131168 2022-01-17 19:53 bin/busybox
-rwxr-xr-x 0/0           38240 2022-10-04 18:19 bin/echo
-rwxr-xr-x 0/0               0 2024-11-05 21:50 dev/console
-rw-r--r-- 0/0              10 2024-11-05 21:50 etc/group
-rwxr-xr-x 0/0               0 2024-11-05 21:50 etc/hostname
-rwxr-xr-x 0/0               0 2024-11-05 21:50 etc/hosts
lrwxrwxrwx 0/0               0 2024-11-05 21:50 etc/mtab -> /proc/mounts
-rw-r--r-- 0/0              30 2024-11-05 21:50 etc/passwd
-rwxr-xr-x 0/0               0 2024-11-05 21:50 etc/resolv.conf
-rwxr-xr-x 0/0         1122408 2022-09-30 07:43 lib64/ld-linux-x86-64.so.2
-rwxr-xr-x 0/0         2093744 2022-09-30 07:43 lib64/libc.so.6

# now you can run:
# docker run -it hello
```
