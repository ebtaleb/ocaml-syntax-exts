cmd{echo "################"}
cmd{echo "SOLUTION 4 - calculate total count of words and save in array"}
files=""
array{wc}
idx=0
for (entry) in ("ls *.ml"): concat{ files = ${files} ${entry}}
cmd{echo "****print array 3:"}
for (i) in (0 9): cmd{"echo" wc{i}}
