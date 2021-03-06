## This script is used only to prepare the combined and transformed datasets to be used during analyses

######################
#### Oral Data L8 ####
######################

source("microbiome_functions.R")

data <- read.table("Oral/roos-oral-dada2_table-L8.tsv", sep = "\t", skip=-2)
oral <- as.data.frame(t(data))
oral <- oral %>% slice(1:168)
oral <-  data.frame(apply(droplevels(oral),2,as.numeric),check.names = FALSE)

# Extract sample IDs
names <- colnames(data)
sampleID <- unlist(sapply(strsplit(names,split = "Opti."),"[",-1))
rownames(oral) <- sampleID

# Extract taxonomy table
tax <- data.frame(cbind(
  Kingdom = sapply(strsplit(as.character(data$Taxon),split = "; "),"[",1),
  Phylum = sapply(strsplit(as.character(data$Taxon),split = "; "),"[",2),
  Class = sapply(strsplit(as.character(data$Taxon),split = "; "),"[",3),
  Order = sapply(strsplit(as.character(data$Taxon),split = "; "),"[",4),
  Family = sapply(strsplit(as.character(data$Taxon),split = "; "),"[",5),
  Genus = sapply(strsplit(as.character(data$Taxon),split = "; "),"[",6),
  Species = sapply(strsplit(as.character(data$Taxon),split = "; "),"[",7)))
rownames(tax) <- rownames(data)

# Load sample data
sample <- read.csv("Oral/mapping_file_oral_roos_new.csv", sep = ";")
sampleID <- unlist(sapply(strsplit(as.character(sample$X.SampleID),split = "Opti."),"[",-1))
sample <- sample %>% select(-X.SampleID) %>% data.frame
rownames(sample) <- sampleID

# Load phylogenetic tree
tree <- read.tree("Oral/roos_oral_tree.nwk")

# Prepare data and combine it into phyloseq object
otu <- otu_table(oral,taxa_are_rows = FALSE)
tax <- tax_table(as.matrix(tax))
samples <- sample_data(sample)
phyl <- phyloseq(otu,tax,tree,samples)

# Solve multichotomies (make tree entirely binary)
phyl <- phyloseq(otu,tax,multi2di(tree),samples)

# Rename tree nodes to n1-nN
phy_tree(phyl) <- makeNodeLabel(phy_tree(phyl), method="number", prefix='n')

saveRDS(phyl, "Oral/phyl_object.RDS")


##############################
#### Prepared sample data ####
##############################

sample <- data.frame(sample_data(phyl))

sample$sampleID <- rownames(sample[1:168,])

library(chron)
age <- as.Date(chron(format(as.Date(sample$date_birth, "%d.%m.%y"), "%m/%d/%y")))
sample$Age_cont <- calc_age(age,Sys.Date())

saveRDS(sample,"Oral/sample.RDS")


################################
#### PhILR transformed data ####
################################

oral_philr <- philr(otu_table(phyl)+1,phy_tree(phyl),part.weights='enorm.x.gm.counts', 
                    ilr.weights='blw.sqrt', return.all = TRUE)

OTU_philr <- data.frame(oral_philr$df.ilrp,"sampleID"=rownames(oral_philr$df.ilrp))

saveRDS(OTU_philr,"Oral/OTU_philr.RDS")

#################################
#### CLR transformed L8 data ####
#################################

OTU_clr <- (otu+1) %>% comp %>% clr %>% data.frame(sampleID=rownames(otu),check.names = FALSE)

saveRDS(OTU_clr,"Oral/OTU_clr_L8.RDS")

######################
#### Oral Data L7 ####
######################

data <- read.table("Oral/roos_oral_dada2_table-L7.tsv", sep = "\t", skip=-2)
dim(data)
data <- t(data)
glimpse(data)

# Extract patients IDs
names <- rownames(data)
sampleID <- sapply(strsplit(names,split = "Opti."),"[",-1)
rownames(data) <- sampleID

# Add patient ID as variable to be used for joining data with clinical information
data <- data.frame(sampleID,data)

# Extract L7 names. If L7 is not provided, use higher order names
Oral_L7_raw <- rename.OTU(data,"L7")

saveRDS(Oral_L7_raw,"Oral/L7_raw.RDS")

##########################
#### L7 Compositional ####
##########################

L7comp <- comp((Oral_L7_raw[,-1]+1))
Oral_L7_comp <- data.frame("sampleID"=Oral_L7_raw[,1],L7comp)

saveRDS(Oral_L7_comp,"Oral/L7_comp.RDS")

###############################
#### L7 Centered log-ratio ####
###############################
L7clr <- clr(L7comp)
Oral_L7_clr <- data.frame("sampleID"=Oral_L7_raw[,1],L7clr)

saveRDS(Oral_L7_clr,"Oral/L7_clr.RDS")

######################
#### Oral Data L5 ####
######################
data <- read.table("Oral/roos_oral_dada2_table-L5.tsv", sep = "\t", skip=-2)
dim(data)
data <- t(data)
glimpse(data)

# Extract patients IDs
names <- rownames(data)
sampleID <- sapply(strsplit(names,split = "Opti."),"[",-1)
rownames(data) <- sampleID

# Add patient ID as variable to be used for joining data with clinical information
data <- data.frame(sampleID,data)

# Extract L5 names. If L5 is not provided, use higher order names
Oral_L5_raw <- rename.OTU(data,"L5")
saveRDS(Oral_L5_raw,"Oral/L5_raw.RDS")

##########################
#### L5 Compositional ####
##########################

L5comp <- comp((Oral_L5_raw[,-1]+1))
Oral_L5_comp <- data.frame("sampleID"=Oral_L5_raw[,1],L5comp)

saveRDS(Oral_L5_comp,"Oral/L5_comp.RDS")

###############################
#### L5 Centered log-ratio ####
###############################
L5clr <- clr(L5comp)
Oral_L5_clr <- data.frame("sampleID"=Oral_L5_raw[,1],L5clr)

saveRDS(Oral_L5_clr,"Oral/L5_clr.RDS")
