next() {
  sort -R random
}
square() {
 sed -n -e "${i},+5p" <( next )
}
for j in {1..200}
do
for i in {1..715}
do
 square > temp
 hash=$( cat temp | md5 )
 mv temp squares/${hash}
 echo ${hash}
done
done | tee out
