import numpy as np
import pandas as pd
from pandas import DataFrame, Series
from datetime import datetime
import dateutil
from collections import defaultdict  
import sys
import os
from nltk.corpus import stopwords
from nltk import download as nltkdownload
from nltk.tokenize import word_tokenize


sejour = pd.read_csv("data/sejours_pmsi.csv", delimiter = ';')
acte = pd.read_csv("data/actes_pmsi.csv", delimiter = ';')
diag = pd.read_csv("data/diagnostics_ass.csv", delimiter = ';')
allergie = pd.read_csv("data/allergies.csv", delimiter = ';')
antecedent = pd.read_csv("data/antecedents.csv", delimiter = ';')
examen = pd.read_csv("data/examens_ipp_sans_cle.csv", delimiter = ';')
imc = pd.read_csv("data/imc.csv", delimiter = ';')
motifHosp = pd.read_csv("data/motif_hospit_ipp_sans_cle.csv", delimiter = ';')
motifUrg = pd.read_csv("data/motif_urgences.csv", delimiter = ';')
patient = pd.read_csv("data/patients.csv", delimiter = ';')
poid = pd.read_csv("data/poids.csv", delimiter = ';')
taille = pd.read_csv("data/taille.csv", delimiter = ';')
urgence = pd.read_csv("data/urgences.csv", delimiter = ';')

output = pd.read_csv("data/output.csv", delimiter = ',')
del output['Unnamed: 0']

df = output.copy()
df['IEP'] = [int(x/10) if not np.isnan(x) else 0 for x in df['IEP']]

## sejour
newCols = ["ipp", "iep", "gender", "dob", "residence", "res", "rss", "um", "entryDate", "entryMode", "from", "exitDate", "exitMode", "destination","stayLength", "diagnostic"]
sejour.columns = newCols
ipp = [int(x/10) for x in sejour.ix[:,0]]
iep = [int(x/10) if not np.isnan(x) and x is not 0 else 0 for x in sejour.ix[:,1]]
sejour['ipp'] = ipp
sejour['iep'] = iep
sejour['dob'] = [dateutil.parser.parse(x) for x in sejour['dob']]
sejour['entryDate'] = [dateutil.parser.parse(x) for x in sejour['entryDate']]
sejour['exitDate'] = [dateutil.parser.parse(x) for x in sejour['exitDate']]

## acte
newCols = ['rss', 'res', 'act', 'phase', 'activity', 'date']
acte.columns = newCols
acte['date'] = [dateutil.parser.parse(x) for x in acte['date']]
## there are rss missing, but the res are there.

## diag
newCols = ["res", "rss", "diagnostic", "cma"]
diag.columns = newCols


## allergie: all type are given. Especially important is the type médicamenteuse. Could take only that as a variable. Date is unimportant really for this one. Allergy has many labels (rr 5), family and severity are mostly missing. Equally important is the number of allergies variable.  
newCols = ["ipp", "allergy", "type", "family", "severity", "date"]
allergie.columns = newCols
ipp = [int(x/10]) for x in allergie.ix[:,0]]
allergie['ipp'] = ipp
allergie['date'] = [dateutil.parser.parse(x) for x in allergie['date']]

del allergie['date']
del allergie['severity']
del allergie['family']

df['nbAllergies'] = 0
tmpDict = defaultdict(int)
for ipp in allergie.ipp:
    tmpDict[ipp] += 1

for x in df.index:
    df.loc[x,'nbAllergies'] = tmpDict[df.IPP[x]]
    

## antecedent
newCols = ['ipp', 'diagnostic', 'type', 'date', 'comment']
antecedent.columns = newCols

## examen
newCols = ["ipp", "iep", "v1", "v2", "v3", "v4", "v5"]
examen.columns = newCols

## imc
newCols = ["ipp", "value", "date"]
imc.columns = newCols
ipp = [int(str(x)[:-1]) for x in imc.ix[:,0]]
imc["ipp"] = ipp
imc['date'] = [dateutil.parser.parse(x) for x in imc['date']]

## motifHosp
newCols

## motifUrg
newCols = ['ipp', 'iep', 'motif']
motifUrg.columns = newCols


## Joining the pmsi files to get Y


## Joining the dpi files to get X

lld = sorted(df['IEP'])
llm = sorted(motifUrg['iep'])
result = []
x,y=0,0
lx, ly = len(lld), len(llm)
while x<lx and y<ly:
    if lld[x] < llm[y]:
        x += 1
    elif llm[y] < lld[x]:
        y += 1
    else:
        result.append(motifUrg[motifUrg['iep'] == llm[y]].motif.values[0])
        x += 1

badwords = stopwords.words('french')
with open('data/out/words', 'w') as f:
    for s in result:
        tokens = word_tokenize(s)
        goodwords = [x for x in tokens if x not in badwords]
        for w in goodwords:
            f.writeline(w)

