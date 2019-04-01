#!/bin/bash
# (c) Pep Diz - licensed as GPLv2

sintaxis () {
  echo "$0 bas|basm|asm|c file [varname]"
  echo
  echo "read a csv file and writes it to stdout in selected format"
  echo "data values (byte assumed) may be inserted in any text line but have to be sequential csv"
  echo "basically extract any csv values and wrap them in right language syntax"
  echo "be sure to have only a data sequence by line or prepare to madness"
  exit
}

bas-array () {
  if (( LINES > 0 && COLS > 0 )) ; then
	  let LINES--
	  let COLS--
	  echo "dim $V($LINES,$COLS) as ubyte => { _"
	  sed -r -e '$s/^[^,]*(([0-9]+ *, *)+[0-9]+).*/{\1} _\n}/;$!s/^[^,]*(([0-9]+ *, *)+[0-9]+).*/{\1} , _ /'
  fi
}

c-array () {
  if (( LINES > 0 && COLS > 0 )) ; then
	  echo "unsigned char $V[$LINES][$COLS] = { _"
	  sed -r -e '$s/^[^,]*(([0-9]+ *, *)+[0-9]+).*/{\1}\n};/;$!s/^[^,]*(([0-9]+ *, *)+[0-9]+).*/{\1} ,/'
#	  sed -r -e '$s/.* (([0-9]+,)+[0-9]+)/{\1}\n};/;$!s/.* (([0-9]+,)+[0-9]+)/{\1} ,/'
  fi
}

asm-bytes () {
  echo "$V:"
  sed -r -e 's/^[^,]*(([0-9]+ *, *)+[0-9]+).*/db \1/'
#  sed -r -e 's/.* (([0-9]+,)+[0-9]+)/db \1/'
}

basm-bytes () {
  if (( LINES > 0 && COLS > 0 )) ; then
	  echo "$V:"
	  echo "ASM"
	  sed -r -e '$ s/^[^,]*(([0-9]+ *, *)+[0-9]+).*/db \1\nEND ASM/;$!s/^[^,]*(([0-9]+ *, *)+[0-9]+).*/db \1/'
	#  sed -r -e '$s/.* (([0-9]+,)+[0-9]+)/db \1\nASM END/;$!s/.* (([0-9]+,)+[0-9]+)/db \1/'
  fi
}

[ $# -gt 3 -o $# -lt 2 ] && sintaxis
[ -s $2 ] || { echo "$2 file not found"; exit 1; }

V=${3:-byteSet}

COLS=$(grep -E -o '([0-9]+ *, *)+[0-9]+' $2 | awk -F, 'NR==1{max=NF}NF > max{max=NF}END{print max}')
LINES=$(wc -l < $2)

case $1 in
bas)	dos2unix < $2 | bas-array ;;
basm)	dos2unix < $2 | basm-bytes ;;
c)		dos2unix < $2 | c-array ;;
asm)	dos2unix < $2 | asm-bytes ;;
*)	sintaxis ;;
esac


