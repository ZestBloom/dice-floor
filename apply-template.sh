template-line() {
  cat << EOF
	else if(as + bs == ${1} + 7 * ${2}) {
	  transfer(balance(tok${3}), tok${3}).to(this);
	  transfer(1, tok7).to(${5})
	} 
EOF
}
template() {
  ${FUNCNAME}-line 0 ${i} ${i0} 6 Alice
  ${FUNCNAME}-line 1 ${i} ${i1} 6 Alice
  ${FUNCNAME}-line 2 ${i} ${i2} 6 Alice
  ${FUNCNAME}-line 3 ${i} ${i3} 6 Alice
  ${FUNCNAME}-line 4 ${i} ${i4} 6 Alice
  ${FUNCNAME}-line 5 ${i} ${i5} 6 Alice
}
i=0
while read -r i0 i1 i2 i3 i4 i5
do
 template
 let i+=1
done < <( cat ${1:-squares/693e5ca12dcf6e4f21b1e988114900f6} ) | sed -e '1s/else //' -e 's/tok6/tok0/g' -e 's/tok7/tok6/g'


