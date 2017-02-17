################# Just checking the matches between keys
namesPMSI = ["acte", "diag"]
namesDPI = ["allergie", "antecedent", "examen", "imc", "motifHosp", "motifUrg", "patient", "poid", "taille", "urgence"]

## Need to check the types. Eg column 3 should be datetime.

## Want to compute the dictionary of ids to documents.
# locals()[name] returns the value of the variable named name (string).
keyStrPMSI = "RSS_C_IDE"
keyStrDPI = "PAT_C_IPP"
dictPMSI = defaultdict(lambda: defaultdict(int))
dictDPI = defaultdict(lambda: defaultdict(int))
for k in sejour[keyStrPMSI]:
    dictPMSI[k]["sejour"] +=1

for x in namesPMSI:
    print("Reading file "+ x + ": ", file=sys.stderr)
    for k in locals()[x][keyStrPMSI]:
        if k in dictPMSI.keys():
            dictPMSI[k][x] += 1
        else:
            dictPMSI["NA"][x] += 1

c=0
for k in dictPMSI:
    if dictPMSI[k]["acte"] is 0 or dictPMSI[k]["diag"] is 0:
        c += 1

print(c)

for x in namesDPI:
    print("Reading file "+ x + ": ", file=sys.stderr)
    for k in locals()[x][keyStrDPI]:
        dictDPI[k][x] += 1

