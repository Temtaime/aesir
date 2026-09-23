import os
import zipfile

dst = 'shaders.zip'

os.chdir('source/perfontain/shader/resource')

if os.path.exists(dst):
	os.remove(dst)

files = [ p[2] for p in os.walk('.') ][0]

with zipfile.ZipFile(dst, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
	for file in files:
		z.write(file)
