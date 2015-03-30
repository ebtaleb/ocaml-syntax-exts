# calculate total
echo "################"
echo "SOLUTION 2 - calculate total count of words"
FILES=""
for entry in `ls *.ml`; do
  FILES=${entry}\ $FILES
done
wc -w $FILES

