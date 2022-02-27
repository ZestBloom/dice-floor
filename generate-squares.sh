next() {
  sort -R random
}
square() {
 sed -n -e "${i},+6p" <( next )
}
for j in {1..500}
do
for i in {1..713}
do
 square > temp
 hash=$( cat temp | md5 )
 mv temp rolls/${hash}
 echo ${hash}
done
done | tee out
