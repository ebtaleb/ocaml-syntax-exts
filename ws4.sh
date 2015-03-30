echo "################"
echo "SOLUTION 4 - calculate total count of words and save in array"
FILES=""
declare -a WC
IDX=0
for entry in `ls *.ml`; do
  WC[$IDX]=`wc -w ${entry}`
  IDX=$((IDX+1))
  FILES=${entry}\ $FILES
done
echo "****print array 3:"
for ((i=0; i<$IDX; i++)) do
    echo ${WC[${i}]}
done

# design a Shell scripting language for OCaml

