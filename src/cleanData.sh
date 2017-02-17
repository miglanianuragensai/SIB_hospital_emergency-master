## IMPORTANT:
##   As usual, paths are relative to the root of the project and it is assumed you run this script from there.
##
## PRECONDITIONS:
##   - download all files from ownCloud and unzip it in /rawdata
##
## POSTCONDITIONS:
##   - Output files go into the directory /data
##   - Output files are in utf-8 text encoding
##   - Output files are valid csv files.

if [ -d "rawdata/ajout" ]; then
  mv rawdata/ajout/* rawdata/
  rmdir rawdata/ajout
fi

## Text Encoding to utf-8
if [ ! -d "rawdata/tmp" ]; then
  mkdir rawdata/tmp
fi

cp rawdata/* rawdata/tmp/
cd rawdata/tmp
for file in `dir -d *`; do
  if [[ `file -bi $file` =~ iso-8859-1 ]]; then 
    cp $file tmp
    iconv -f iso-8859-1 -t utf-8 tmp > $file
    rm tmp
  fi
done
## antecedents need to be done manually, because it is binary but really latin1
cp antecedents.csv tmp
iconv -f iso-8859-1 -t utf-8 tmp > antecedents.csv
rm tmp

cd ../..
## rearranging the csv files
## convertCSV is to merge lines created by a newline inside a field
## quotes puts double-quotes on the last field, specified by field=..
## Manually in vim %s/\r//g and %g/^$/d
awk -F';' -f src/convertCSV.awk rawdata/tmp/antecedents.csv > rawdata/tmp/antecedents2.csv
awk -F';' -f src/convertCSV.awk rawdata/tmp/motif_urgences.csv > rawdata/tmp/motifs_urgences2.csv

awk -F';' -v field=5 -f src/quotes.awk rawdata/tmp/antecedents2.csv > rawdata/tmp/antecedents3.csv
awk -F';' -v field=3 -f src/quotes.awk rawdata/tmp/motif_urgences2.csv > rawdata/tmp/motif_urgences3.csv

## For file urgences: manually modify names.
awk -F';' 'NR==1{print} NR>1{$4="";print $0}' rawdata/tmp/motif_urgences3.csv > motif_urgences4.csv
