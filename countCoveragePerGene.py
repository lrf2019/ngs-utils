#!/usr/bin/env python
import sys
import math
import csv
from collections import defaultdict

columns = defaultdict(list)

dictAvgCoverage=dict()
dictCount=dict()
dictMedian=dict()
dictSD=dict()
dictU10=dict()
dictU20=dict()
dictU50=dict()
dictU100=dict()
#print sys.argv[1]
reader = csv.DictReader(open(sys.argv[1], "rb"), delimiter="\t")
for row in reader:
	gene=row['Gene']
	cov=row['AvgCoverage']
	median=row['Median']
	sd=row['SD']
	u10=row['u10']
	u20=row['u20']
	u50=row['u50']
	u100=row['u100']
	if row['Gene'] not in dictAvgCoverage:
		dictAvgCoverage[row['Gene']] = 0 
		dictMedian[row['Gene']] = 0
		dictSD[row['Gene']] = 0
		dictU10[row['Gene']] = 0
		dictU20[row['Gene']] = 0
		dictU50[row['Gene']] = 0
		dictU100[row['Gene']] = 0
		dictCount[row['Gene']] = 0

	dictAvgCoverage[row['Gene']] += float(cov)
	dictSD[row['Gene']] += float(sd)
	dictMedian[row['Gene']] += float(median)
	if u10:
		dictU10[row['Gene']] += float(u10)
	if u20:
		dictU20[row['Gene']] += float(u20)		
	if u50:
		dictU50[row['Gene']] += float(u50)
	if u100:
		dictU100[row['Gene']] += float(u100)
	dictCount[row['Gene']] += 1


for gene in dictAvgCoverage:
	c=dictAvgCoverage[gene]/dictCount[gene]
	de=dictSD[gene]/dictCount[gene]
	d=dictMedian[gene]/dictCount[gene]
	e=dictU10[gene]/dictCount[gene]
	f=dictU20[gene]/dictCount[gene]
	g=dictU50[gene]/dictCount[gene]
	h=dictU100[gene]/dictCount[gene]
	print gene + "\t"+  str(c) + "\t" + str(dictCount[gene]) + "\t"+ str(d) +"\t"+ str(de) +"\t"+str(e) + "\t"+str(f) + "\t"+ str(g)+ "\t"+str(h) 
