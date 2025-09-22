# Packages
library(shiny)
library(shinythemes)
library(ggplot2)
library(shinyjs)
library(stringr)
library(dplyr)
library(reshape2)
library(stringr)
library(ggvenn)
library(readxl)
library(ggrepel)
library(jsonlite)
library(rstatix)
library(ggpubr)
library(ggtext)
library(plotly)

# Set wd
#setwd("E:/Ageing datasets/Ageing_Teeth_Shiny/")

# EPA tissues with protocols
protocol_steps <- c("Sample collection",
                    "Isolation of tissues",
                    "Protein extraction",
                    "Protein digestion",
                    "Mass spectrometry",
                    "Statistical analysis")

# EPA samples with analysis done
analysis <- c("Enamel", "Pulp", "Dentin", "Cementum")

# Written brief protocols
protocol_texts <- list(
  Samplecollection = "Equine molars were removed from cadaver heads of mixed breeds sourced from an abattoir. Samples were collected as a byproduct of the agricultural industry. Specifically, the Animal (Scientific Procedures) Act 1986, Schedule 2, does not define collection from these sources as scientific procedures. Ethical approval was therefore not required for this study. Molars from five young and five old horses with no macroscopic signs of disease were used and each of four dental tissues isolated from each tooth: pulp, dentine, enamel, cementum.  For diseased teeth molars were collected following surgical extraction by a veterinary surgeon with informed consent and ethical approval (University of Liverpool; VREC1171). Teeth were stored immediately at – 80 °C.",
  Isolationoftissues = "Adherent periodontal ligament and alveolar bone were removed using a sterile scalpel. Pulp was extracted using sterile dental probes and stored immediately at – 80 °C. The teeth were sectioned into three segments: crown, reserve crown and root. The segments were separated by cutting horizontally using a diamond wire (WELL Precision Diamond Wire Saw model 3242, Le Locle, Switzerland) under constant water cooling. The crown was further cut into 1 – 3 mm thick sections. To distinguish the individual tissues, the cross sections were visualised under QLF imaging. Images were captured using the QLF-D™ Biluminator system (Inspektor Pro Research Systems, Amsterdam, Netherlands), attached to an SLR camera (Canon 660D; Canon, Tokyo, Japan) with an EF-S 60mm f/2.8 macro lens (Canon, Tokyo, Japan). The Biluminator is a tube containing 8 blue LEDs (405nm), 4 white LEDs (6500k), and filters for making white-light and QLF™ images. Images were captured in a dark room with standardised settings for blue and white light images. Pulp tissues were removed using sterile endodontic files and hard tissues were cut based of previously acquired images. Segments of hard tissues were further processing using a diamond disc (Buehler Ecomet 30, Illinois, United States).",
  Proteinextraction = "Pulp tissue was into small fractions using a sterile scalpel and snap frozen with liquid nitrogen. Hard tissues (dentin, cementum and enamel) were also snap frozen and then processed tissues were crushed into a fine powder using a mikro-dismembrator (Sartorius Group, Göttingen, Germany) with further liquid nitrogen cooling. Hard tissues were incubated with 500mM Ethylenediaminetetraacetic acid (EDTA) and protease inhibitor cocktail (find code) for three days at 4°C. Samples were centrifuged at 10,000g for 10 minutes and the supernatant was collected. The remaining powder and the pulp tissue was then incubated with guanidine hydrochloride (GnHCl, 4 M, ThermoFisher Scientific, Massachusetts, United States) extraction buffer containing dithiothreitol (DTT, 65 mM, Sigma) and sodium acetate (25 mM, Sigma) and sonicated for ten 30 second cycles with 30 second rest using a Bioruptor Sonication Device (Diagenode, Liege, Belgium). Samples were left for one day under constant motion and then the protein extract was collected as previously mentioned. EDTA and GnHCl protein extracts were pooled together for further processing. Prior to determining the concentrartion of extract, buffers were exchanged using Vivaspin columns (3kda cut-off, Sartorius Group, Göttingen, Germany) and then protein concentration was determined using Pierce660 protein assay (ThermoFisher Scientific, Massachusetts, United States) according to manufacturer’s protocol. ",
  Proteindigestion = "For digestion, 50 µg of protein of each sample was incubated with 10 µl of StratacleanTM resin (Agilent Genomics, California, United States) and washed three times with 25 mM ammonium bicarbonate (ambic) (ThermoFisher Scientific, Massachusetts, United States). The sample was incubated with RapigestTM (Waters, Massachusetts, United States) (80 °C, 10 min, 0.05 % (w/v)), reduced with DTT (ThermoFisher Scientific, Massachusetts, United States) (60 °C, 10 min, 3 mM) and alkylated with iodoacetamide (ThermoFisher Scientific, Massachusetts, United States) (25 °C, 30 min, in the dark, 9 mM). Before the addition of Trypsin/Lys-C (Promega, Wisconsin, United States), the digests were transferred into Protein LoBind tubes (Eppendorf, Hamburg, Germany). Trypsin/Lys-C was added at a 50:1 protein to Trypsin/Lys-C ratio for 12 h at 37 °C with agitation.. Samples were centrifuged (5000 g. 5 min), the supernatant (tryptic digest) transferred into a fresh LoBind tube and the Rapigest inactivated with trifluoroacetic acid (ThermoFisher Scientific, Massachusetts, United States) (37 °C, 30 min, 0.05 % (v/v)). The digest was centrifuged (13000 g, 15 min) and the supernatant used for downstream liquid chromatography tandem mass spectroscopy analysis",
  Massspectrometry = "Mandy did this",
  Statisticalanalysis = "Label-free quantification (LFQ) intensities were obtained from Progenesis QI for Proteomics and exported for downstream analysis. The normalised intensity values were imported into R (version 4.2.2) for preprocessing, statistical testing, and visualisation. Proteins were filtered to exclude those with excessive missing values; specifically, only proteins quantified in at least three biological replicates per group were retained for further analysis. To assess and compare normalisation methods, the NormalyzerDE package (version 1.16.0) was used. Multiple normalisation approaches were evaluated, and median normalisation was selected as the most suitable method based on diagnostic plots and performance metrics. Median normalisation was implemented as follows: the intensity of each protein in a given sample was divided by the sample median, then multiplied by the mean of sample medians across all samples. The resulting values were then log2-transformed to stabilise variance and approximate normal distribution. Pairwise differential expression analysis was performed within each tissue type using NormalyzerDE, comparing the following groups: young vs. old, young vs. diseased, and old vs. diseased. Importantly tissues were not compared against tissues due to batch effects.  Statistical significance was assessed using empirical Bayes moderated t-tests. Proteins were considered differentially expressed if they met both a fold change threshold of log2(FC) ≥ 1 or ≤ -1 and a p-value ≤ 0.05. All visualisations were generated using the ggplot2 package (version 3.4.3) in R. These included volcano plots, boxplots, and PCA plots to illustrate expression patterns and group separation. Significantly differentially expressed proteins from each comparison were then uploaded to Ingenuity Pathway Analysis (IPA) software for functional and pathway enrichment analysis."
)

# get a long dataset in excel that contains all the proteins in tissues
venn_check <- read.csv("data/venn_check.csv") %>% 
  mutate(Protein = unlist(lapply(strsplit(Protein, "\\."), function(x)x[1])))
# pulp prots
pulp_prot <- venn_check %>% 
  filter(Tissue == "Pulp") %>% 
  pull(var = Protein)
dentin_prot <- venn_check %>% 
  filter(Tissue == "Dentine") %>% 
  pull(var = Protein)
cementum_prot <- venn_check %>% 
  filter(Tissue == "Cementum") %>% 
  pull(var = Protein)
enamel_prot <- venn_check %>% 
  filter(Tissue == "Enamel") %>% 
  pull(var = Protein)

# Make the list
protein_data <- list(
  Pulp = pulp_prot,
  Dentin = dentin_prot,
  Cementum = cementum_prot,
  Enamel = enamel_prot
)

