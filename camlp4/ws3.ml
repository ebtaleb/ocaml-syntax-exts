cmd{echo "################"}
cmd{echo "SOLUTION 3 - calculate total count of words"}
out{"echo \"\" > temp"}
for (entry) in ("ls *.ml"): out{"cat" ${entry}}>"temp"
cmd{"wc -w temp"}
cmd{"rm temp"}
