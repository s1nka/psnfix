#!/bin/bash

tsvdir="$HOME/tsv/"
database="$HOME/database"
downloadpkg=0
compresspkg=0
udpatetsv=0
getRAP=0
fixdat=""
trrntzip=""

function ShowHelp {
  echo "usage:"
  echo "./fix_dl.sh -f <dat-file> -c -d -u -r"
  echo "-f - dat-name"
  echo "-d - download PKG-files (need wget)"
  echo "-c - compress to torrentzip (need trrntzip)"
  echo "-u - update TSV files"
  echo "-r - get rap-files"
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
  dependtool="grep mktemp wget sed mktemp"
  for tool in $dependtool
  do
    if [ -z "$(which "$tool")" ]
    then
      echo -e "\033[31;1mError: failed to find $tool. Install it.\033[0m"
      exit
    fi
  done
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

  if [ "$(which trrntzip)" != "" ]
  then
    trrntzip="$(which trrntzip)"
  fi

  if [[ -z "$trrntzip" || "$(which zip)" = "" ]]
  then
    compresspkg=0
    echo -e "\033[31;1mError: failed find trrntzip or zip. Compress option was ignore\033[0m"
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
  rm "$tsvdir"/*.tsv
  wget https://nopaystation.com/tsv/ -q -O- | grep "\.tsv" | sed 's/\.tsv.*/\.tsv/' | sed 's/.*\"/https\:\/\/nopaystation\.com\/tsv\//' | wget -q -i - -P "$tsvdir"
}

function CheckTSV {
  if [ ! -d "$tsvdir" ]
  then
    UdpateTSV
  fi
}

function SetRAP {
  getRAP=1
}

echo fix-dat downloader by s1nka

CheckDepend

if [[ $# -lt 2 ]]
then
  ShowHelp
fi

while [ -n "$1" ]
do
  case "$1" in
    -f) SetFixDat "$2"
        shift;;
    -d) SetDownloadPKG ;;
    -c) SetCompressPKG ;;
    -u) UdpateTSV ;;
    -r) SetRAP ;;
     *) echo "$1 is not an option and ignore";;
  esac
  shift
done

if [ "$udpatetsv" -ne 0 ]
then
  UdpateTSV
fi

CheckTSV

if [ ! -n "$fixdat" ]
then
  echo "no fixdat, nothing scan"
  exit
fi

if [ "$compresspkg" -ne 0 ]
then
  CheckCompressPKG
fi

needlist=$(mktemp)
foolist=$(mktemp)
grep "rom name" "$fixdat" | grep -o "[0-9A-Za-z\_-]*\.pkg" > "$needlist"

for TSVfile in $tsvdir*.tsv
do
  echo "scan [$TSVfile]"
  while IFS= read -r URL
  do
    grep "$URL" "$TSVfile" | grep -o "http.*" | sed 's/\.pkg.*/\.pkg/' >> "$foolist"
  done < "$needlist"
done

if [ -f "$database" ]
then
  echo "scan [$database]"
  while IFS= read -r URL
  do
    grep "$URL" "$database" | grep -o "http.*" | sed -e 's/\;.*//' >> "$foolist"
  done < "$needlist"
else
  echo "please download 'database' from http://www.ps3hax.net/showthread.php?t=81538"
fi

rm "$needlist"

if [ "$getRAP" -ne 0 ]
then
  if [ -z "$(which xxd)" ]
  then
    echo -e "\033[31;1mError: failed to find xxd. Can't extract rap-files. Install it.\033[0m"
  else
    echo "get rap-files"
    raplist=$(mktemp)
    grep -o "[0-9A-Za-z\_.-]*rap" "$fixdat" > "$raplist"
    while IFS= read -r rapfile
    do
      raphex=$(grep -o "$rapfile;[0-9A-Z]*;" "$database" | grep -Eo "[0-9A-Z]{32}")
      echo "$raphex" | xxd -r -p > "$rapfile"
    done < "$raplist"
    rm "$raplist"
  fi
fi

if [ ! -s "$foolist" ]
then
  echo "no download found"
  rm "$foolist"
  exit
fi

urllist=$(mktemp)

sort -u > "$urllist" < "$foolist"

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
  for FILE in *.pkg
  do
    rm "$FILE.zip"
    zip "$FILE.zip" "$FILE"
    $trrntzip "$FILE.zip"
    rm "$FILE"
  done
  rm -- *.log
fi

rm "$urllist"
