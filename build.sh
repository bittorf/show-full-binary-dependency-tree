#!/bin/sh
# shellcheck shell=dash

ACTION="$1"	# helloworld, busybox, imagemagick, ...
		# show <ID>

[ -z "$ACTION" ] && {
	cat <<EOF
Usage: $0 <app1> <app2> <appN>

  e.g: $0 helloworld
       $0 busybox
       $0 imagemagick

       $0 "helloworld imagemagick busybox"
EOF
	exit 1
}


#### prepare build for CentOS8/Oracle8 linux:
# IMAGE="oraclelinux:8"
# docker image rm "$IMAGE" 2>/dev/null
# docker run -ti --security-opt seccomp=unconfined --rm "$IMAGE" || echo ERROR
#
#
#### imagemagick7 - see https://github.com/ImageMagick/ImageMagick
# [root@dfe306d00426 ~]# git clone https://github.com/ImageMagick/ImageMagick.git && cd ImageMagick
# [root@dfe306d00426 ImageMagick]# ./configure && make && make install


is()
{
	local word="$1"
	local obj

	for obj in $ACTION; do test "$obj" = "$word" && return 0; done
	false
}

showfiles()		# helper: list all files in docker images
{			# https://stackoverflow.com/questions/44769315/how-to-see-docker-image-contents/53481010#53481010
  local id="$1"

  docker create --name="tmp_$$" "$id" >/dev/null || { echo "[ERROR:$?] command: docker create $id"; docker images -a; return 1; }
  docker export --output "mytar_$$" "tmp_$$" || exit
  tar tvf "mytar_$$" | grep -v ^d | grep -v -- '-> /bin/busybox'
  rm -f "mytar_$$"
  docker rm "tmp_$$" >/dev/null
}

showdeps()		# helper: list all dependencies for a binary (shared libs)
{
  local binary="$1"	# e.g. './ssimulacra2 arg1 arg2' - maybe apply: export LC_ALL=C
  local line base

  list_file() {
    local bytes file="$1"
    test -h "$file" || file="$( readlink -f "$file" )"
    bytes="$( wc -c 2>/dev/null <"$file" )" || return 1

    # shellcheck disable=SC2012
    ls -l "$file" --time-style=long-iso | awk "{print \$1,sprintf(\"%10s\", \"$bytes\"),\$6,\$7,\$8,\$9,\$10}"
  }

  binary="$( command -v "$binary" )"	# e.g. 'busybox' => /usr/bin/busybox OR './busybox' => './busybox'
  base="$( basename -- "$binary" )"

  x()
  {
   list_file "$binary"
   {
    strace -f -t -e trace=file "$@" 2>&1 | \
      cut -d'"' -f2 | \
      while read -r line; do {
        test -f "$line" && list_file "$line"
      } done

    LC_ALL=C ldd "$binary" 2>&1 | while read -r line; do {
      # shellcheck disable=SC2086
      set -- $line

      case "$line" in
        *'not a dynamic executable'*) ;;
        *' => '*) test -f "$3" && list_file "$3" ;;
        *) test -f "$1" && list_file "$1" ;;
      esac
    } done
   } | sort -u -k5,5 | grep -v "$base" | grep -v "/etc/ld.so.cache" | grep -v '^/sys/'
  }

  x; echo && echo "list()	# deps for '$base' - generated with showdeps()" && echo "{"
  x | awk '{print $5}' | while read -r line; do {
    echo "	echo \"$line\""
  } done
  echo "}"
}

add_testimages()
{
	mkdir -p rootfs/data

	URL1="http://intercity-vpn.de/files/bitcoin-button.png"
	URL2="http://intercity-vpn.de/files/audacity-example-sox-fade.png"

	wget -qO rootfs/data/pic1.png "$URL1" || exit 1
	wget -qO rootfs/data/pic2.png "$URL2" || exit 1
}

