#! /bin/bash

function just_do_it {

for over in ever
do

du -S -a -b -d 1 | sort -n -r

done

}


#clear
echo -e 'SIZE\t NAME'
echo  


just_du_it


echo  
