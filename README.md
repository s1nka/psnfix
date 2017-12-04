# psnfix
Download PSN PKG from fixdat

# depend
linux, bash. wget, zip, grep, sed, mktemp, [trrntzip](https://sourceforge.net/projects/trrntzip/)

# usage
```
./fix_dl.sh -f <dat-file> -c -d -u
-f - dat-name
-d - download PKG-files (need wget)
-c - compress to torrentzip (need trrntzip)
-u - update TSV files
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

update nopaystation base(install in ~/tsv/):
```
./fix_dl.sh -u
```