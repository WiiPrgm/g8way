numlist() {

bank=0
headoffset=0x200
datastart=0x00100000
banksize=0x5747C000
epoch=946684800


while [ "$bank" -lt 40 ]; do
skipme=$((headoffset * bank))
title=$(dd if="$2" bs=1 count=32 skip="$skipme" status=none | strings)
dataskip=$((datastart + (banksize * bank)))
lodgemagic=$(dd if="$2" bs=1 count=4 skip="$dataskip" status=none | xxd -p)
datemagic=$(dd if="$2" bs=1 count=4 skip="$((skipme + 0x20))" status=none | xxd -p | tr -d '\r\n')
magicdate=$((epoch + $(printf "%d\n" "0x${datemagic:6:2}${datemagic:4:2}${datemagic:2:2}${datemagic:0:2}")))

((bank++))


if [[ -z "$title" && "$lodgemagic" = "00000000" ]]; then
    #No header on HDD and no data in the bank. Commenting out for now. Will be useful for adding a deep scan later.
    #echo "$bank. Bank Deleted and Data is gone"
    echo ""
elif [[ -z "$title" && "$lodgemagic" = "b38fdce1" ]]; then
    #Bank is missing header at start of HDD, but first bytes of the bank look like a game
    echo "$bank. Valid Data Detected, but bank has been deleted"
elif [[ -z "$title" ]]; then
    #This type of bank has no header, but there is some likely non-game data in the bank
    echo "$bank. Bank has been deleted, and unknown data detected on disc"
else
    if [[ "$1" == "-la" ]]; then
        # Formats: Column 1 (Left aligned, 30 chars wide), Column 2 (Date), Column 3 (Time)
        formatted_date=$(date -u -d "@$magicdate" "+%B %-d, %Y")
        formatted_time=$(date -u -d "@$magicdate" "+%H:%M:%S")
        printf "%-36s %-20s %-10s\n" "$bank. $title" "$formatted_date" "$formatted_time"
    else
        echo "$bank. $title"
	fi
fi

done
}

bankextract(){
#syntax = gway -x gclnet.img bank#

bank="$3"
headerstart=0x00100000
banksize=0x5747C000
bankdatastart=0x00108000
gcsize=0x57060000
title=$(dd if="$2" bs=1 count=32 skip=$((($3 - 1) * 512)) status=none | strings)


if [[ "$1" == "-x" ]]; then
dataskip=$((headerstart + (banksize * (bank - 1))))
dd if="$2" bs=1 skip="$dataskip" count=$((0x8000)) of="$bank"."$title"".header"
else
dataskip2=$((bankdatastart + (banksize * (bank -1))))
dd if="$2" bs=1M skip="$dataskip2" count=$((gcsize)) iflag=skip_bytes,count_bytes of="${bank}.${title}.body" status=progress
fi

}


case "$1" in
    list|-l|-la)
        numlist "$1" "$2"
        ;;
    extract|-x|-xa)
        bankextract "$1" "$2" "$3"
        ;;
    tplextract|-tpl)
        tplextract "$2" "$3"
        ;;
    listall|-la)
	numlist "$2"
	verbose=1
	;;
#    extractall|-xa)
#	bankextractall "$2"
#	;;

	help|--h|-h)
	echo This tool is for analyzing Gamecube Lodgenet HDD dumps.
	echo In this version, games can only be extracted in their encrypted form..
	echo $0 -l [HDD image] will list all games from the HDD header.
	echo $0 -tpl [HDD image] [Bank Number] will extract the box art TPL if present.
	echo $0 -x [HDD image] [Bank Number] will extract that game from the HDD image.
	echo $0 -xa [HDD image] will extract all games from the HDD image.
	exit 1
	;;

	*)
        echo run $0 -h for usage instructions
        exit 1
        ;;
esac
