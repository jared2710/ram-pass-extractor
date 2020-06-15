#! /bin/sh

RED='\033[1;31m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${YELLOW}ram-pass-extractor${NC}"
echo "Extract passwords from an image of main memory!"
echo "Built for Windows XP SP3 images, and tested on a 1GB main memory image."
echo "Author: Jared O'Reilly, for COS 783"
echo ""


echo "Files in this folder:"
ls
echo ""

echo -e "Enter filename of image to extract from (e.g. memory_dump.img):${ORANGE}"
read image_filename
#image_filename="text_memory13.img"
echo -e "${NC}Image to extract from: ${ORANGE}$image_filename${NC}"
echo ""

echo "Select the type of password extraction you wish to perform:"
echo -e "${ORANGE}zip${NC} - Extract passwords leaked into RAM after the unlocking of a password-archived zip file"
echo -e "${ORANGE}ftp${NC} - Extract passwords leaked into RAM from use of the FTP client${ORANGE}"
read what_to_extract
if [ $what_to_extract = "zip" ]
then
    	echo -e "${NC}Option ${ORANGE}zip${NC} chosen, continuing with extraction."
	echo ""

	echo -e "Enter the filename of the zip-locked file (e.g. message.zip):${ORANGE}"
	read zip_filename
	#zip_filename="message.zip"
	echo -e "${NC}Zip-locked file to find password for: ${ORANGE}$zip_filename${NC}"
	#echo "Enter the parent folder name of the zip-locked file (e.g. Temp):"
	#read folder_filename
	folder_filename="Temp"
	#echo "Folder the zip-locked file was in: $folder_filename"
	echo ""

	echo -e "Thanks, now we ${BLUE}make the strings file${NC}."
	strings_ending="_strings.txt"
	strings_filename="$image_filename$strings_ending"
	echo "Strings file: $strings_filename"
	if [ -f "$strings_filename" ]
	then
	    echo -e "String file already found. Redo the string extraction? (yes/no)${ORANGE}"
	    read choice
	    if [ $choice = "yes" ]
	    then
		echo -e "yes${NC} - sure, extracting strings..."
		strings $image_filename > $strings_filename
		echo "Done extracting strings..."
		echo ""
	    else
		echo -e "no${NC} - okay, using old strings file."
		echo ""
	    fi
	else
	    echo "Extracting strings..."
	    strings $image_filename > $strings_filename
	    echo "Done extracting strings..."
	    echo ""
	fi



	echo -e "Now, we ${BLUE}search${NC} using filename and folder name."
	echo "Search 1 for '$folder_filename.*Temporary.*$zip_filename'"
	search_1_ending="_search1.txt"
	search_1_filename="$image_filename$search_1_ending"
	cat -n $strings_filename | grep -E "$folder_filename.*Temporary.*$zip_filename" > $search_1_filename
	echo "Done with search 1"
	echo ""

	echo -e "Now, we ${BLUE}search${NC} using our special character sequence."
	echo "Search 2 for '\s:=B~'"
	search_2_ending="_search2.txt"
	search_2_filename="$image_filename$search_2_ending"
	cat -n $strings_filename | grep '\s:=B~' > $search_2_filename
	echo "Done with search 2"
	echo ""

	echo -e "Now, we ${BLUE}identify possible passwords${NC} from search 1:"
	num_lines=$(wc -l < $search_1_filename)
	echo "$num_lines results from search 1":
	for i in $(eval echo {1..$num_lines})
	do
	    #echo $(cat -n $search_1_filename | grep "\s\s$i\s")
	    line=$(cat -n $search_1_filename | grep "\s\s$i\s" | head -n1 | awk '{print $2;}')
	    #echo "$i $line"
	    line=$(echo "$(($line + 1))")
	    #echo "$i $line"
	    possible_pass=$(cat -n $strings_filename | grep "^$line\s" | head -n1 | awk '{$1 = ""; print $0;}')
	    #echo "$i $line $possible_pass"
	    echo "Relatively likely $i of $num_lines: $possible_pass"
	done
	echo "Done with possible passwords from search 1."
	echo ""

	echo -e "Now, we ${BLUE}identify possible passwords${NC} from search 2:"
	echo "(note: there may be a leading |, removing it could give you the password)"
	num_lines=$(wc -l < $search_2_filename)
	echo "$num_lines results from search 2:"
	echo ""
	for i in $(eval echo {1..$num_lines})
	do
	    #echo $(cat -n $search_2_filename | grep "\s\s$i\s")
	    line=$(cat -n $search_2_filename | grep "\s\s$i\s" | head -n1 | awk '{print $2;}')
	    #echo "$i $line"
	    line=$(echo "$(($line - 1))")
	    #echo "$i $line"
	    possible_pass=$(cat -n $strings_filename | grep -E "^$line\s.*\|" | head -n1 | awk '{$1 = ""; print $0;}')
	    #echo "$i $line $possible_pass"
	    if [ "$possible_pass" != "" ]
	    then
		echo "Highly likely $i of $num_lines: $possible_pass"
		echo ""
	    else
		echo -e "\e[1A\e[KHighly likely $i of $num_lines:  ~"
	    fi
	done
	echo "Done with possible passwords from search 2."
	echo ""
elif [ $what_to_extract = "ftp" ]
then
    	echo -e "${NC}Option ${ORANGE}ftp${NC} chosen, continuing with extraction."
    	echo ""

	echo -e "Thanks, now we ${BLUE}make the strings file${NC}."
	strings_ending="_strings.txt"
	strings_filename="$image_filename$strings_ending"
	echo "Strings file: $strings_filename"
	if [ -f "$strings_filename" ]
	then
	    echo -e "String file already found. Redo the string extraction? (yes/no)${ORANGE}"
	    read choice
	    if [ $choice = "yes" ]
	    then
		echo -e "yes${NC} - sure, extracting strings..."
		strings $image_filename > $strings_filename
		echo "Done extracting strings..."
		echo ""
	    else
		echo -e "no${NC} - okay, using old strings file."
		echo ""
	    fi
	else
	    echo "Extracting strings..."
	    strings $image_filename > $strings_filename
	    echo "Done extracting strings..."
	    echo ""
	fi

	echo -e "Now, we ${BLUE}search${NC} for the word PASS, from the FTP protocol"
	echo "Search 1 for '[0-9]\sPASS\s'"
	search_1_ending="_search1.txt"
	search_1_filename="$image_filename$search_1_ending"
	cat -n $strings_filename | grep '[0-9]\sPASS\s' > $search_1_filename
	echo "Done with search 1"
	echo ""

	echo -e "Now, we ${BLUE}identify possible passwords${NC} from search 1:"
	num_lines=$(wc -l < $search_1_filename)
	echo "$num_lines results from search 1":
	for i in $(eval echo {1..$num_lines})
	do
	    possible_pass=$(cat -n $search_1_filename | grep "\s\s$i\s" | head -n1 | awk '{print $4;}')
	    echo "Highly likely $i of $num_lines: $possible_pass"
	done
	echo "Done with possible passwords from search 1."
	echo ""
else
    echo "Invalid option chosen, exiting."
    exit 0
fi

echo -e "${YELLOW}Done with extracting passwords from memory. Good bye!${NC}"
