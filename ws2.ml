cmd{echo "################"}
cmd{echo "SOLUTION 2 - calculate total count of words"}
files=""
for (entry) in ("ls *.ml"): concat{ files = ${entry} ${files} }
cmd{"wc -w" ${files}}
