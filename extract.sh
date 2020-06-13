#! /bin/sh
echo "Extract zip passwords from image!"
echo ""

echo "Files in this folder:"
ls
echo ""

echo "Enter filename of image to extract from (e.g. memory_dump.img):"
read image_filename
#image_filename="text_memory13.img"
echo "Image to extract from: $image_filename"
echo "Enter the filename of the zip-locked file (e.g. message.zip):"
read zip_filename
#zip_filename="message.zip"
echo "Zip-locked file to find password for: $zip_filename"
echo "Enter the parent folder name of the zip-locked file (e.g. Temp):"
read folder_filename
#folder_filename="Temp"
echo "Folder the zip-locked file was in: $folder_filename"
echo ""

echo "Thanks, now we make the strings file."
strings_ending="_strings.txt"
strings_filename="$image_filename$strings_ending"
echo "Strings file: $strings_filename"
if [ -f "$strings_filename" ]
then
    echo "String file already found. Redo the string extraction? (yes/no)"
    read choice
    if [ $choice = "yes" ]
    then
        echo "Okay, extracting strings..."
	strings $image_filename > $strings_filename
	echo "Done extracting strings..."
	echo ""
    else
        echo "Okay, using old strings file."
        echo ""
    fi
else
    echo "Okay, extracting strings..."
    strings $image_filename > $strings_filename
    echo "Done extracting strings..."
    echo ""
fi



echo "Now, we search using filename and folder name."
echo "Search for '$folder_filename.*Temporary.*$zip_filename'"
search_1_ending="_search1.txt"
search_1_filename="$image_filename$search_1_ending"
cat -n $strings_filename | grep -E "$folder_filename.*Temporary.*$zip_filename" > $search_1_filename
echo "Done with search"
echo ""

echo "Now, we search using special character sequence '\s:=B~'"
search_2_ending="_search2.txt"
search_2_filename="$image_filename$search_2_ending"
cat -n $strings_filename | grep '\s:=B~' > $search_2_filename
echo "Done with search"
echo ""

echo "Now, we identify possible passwords from first search:"
num_lines=$(wc -l < $search_1_filename)
echo "$num_lines results from search 1"
for i in $(eval echo {1..$num_lines})
do
    #echo $(cat -n $search_1_filename | grep "\s\s$i\s")
    line=$(cat -n $search_1_filename | grep "\s\s$i\s" | head -n1 | awk '{print $2;}')
    #echo "$i $line"
    line=$(echo "$(($line + 1))")
    #echo "$i $line"
    possible_pass=$(cat -n $strings_filename | grep "^$line\s" | head -n1 | awk '{$1 = ""; print $0;}')
    #echo "$i $line $possible_pass"
    echo "Highly likely $i of $num_lines: $possible_pass"
done
echo "Done with possible passwords from first search."
echo ""

echo "Now, we identify possible passwords from second search:"
num_lines=$(wc -l < $search_2_filename)
echo "$num_lines results from search 2"
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
        echo "Relatively likely $i of $num_lines: $possible_pass"
        echo ""
    else
        echo -e "\e[1A\e[KRelatively likely $i of $num_lines: ~"
    fi
done
echo "Done with possible passwords from second search."
echo ""

echo "Done with extracting zip passwords. Good bye!"