copydocker()
{
	IMAGE="oraclelinux:8"
	for ID in $( docker ps | grep "$IMAGE" ); do break; done

	I=0
	for FILE in $( list ); do {
		I=$(( I + 1 ))
		DIR="$(   dirname -- "$FILE" )"
		BASE="$( basename -- "$FILE" )"

		test $I = 1 && DIR='bin'
		echo "# container $ID => '$FILE' => $DIR => $BASE"

		DEST="rootfs/$DIR"
		mkdir -p "$DEST"

		docker cp -L "$ID:$FILE" "$DEST/$BASE" || exit
	} done
}


is 'show' && {
	showfiles "$2"
	exit $?
}

rm -fR ./rootfs

is "busybox" && {		# brunocmorais/BusyboxDocker.sh
	mkdir -p rootfs/bin	# https://gist.github.com/brunocmorais/938cb52b68ff993b3b21bdaa568f83ef
	mkdir -p rootfs/root
	mkdir -p rootfs/etc

	echo >rootfs/etc/passwd "root:x:0:0:root:/root:/bin/sh"
	echo >rootfs/etc/group  "root:x:0:"

	[ -s busybox ] || wget https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
	chmod +x busybox

	cp -v busybox rootfs/bin
}

is "helloworld" && {
	list()     # deps for 'echo' - generated with showdeps()
	{
	      echo "/usr/bin/echo"
	      echo "/lib64/ld-linux-x86-64.so.2"
	      echo "/lib64/libc.so.6"
	}

	copydocker	# needs list()
}

is 'imagemagick' && {
	list()       # deps for 'magick' - generated with showdeps()
	{
	      echo "/usr/local/bin/magick"
	      echo "/lib64/ld-linux-x86-64.so.2"
	      echo "/lib64/libc.so.6"
	      echo "/lib64/libdl.so.2"
	      echo "/lib64/libgcc_s.so.1"
	      echo "/lib64/libgomp.so.1"
	      echo "/lib64/libjpeg.so.62"
	      echo "/lib64/libm.so.6"
	      echo "/lib64/libpthread.so.0"
	      echo "/lib64/libstdc++.so.6"
	      echo "/usr/local/etc/ImageMagick-7/log.xml"
	      echo "/usr/local/etc/ImageMagick-7/policy.xml"
	      echo "/usr/local/lib/libMagickCore-7.Q16HDRI.so.10"
	      echo "/usr/local/lib/libMagickWand-7.Q16HDRI.so.10"
	      echo "/usr/local/lib/liblcms2.so.2"
	      echo "/usr/local/lib/libpng16.so.16"
	      echo "/usr/local/lib/libz.so.1"
	      echo "/usr/local/share/ImageMagick-7/english.xml"
	      echo "/usr/local/share/ImageMagick-7/locale.xml"
	}

	copydocker 	# needs list()
	add_testimages
}

autocleanup()
{
  docker images -a | grep ^'<none>' | grep '[0-9] hours ago\|[0-9] minutes ago' | \
    awk '{print $3}' | \
      while read -r ID; do docker image rm "$ID" --force; done
}

generate_dockerfile()
{
	cat <<EOF
# syntax=docker/dockerfile:1
FROM scratch
COPY rootfs/ /

EOF
	is "helloworld" && cat <<EOF
CMD ["/bin/echo", "Hallo Welt..."]
EOF
	is "busybox" && cat <<EOF
COPY busybox /bin
RUN ["./bin/busybox", "--install", "-s", "/bin"]
CMD ["/bin/sh"]
EOF
}

echo
echo "# autocleanup"
autocleanup

echo
echo "# generating Dockerfile"
generate_dockerfile >Dockerfile
cat Dockerfile

echo
if docker build . -t hello; then
	echo
	echo "# generated docker image:"
	rm -fR ./rootfs Dockerfile
	docker images -a | head -n2
else
	cat Dockerfile
	exit 1
fi

echo
echo "# content of docker image:"
showfiles hello || exit

echo
echo '# now you can run:'
echo '# docker run -it hello'
