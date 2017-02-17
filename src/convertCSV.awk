#!/usr/bin/awk -f

## Fixes the csv format problems in the DPI
NR==1{
  nbCols = NF;
  lastLine = $0;
}

NR>1{
  if(NF != nbCols || $1 !~ /[0-9]+/){
    lastLine = lastLine". "$0;
  }
  else{
    print(lastLine);
    lastLine = $0;
  }
}

END{
  print(lastLine);
}




