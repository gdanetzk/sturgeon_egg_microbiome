#!/usr/bin/env python2.7

fasta= open('Robideau_allITS_extracted.fasta.ITS1.fasta')
newnames= open('Taxonomy_Robideau_2011_ITS1_extraction.txt')
newfasta= open('Robideau2011_oomycetes_ITS1_extraction_UNITEformat.fasta', 'w')

for line in fasta:
    if line.startswith('>'):
        newname= newnames.readline()
        newfasta.write(newname)
    else:
        newfasta.write(line)

fasta.close()
newnames.close()
newfasta.close()