echo "################"
echo "SOLUTION 3 - calculate total count of words"
echo "" > temp
for entry in `ls *.ml`; do
  cat ${entry} >> temp
done
wc -w temp
rm temp
