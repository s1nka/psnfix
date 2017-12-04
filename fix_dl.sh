#!/bin/bash

tsvdir="$HOME/tsv/"
database="$HOME/database"
downloadpkg=0
compresspkg=0
udpatetsv=0
fixdat=""
trrntzip=""

function ShowHelp {
  echo "usage:"
  echo "./fix_dl.sh -d <dat-file> -c -d -s"
  echo "-f - dat-name"
  echo "-d - download PKG-files (need wget)"
  echo "-c - compress to torrentzip (need trrntzip)"
  echo "-u - update TSV files"
}

function SetFixDat {
  fixdat=$*
  if [ ! -r "$fixdat" ]
  then
    echo -e "\033[31;1mError: failed get fix-dat file [$fixdat]\033[0m"
    ShowHelp
    exit
  fi
  echo "process [$fixdat] file"
}

function CheckDepend {
  if [ -z "`which grep`" ]
  then
    echo -e "\033[31;1mError: failed to find grep. Install it.\033[0m"
    exit
  fi
  if [ -z "`which mktemp`" ]
  then
    echo -e "\033[31;1mError: failed to find mktemp. Install it.\033[0m"
    exit
  fi
  if [ -z "`which wget`" ]
  then
    echo -e "\033[31;1mError: failed to find wget. Install it.\033[0m"
    exit
  fi
  if [ -z "`which sed`" ]
  then
    echo -e "\033[31;1mError: failed to find sed. Install it.\033[0m"
    exit
  fi
}

function SetDownloadPKG {
  downloadpkg=1
}

function SetCompressPKG {
  compresspkg=1
}

function CheckCompressPKG {
  if [[ "$downloadpkg" -eq 0 && "$compresspkg" -eq 1 ]]
  then
    echo -e "\033[31;1mError: use only with option -d\033[0m"
    ShowHelp
    exit
  fi

  if [ -f "./trrntzip" ]
  then
    trrntzip="./trrntzip"
  fi

  if [ "`which trrntzip`" != "" ]
  then
    trrntzip="`which trrntzip`"
  fi

  if [ -z "$trrntzip" ]
  then
    compresspkg=0
    echo -e "\033[31;1mError: failed find trrntzip and compress option was ignore\033[0m"
    return
  fi

  echo "using [$trrntzip] for compress"
}

function SetUpdateTSV {
  udpatetsv=1
}

function UdpateTSV {
  echo start update TSV-file
  mkdir -p "$tsvdir"
  rm $tsvdir/*.tsv
  curl https://nopaystation.com/ -s | grep ".tsv" | sed 's/\.tsv.*/\.tsv/' | sed 's/.*\"/https\:\/\/nopaystation\.com\//' | wget -q -i - -P "$tsvdir"
}

function CheckTSV {
  if [ ! -d "$tsvdir" ]
  then
    UdpateTSV
  fi
}

echo fix-dat downloader by s1nka

CheckDepend

if [[ $# < 2 ]]
then
  ShowHelp
fi

while [ -n "$1" ]
do
  case "$1" in
    -f) SetFixDat $2
        shift;;
    -d) SetDownloadPKG ;;
    -c) SetCompressPKG ;;
    -u) UdpateTSV ;;
     *) echo "$1 is not an option and ignore";;
  esac
  shift
done

if [ "$udpatetsv" -ne 0 ]
then
  UdpateTSV
fi

CheckTSV

if [ -n "$fixdat"]
then
  echo "no fixdat, nothing scan"
  exit
fi

needlist=`mktemp`
foolist=`mktemp`
grep "rom name" "$fixdat" | grep -o "[0-9A-Za-z\_-]*\.pkg" > $needlist

for TSVfile in $tsvdir*.tsv
do
  echo "scan [$TSVfile]"
  for URL in `cat $needlist`
  do
    grep $URL $TSVfile | grep -o "http.*" | sed 's/\.pkg.*/\.pkg/' >> "$foolist"
  done
done

if [ -f "$database" ]
then
  echo "scan ["$database"]"
  for URL in `cat $needlist`
  do
    grep $URL "$database" | grep -o "http.*" | sed -e 's/\;.*//' >> "$foolist"
  done
else
  echo "please download 'database' from http://www.ps3hax.net/showthread.php?t=81538"
fi

rm "$needlist"

if [ ! -s "$foolist" ]
then
  echo "no download found"
  rm "$foolist"
  exit
fi

urllist=`mktemp`

cat "$foolist" | sort -u > "$urllist"

rm "$foolist"

if [ "$downloadpkg" -eq 0 ]
then
  echo "url to download:"
  cat "$urllist"
else
  echo "start download"
  wget -c -i "$urllist"
fi

if [ "$compresspkg" -ne 0 ]
then
  CheckCompressPKG
fi

if [ "$compresspkg" -ne 0 ]
then
  for FILE in *.pkg
  do
    rm "$FILE.zip"
    zip "$FILE.zip" "$FILE"
    $trrntzip "$FILE.zip"
    rm "$FILE"
  done
  rm *.log
fi

rm "$urllist"