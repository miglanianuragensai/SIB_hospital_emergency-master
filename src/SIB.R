dpi_patients = read.csv("ensai_data\\patients.csv",sep = ";")
dpi_allergies = read.csv("ensai_data\\allergies.csv",sep = ";")
dpi_antecedents = read.csv("ensai_data\\antecedents2.csv",sep = ";")
dpi_examens = read.csv("ensai_data\\examens_ipp_sans_cle.csv",sep = ";")
dpi_imc = read.csv("ensai_data\\imc.csv",sep = ";")
dpi_motifs_urgences = read.csv("ensai_data\\motif_urgences_ipp_sans_cle.csv",sep = ";")
length(unique(dpi_motifs_urgences$DAD_C_IEP_CLE))
dpi_motifs_hosp = read.csv("ensai_data\\motif_hospit_ipp_sans_cle.csv",sep = ";")
dpi_poids = read.csv("ensai_data\\poids.csv",sep = ";")
dpi_taille = read.csv("ensai_data\\taille.csv",sep = ";")
dpi_urgences = read.csv("ensai_data\\urgences.csv",sep = ";")

pmsi_diag_associes = read.csv("ensai_data\\diagnostics_ass.csv", sep = ";")
pmsi_sejour = read.csv("ensai_data\\sejours_pmsi.csv", sep = ";")
pmsi_actes = read.csv("ensai_data\\actes_pmsi.csv", sep = ";")
pmsi_diag_relies = read.csv("ensai_data\\diagnostic_relies_pmsi.csv", sep = ";")

### Frame de d'association IPP-IEP-RSS

IPP_IEP_RSS = data.frame(pmsi_sejour["PAT_C_IPP_CLE"], pmsi_sejour[,"DAD_C_IEP_CLE"], pmsi_sejour[,"RSS_C_IDE"])
colnames(IPP_IEP_RSS) = c('IPP','IEP','RSS')
IPP_IEP_RSS = unique(IPP_IEP_RSS)

converter = function(from, to, value){
   return(IPP_IEP_RSS[which(IPP_IEP_RSS[, paste(from)] == value), paste(to)])
}
converter("RSS","IEP",16266)

### RSS_C_IDE of the people having an escarre ###

# Returns indixes of the x vector which matches one value in y
matching = function(x,y){
   return(which(x%in%y))
}
matching(c(1,2,3,4,5,6),c(2,4,6,8)) # lequel des x est dans y? le 2, 4, et 6 eme.
matching(c(2,4,6,8),c(1,2,3,4,5,6))

# Returns indixes of the x vector which DOESNT matches any value in y
not_matching = function(x,y){
   return(which(!x%in%y)) # lequel des x N'est PAS dans y? le 4 eme.
}
not_matching(c(1,2,3,4,5,6),c(2,4,6,8))
not_matching(c(2,4,6,8),c(1,2,3,4,5,6))

# More Complex matching function: 
# all_included : all x are in y ? 
# indexes_of_those_present_in_both: which x are in y?
# indexes_of_those_NOT_present_in_both: which x are NOT in y?
# proportion_de_linclusion: what the proportion of the guy in y who are in y?
all_included = function(x,y){
   indexes_of_those_present_in_both = matching(x,y)
   return(list( all_included = sum(x%in%y) == length(x),
                indexes_of_those_present_in_both = matching(x,y),
                indexes_of_those_NOT_present_in_both = not_matching(x,y),
                proportion_de_linclusion = length(matching(unique(x),y)) / length(unique(x))
   ))
}

# Indexes of the guy havin an escarre in diag_associe
escarre_indexes = matching(pmsi_diag_associes[,"DAS_C_DIAG"], c("L890", "L891","L892","L893","L899","L89"))
# RSS of the patient with escarre
RSS_C_IDE_with_escarre = unique(pmsi_diag_associes[escarre_indexes, "RSS_C_IDE"])

# Creation of the column corresponding to the escarre class
y_escarre = rep(0, dim(pmsi_sejour)[1]) 
RSS_indexes_with_escarres = matching(pmsi_sejour$RSS_C_IDE, RSS_C_IDE_with_escarre)
y_escarre[RSS_indexes_with_escarres] = 1
pmsi_sejour$y_escarre = y_escarre
#

output = data.frame(pmsi_sejour$PAT_C_IPP_CLE, 
                    pmsi_sejour$DAD_C_IEP_CLE, 
                    pmsi_sejour$RSS_C_IDE, 
                    pmsi_sejour$y_escarre, 
                    pmsi_sejour$RUM_N_DUREE_PMSI,
                    pmsi_sejour$RUM_D_ENTREE,
                    pmsi_sejour$RUM_D_SORTIE)
colnames(output) = c("IPP","IEP","RSS","Y_escarre","Y_duree")

# export 
write.csv(output, file = "output.csv")
i = 2
tro = aggregate(Y_duree~IPP + IEP + RSS + Y_escarre, FUN = "sum", data = output)

