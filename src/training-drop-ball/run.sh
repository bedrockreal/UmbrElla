sfiles=$(ls | grep ".s$")
for f in $sfiles; do
	b=$(basename "${f%.*}")
	./../asm2gecko $f
	rm $b
done
rm gecko.txt
cat *.txt > gecko.txt
xclip -selection clipboard < gecko.txt
