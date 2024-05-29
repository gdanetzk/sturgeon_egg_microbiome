#!/bin/bash

# load modules
module load ITSx/1.0.11
module load BLAST+/2.2.30

#### Create Oomycete ITS2 Database ------------------------------------

# use ITSx to pull out ITS2 sequences from full list 
ITSx -i Robideau_ITS2.fasta -o Robideau_allITS_extracted.fasta.ITS2.fasta -t Oomycetes --preserve T --save_regions ITS2 --partial 99 --truncate T --multi_thread T --cpu 8

#remove extra info from fasta header
grep -c '>' Robideau_ITS2.fasta #1201 sequences 
sed -e 's/|O|ITS2 Extracted ITS2 sequence .*-.* (.* bp)/ /g' Robideau_ITS2.fasta > sed.test.Robideau_ITS2.fasta 
grep -c '>' sed.test.Robideau_ITS2.fasta #1201 sequences

# Run replace_fasta_names.py -> add full taxonomic lineage to fasta header line
# file with full lineage == all_names_unite.txt (1465 names)
# file with sequences == sed.test.Robideau_ITS2.fasta (1201 sequenecs)
# output file == rename_Robideau_ITS2.fasta
python replace_fasta_names.py

# create SINTAX database and train classifier
/mnt/research/rdp/public/thirdParty/usearch10.0.240_i86linux64 -makeudb_sintax /mnt/home/oomy_taxonomy/rename_Robideau_ITS2.fasta -output /mnt/home/oomy_taxonomy/Robideau_ITS2.udb

#### Oomycetes ------------------------------------

