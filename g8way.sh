bank=0
headoffset=0x200
datastart=0x00100000
banksize=0x5747C000

while [ "$bank" -lt 40 ]; do
skipme=$((headoffset * bank))
title=$(dd if="$1" bs=1 count=32 skip="$skipme" status=none | strings)
dataskip=$((datastart + (banksize * bank)))
lodgemagic=$(dd if="$1" bs=1 count=4 skip="$dataskip" status=none | xxd -p)

((bank++))

if [[ -z "$title" && "$lodgemagic" = "00000000" ]]; then
    echo "$bank. Bank Deleted and Data is gone"
elif [[ -z "$title" && "$lodgemagic" = "b38fdce1" ]]; then
    echo "$bank. Valid Data Detected, but bank has been deleted"
elif [[ -z "$title" ]]; then
    echo "$bank. Bank has been deleted, and unknown data detected on disc"
else
    echo "$bank. $title"
fi

done
