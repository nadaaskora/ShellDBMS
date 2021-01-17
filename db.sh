#!/bin/bash
mkdir dbms 2>> ./.error.log
function createDB {
	echo "Enter DB Name"
	read DBName
	DBName="./dbms/${DBName}"
	while [ -d $DBName ]
	do
		echo $DBName
		echo "Database already exist enter new DBName"
		read DBName
	done
	mkdir $DBName
	if [[ $?==0 ]]
	then
		echo "database $DBName created"
		source tables.sh
	else
		echo "can not create DB"
	fi 
	export $DBName
	./tables.sh
}
# createDB
function listDB {
	echo "Listing DB"
        ls ./dbms/
}       
#listDB
function connectDB {
	listDB
	echo "Select from existing DB"
	read DBName
    DBName="./dbms/${DBName}"
	if [ -d "$DBName" ]
	then
		ls $DBName
		source tables.sh
	else 
		echo "DB not found"
	fi
	export DBName
	./tables.sh
}
#connectDB
function dropDB {
	listDB
	echo "remove from existing DB"
	read DBName
	DBName="./${DBName}"
	if [ -d "$DBName" ]
	then
		rm -r $DBName
		listDB
	else
		echo "DB not found"
	fi
}
#dropDB
PS3='choose from DB options: '
select choice in createDB listDB connectDB dropDB Exit;
do
	case $choice in
		createDB) createDB 
		;;
		listDB) listDB
		;;
		connectDB) connectDB
		;;
		dropDB) dropDB
		;;
		Exit) 
		exit
		;;
		*)
		echo wrong choice
		;;
	esac
done