# merged reads
/mnt/research/rdp/public/thirdParty/usearch10.0.240_i86linux64 -fastq_mergepairs /mnt/research/Oomycetes/*R1*.fastq -report -report.txt -fastq_minmergelen 200 -fastq_maxdiffs 10 -fastq_maxdiffpct 10 -relabel @ -fastqout /mnt/home/fish_eggs/oomy_merged.fq

# quality filer 
/mnt/research/rdp/public/thirdParty/usearch10.0.240_i86linux64 -fastq_filter /mnt/home/fish_eggs/oomy_merged.fq -fastq_maxee 1.0 -fastaout /mnt/home/fish_eggs/oomy_new_filtered.fa

# get unique seqs
/mnt/research/rdp/public/thirdParty/usearch8.1.1831_i86linux64 -derep_fulllength /mnt/home/fish_eggs/oomy_new_filtered.fa -sizeout -fastaout /mnt/home/fish_eggs/oomy.reads.derep.fa -uc /mnt/home/fish_eggs/oomy.reads.unique.uc -threads 4

# cluster OTUs
/mnt/research/rdp/public/thirdParty/usearch8.1.1831_i86linux64 -cluster_otus /mnt/home/fish_eggs/oomy.reads.derep.fa -minsize 2 -sizein -sizeout -relabel OTU_ -otus /mnt/home/fish_eggs/oomy.reads.derep.otus.fa -uparseout /mnt/home/fish_eggs/oomy.reads.derep.otus.txt

# remove chimeras
/mnt/research/rdp/public/thirdParty/usearch8.1.1831_i86linux64 -uchime_ref /mnt/home/fish_eggs/oomy.reads.derep.otus.fa -db /mnt/home/unite_ref_db/uchime_ref_dyn_ITS2.fasta -nonchimeras /mnt/home/fish_eggs/oomy.reads.derep.otus.no_chimera.fa -uchimeout /mnt/home/fish_eggs/oomy.reads.derep.otus.no_chimera.uchime -strand plus -sizein -sizeout

# map reads back to OTUs
/mnt/research/rdp/public/thirdParty/usearch8.1.1831_i86linux64 -usearch_global /mnt/home/fish_eggs/oomy_new_filtered.fa -db /mnt/home/fish_eggs/oomy.reads.derep.otus.no_chimera.fa -strand plus -id 0.97 -top_hit_only -otutabout /mnt/home/fish_eggs/oomy.otu_tab.txt -sizein -sizeout 

# assign taxonomy oomycetes -> SINTAX with Robideau Database
# create SINTAX database and train classifier
/mnt/research/rdp/public/thirdParty/usearch10.0.240_i86linux64 -makeudb_sintax /mnt/home/oomy_taxonomy/rename_Robideau_ITS2.fasta -output /mnt/home/oomy_taxonomy/Robideau_ITS2.udb
# classify Oomycete OTUs
/mnt/research/rdp/public/thirdParty/usearch10.0.240_i86linux64 -sintax /mnt/home/fish_eggs/oomy.reads.derep.otus.no_chimera.fa -db /mnt/home/oomy_taxonomy/Robideau_ITS2.udb -tabbedout /mnt/home/fish_eggs/oomy_otus_taxonomy_05.sintax -strand both -sintax_cutoff 0.5


#### Fungi ------------------------------------

# merged reads 
/mnt/research/rdp/public/thirdParty/usearch10.0.240_i86linux64 -fastq_mergepairs /mnt/research/Fungi/*R1*.fastq -report -report.txt -fastq_minmergelen 200 -fastq_maxdiffs 10 -fastq_maxdiffpct 10 -relabel @ -fastqout /mnt/home/fish_eggs/fungi_merged.fq

# quality filer 
/mnt/research/rdp/public/thirdParty/usearch10.0.240_i86linux64 -fastq_filter /mnt/home/fish_eggs/fungi_merged.fq -fastq_maxee 1.0 -fastaout /mnt/home/fish_eggs/fungi_new_filtered.fa

# get unique seqs
/mnt/research/rdp/public/thirdParty/usearch8.1.1831_i86linux64 -derep_fulllength /mnt/home/fish_eggs/fungi_new_filtered.fa -sizeout -fastaout /mnt/home/fish_eggs/its.reads.derep.fa -uc /mnt/home/fish_eggs/its.reads.unique.uc -threads 4

# cluster OTUs
/mnt/research/rdp/public/thirdParty/usearch8.1.1831_i86linux64 -cluster_otus /mnt/home/fish_eggs/its.reads.derep.fa -minsize 2 -sizein -sizeout -relabel OTU_ -otus /mnt/home/fish_eggs/its.reads.derep.otus.fa -uparseout /mnt/home/fish_eggs/its.reads.derep.otus.txt

# remove chimeras
/mnt/research/rdp/public/thirdParty/usearch8.1.1831_i86linux64 -uchime_ref /mnt/home/fish_eggs/its.reads.derep.otus.fa -db /mnt/home/unite_ref_db/uchime_ref_dyn_ITS2.fasta -nonchimeras /mnt/home/fish_eggs/its.reads.derep.otus.no_chimera.fa -uchimeout /mnt/home/fish_eggs/its.reads.derep.otus.no_chimera.uchime -strand plus -sizein -sizeout

# map reads back to OTUs
/mnt/research/rdp/public/thirdParty/usearch8.1.1831_i86linux64 -usearch_global /mnt/home/fish_eggs/fungi_new_filtered.fa -db /mnt/home/fish_eggs/its.reads.derep.otus.no_chimera.fa -strand plus -id 0.97 -top_hit_only -otutabout /mnt/home/fish_eggs/its.otu_tab.txt -sizein -sizeout 

# assign taxonomy fungi -> SINTAX with UNITE database 
# create database and train classifier
/mnt/research/rdp/public/thirdParty/usearch10.0.240_i86linux64 -makeudb_sintax /mnt/home/unite_ref_db/sh_general_release_31.01.2016__UTAX__filtered.fasta -output /mnt/home/unite_ref_db/sintax_db_31.01.2016.db
# classify Fungal OUTs with SINTAX
/mnt/research/rdp/public/thirdParty/usearch10.0.240_i86linux64 -sintax /mnt/home/fish_eggs/its.reads.derep.otus.no_chimera.fa -db /mnt/home/unite_ref_db/sintax_db_31.01.2016.db -tabbedout /mnt/home/fish_eggs/fungi_otus_taxonomy_05.sintax -strand both -sintax_cutoff 0.5
#classify Fungal OTUs with RDP Classifier 
java -jar /mnt/research/rdp/public/RDPTools/classifier.jar classify --conf 0.5 --format allrank --gene fungalits_unite -o /mnt/home/fish_eggs/fungi_otus_taxonomy.rdp /mnt/home/fish_eggs/its.reads.derep.otus.no_chimera.fa