inx = c()
k = 1
for (i in sort(output$IEP)){
   
   if(i == sort(output$IEP)[k + 1]){
      inx[length(inx) +1] = i
   }
   k = k + 1
}

length(pmsi_sejour$DAD_C_IEP_CLE)
length(unique(pmsi_sejour$DAD_C_IEP_CLE))
length(output$IPP)
length(unique(output$IPP))
length(pmsi_sejour$RSS_C_IDE)
length(unique(pmsi_sejour$RSS_C_IDE))

# probleme!!
pmsi_sejour[which(pmsi_sejour$DAD_C_IEP_CLE == 402075611),]


all_included(pmsi_diag_associes[,"RSS_C_IDE"], pmsi_sejour[,"RSS_C_IDE"])
# FALSE patients de pmsi diag associe ne sont pas dans sejour !

# RSS des enregistrement dans pmsi diag associe et PAS dans pmsi sejour 

#en particulier, ceux avec escarre sont il tous dans sejour ?
all_included(RSS_C_IDE_with_escarre, pmsi_sejour[,"RSS_C_IDE"]) #RSS_C_IDE_with_escarre%in%pmsi_sejour[,"RSS_C_IDE"]

# A retirer :
not_matching(RSS_C_IDE_with_escarre, pmsi_sejour[,"RSS_C_IDE"])
# RSS_C_IDE_with_escarre[- not_matching(RSS_C_IDE_with_escarre, pmsi_sejour[,"RSS_C_IDE"])]
RSS_C_IDE_with_escarre_cleaned = RSS_C_IDE_with_escarre[- not_matching(RSS_C_IDE_with_escarre, pmsi_sejour[,"RSS_C_IDE"])]
length(RSS_C_IDE_with_escarre_cleaned)
# On en a retirer une dizaine!

ipp_sans_clef = trunc(dpi_patients$PAT_C_IPP/10)


IPP_patients = dpi_patients[,1]
all_included(dpi_allergies[,1], IPP_patients)

all_included(dpi_allergies[,1], IPP_patients)
# allergies : TRUE

all_included(dpi_antecedents[,1], ipp_sans_clef)
# antecedants: FALSE

all_included(dpi_examens[,1], ipp_sans_clef)
# examens: FALSE

all_included(dpi_imc[,1], IPP_patients)
# imc:TRUE

all_included(IPP_patients, dpi_imc[,1])
# 0.095
length(unique(dpi_imc[,1]))
# 21254 imc

all_included(dpi_motifs_hosp[,1], IPP_patients)
# motif host FALSE

all_included(dpi_motifs_urgences[,1], ipp_sans_clef)
all_included(dpi_motifs_urgences[,1], dpi_urgences[,2])

all_included(dpi_motifs_urgences[,1], dpi_urgences[,2])
all_included(dpi_urgences[,2], dpi_motifs_urgences[,1])

all_included(dpi_poids[,1], IPP_patients)
# poids TRUE
all_included(IPP_patients, dpi_poids[,1])

all_included(dpi_taille[,1], IPP_patients)
all_included(IPP_patients, dpi_taille[,1])
# taille TRUE

all_included(dpi_urgences[,1], IPP_patients)
# TRUE 

all_included(dpi_motifs_urgences[,1], dpi_urgences[,2])
# Il y a des gens qui ont des motifs urgences et qui ne sont pas dans urgence !! 
all_included(dpi_urgences[,2], dpi_motifs_urgences[,1])

all_included(IPP_patients, pmsi_sejour[,1])
all_included(pmsi_sejour[,1], IPP_patients)

all_included(pmsi_actes[,1], pmsi_sejour[,7])
all_included(pmsi_sejour[,7], pmsi_actes[,1])

all_included(pmsi_diag_associes[,2], pmsi_actes[,1])
all_included(pmsi_sejour[,7], pmsi_diag_relies[,1])
all_included(pmsi_diag_associes[,2], pmsi_sejour[,7])


x = all_included(trunc(pmsi_sejour$PAT_C_IPP_CLE/10), pmsi_sejour$RSS_C_IDE)
IPP_present_in_both = pmsi_sejour$PAT_C_IPP_CLE[x$indexes_of_those_present_in_both]
head(sort(IPP_present_in_both), 100)

RSS = pmsi_sejour$RSS_C_IDE
IPP = pmsi_sejour$PAT_C_IPP_CLE
IPP_sc = trunc(pmsi_sejour$PAT_C_IPP_CLE/10)


x = all_included(IPP_sc,RSS)
IPP_also_a_RSS = IPP[x$indexes_of_those_present_in_both]
IPP_sc_also_RSS = trunc(IPP_also_a_RSS/10)

which(RSS == IPP_sc_also_RSS)
RSS[which(RSS == 119517)]   
pmsi_sejour$PAT_C_IPP_CLE[which(pmsi_sejour$RSS_C_IDE == 119517)]

all_included(IPP_IEP_RSS$RSS, IPP_IEP_RSS$IPP)
all_included(IPP_IEP_RSS$IEP, IPP_IEP_RSS$RSS)
