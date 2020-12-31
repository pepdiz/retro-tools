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

check_file_cols () {
  OK_LINES=$(awk -F, "NF==$2{print NF}" < $1 |wc -l)
  FILE_LINES=$(wc -l < $1) 
  [ "$OK_LINES" -eq "$FILE_LINES" ] 
}

bas_array () {
  if (( LINES > 0 && COLS > 0 )) ; then
	  let LINES--
	  let COLS--
	  echo "dim $V($LINES,$COLS) as ubyte => { _"
	  sed -r -e '$s/^[^,]*(([0-9]+ *, *)+[0-9]+).*/{\1} _\n}/;$!s/^[^,]*(([0-9]+ *, *)+[0-9]+).*/{\1} , _ /'
  fi
}

c_array () {
  if (( LINES > 0 && COLS > 0 )) ; then
    echo "#define ${V}_ROWS $LINES"
    echo "#define ${V}_COLS $COLS"
	  echo "unsigned char $V[${V}_ROWS][${V}_COLS] = { _"
	  sed -r -e '$s/^[^,]*(([0-9]+ *, *)+[0-9]+).*/{\1}\n};/;$!s/^[^,]*(([0-9]+ *, *)+[0-9]+).*/{\1} ,/'
#	  sed -r -e '$s/.* (([0-9]+,)+[0-9]+)/{\1}\n};/;$!s/.* (([0-9]+,)+[0-9]+)/{\1} ,/'
  fi
}

asm_bytes () {
  echo "${V}_ROWS EQU $LINES"
  echo "${V}_COLS EQU $COLS" 
  echo "$V:"
  sed -r -e 's/^[^,]*(([0-9]+ *, *)+[0-9]+).*/db \1/'
#  sed -r -e 's/.* (([0-9]+,)+[0-9]+)/db \1/'
}

basm_bytes () {
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

check_file_cols $2 $COLS || { echo "number of fields in file $2 are not the same in all lines"; exit 2; }

case $1 in
bas)	dos2unix < $2 | bas_array ;;
basm)	dos2unix < $2 | basm_bytes ;;
c)		dos2unix < $2 | c_array ;;
asm)	dos2unix < $2 | asm_bytes ;;
*)	sintaxis ;;
esac


