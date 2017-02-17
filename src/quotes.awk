#!/bin/awk -f

NR==1{
  print
}

NR>1{
  s="";
  for(i=1;i<field;i++){
    s=s$i";";
  }
  s=s"\"";
  for(i=field;i<=NF;i++){
    s=s$i;
  }
  s=s$i;
  print s"\""
}
  
