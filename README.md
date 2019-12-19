# psnfix
Download PSN PKG from fixdat

# depend
linux, bash, wget, zip, grep, sed, mktemp, xxd, [trrntzip](https://sourceforge.net/projects/trrntzip/)

# base
please download [database](https://psndl.net/download-db) and put in $HOME

# usage
```
./fix_dl.sh -f <dat-file> -c -d -u -r
-f - dat-name
-d - download PKG-files (need wget)
-c - compress to torrentzip (need trrntzip)
-u - update TSV and database files (need wget)
-r - get rap-files (need xxd)
```

# example
show urls:
```
./fix_dl.sh -f "fix_Sony - PlayStation Portable (PSN) (Encrypted) (20171202-061552).dat"
```

download pkgs:
```
./fix_dl.sh -f "fix_Sony - PlayStation Portable (PSN) (Encrypted) (20171202-061552).dat" -d
```

download and compress pkgs:
```
./fix_dl.sh -f "fix_Sony - PlayStation Portable (PSN) (Encrypted) (20171202-061552).dat" -d -c
```

update nopaystation base(install in ~/tsv/) and database from psndl.net(install in ~/):
```
./fix_dl.sh -u
```
