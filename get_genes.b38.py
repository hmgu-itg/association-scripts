#!/nfs/team144/agilly/inter_manh_env/bin/python

import urllib2
import json
import sys
import pandas as pd

region=sys.argv[1]

url = 'http://rest.ensembl.org/overlap/region/human/'+region+'?feature=gene;content-type=application/json'
print("Querying Ensembl with region "+url)
response = urllib2.urlopen(url).read()

jData = json.loads(response)

print("The response contains {0} properties".format(len(jData)))
print("\n")
for item in jData:
	print item['external_name'], item['start'], item['end']

d=pd.DataFrame(jData)
print d['external_name']