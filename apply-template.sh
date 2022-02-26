template() {
  cat << EOF
        else if(as + bs == 0 + 7 * ${i}) transfer(balance(tok${i0}), tok${i0}).to(this);
        else if(as + bs == 1 + 7 * ${i}) transfer(balance(tok${i1}), tok${i1}).to(this);
        else if(as + bs == 2 + 7 * ${i}) transfer(balance(tok${i2}), tok${i2}).to(this);
        else if(as + bs == 3 + 7 * ${i}) transfer(balance(tok${i3}), tok${i3}).to(this);
        else if(as + bs == 4 + 7 * ${i}) transfer(balance(tok${i4}), tok${i4}).to(this);
        else if(as + bs == 5 + 7 * ${i}) transfer(balance(tok${i5}), tok${i5}).to(this);
EOF
}
i=0
while read -r i0 i1 i2 i3 i4 i5
do
 template
 let i+=1
done < <( cat ${1:-squares/693e5ca12dcf6e4f21b1e988114900f6} ) | sed -e '1s/else //' -e 's/tok6/tok0/g'

