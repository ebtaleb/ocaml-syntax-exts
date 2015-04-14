cmd{echo "################"}
cmd{echo "SOLUTION 1 - listing a bunch of ml files using a Loop"}
for (entry) in ("ls *.ml"): cmd{"wc" ${entry}}
