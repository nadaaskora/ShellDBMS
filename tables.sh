#!/bin/bash
function createTable {
        echo "Enter Table Name: "
        read tableName
        while  [ -d $DBName/$tableName ]
        do
                echo $DBName/$tableName
                echo "Table already exist Enter new table name"
	        read tableName
        done
                touch $DBName/$tableName
                echo "Number of Columns: "
                read colsNum
                counter=1
                sep=","
                pKey=""
                while [ $counter -le $colsNum ]
                do
                        echo "Name of Column No.$counter: "
                        read colName
               if [[ $counter == $colsNum ]]; then
                temp=$temp$colName
                else
                temp=$temp$colName$sep
                fi
                ((counter++))
                done
                echo -e $temp >> $DBName/$tableName

                #metadata tabele
                pKey=`awk -F'[,]' '{if(NR==1) print $1}' $DBName/$tableName`
                metaData="columName "$colName"Pkey "$pKey
                touch $DBName/.$tableName
                echo -e $metaData >> $DBName/.$tableName
                cat $DBName/$tableName
        #fi
        if [[ $?==0 ]]
        then
                echo "Table $tableName created"
        else
                echo "Error"
        fi
}
#createTable
function insertInToTable {
        echo "Enter Table Name: "
        read tableName
        if [[ -f $DBName/$tableName ]]
        then
                noFields=`awk -F'[,]' '{if(NR==1)print NF}' $DBName/$tableName`
                pKey=`awk -F'[,]' '{if(NR>=2) print $1}' $DBName/$tableName`
                echo "how many records you want to insert"
                read numRecords
                newL='\n'
                sep=','
                for (( i=1; i<=numRecords; i++ ))
                do
                        for (( j=1; j<=noFields; j++ ))
                        do
                                coulmName=`awk -F'[,]' '{if(NR==1) print $'$j'}' $DBName/$tableName`
                                # echo -e $coulmName
                                echo "read $coulmName record $i"
                                read data
                                while [ $j -eq 1 ] && [ -z "$data" ]
                                do 
                                        echo "PK can't be null Enter pk again" 
                                        echo "read $coulmName record $i"
                                        read data
                                done

                                if [ $j -eq 1 ]
                                then
                                        for x in ${pKey[@]}
                                        do
                                                if [[ $data -eq $x ]]
                                                then
                                                        echo "pk must be unique, insert pk again "
                                                        read data
                                                fi
                                        done
                                fi

                                if [[ $j == $noFields ]]; then
                                        row=$row$data
                                        else
                                        row=$row$data$sep
                                fi
                        done
                        row=$row$newL
                        echo -e `sed -i '/^[[:space:]]*$/d' $DBName/$tableName`
                done
                echo -e $row >> $DBName/$tableName
        else
                echo "no exisiting table, create new table?(y/n)"
                read ch
                case $ch in  
                        y|Y) createTable ;; 
                        n|N) echo "Exit" ;; 
                        *) echo "wrong choice" ;; 
                esac
        fi

        
}
# insertInToTable
function selectFromTable {
        # cat $DBName/$tableName
        echo "Enter Table Name: "
        read tableName
        if [[ -f $DBName/$tableName ]]
        then
                pKey=`awk -F'[,]' '{if(NR>=2) print $1}' $DBName/$tableName`
                echo "Select row by pk"
                read pk
                counter=2
                for x in ${pKey[@]}
                do
                # echo "$x"
                # echo "coutner $record"
                        if [[ $x -eq $pk ]];
                        then
                                record=`awk -F'[,]' '{if(NR=='$counter') print $0}' $DBName/$tableName`
                                echo $record
                        fi
                        ((counter++))
                done
        else
               echo "no exisiting table, create new table?(y/n)"
                read ch
                case $ch in  
                        y|Y) createTable ;; 
                        n|N) echo "Exit" ;; 
                        *) echo "wrong choice" ;; 
                esac
        fi
        
}
#selectFromTable
function deleteFromTable {
        echo "Enter Table Name: "
        read tableName
        if [[ -f $DBName/$tableName ]]
        then
                pKey=`awk -F'[,]' '{if(NR>=2) print $1}' $DBName/$tableName`
                echo "Delete row by pk"
                read pk
                counter=2
                for x in ${pKey[@]}
                do
                # echo "$x"
                # echo "coutner $record"
                        if [[ $x -eq $pk ]];
                        then
                                record=`awk -F'[,]' '{if(NR=='$counter') print $0}' $DBName/$tableName`
                                echo -e `sed -i ''$counter'd' $DBName/$tableName`
                                echo "record deleted successfully"
                                
                        fi
                        ((counter++))
                done
        else
               echo "no exisiting table, create new table?(y/n)"
                read ch
                case $ch in  
                        y|Y) createTable ;; 
                        n|N) echo "Exit" ;; 
                        *) echo "wrong choice" ;; 
                esac
        fi
}
# deleteFromTable
function listTables {
        echo "Listing Tables..."
        ls $DBName
}
#listTables
function dropTable {
        listTables
        echo "drop Table: "
        read tableName
        tableName="$DBName/${tableName}"
        if [ -f "$tableName" ]
        then
                rm $tableName
                echo "table deleted successfully"
        else
               echo "no exisiting table, create new table?(y/n)"
                read ch
                case $ch in  
                        y|Y) createTable ;; 
                        n|N) echo "Exit" ;; 
                        *) echo "wrong choice" ;; 
                esac
                
        fi
       
}
#dropTable
PS3='choose from tables options: '
select choice in "createTable" "insertInToTable" "selectFromTable" "deleteFromTable" "listTables" "dropTable" quit;
do
	case $choice in
		"createTable") 
                createTable
		;;
		"insertInToTable") insertInToTable
		;;
		"selectFromTable") selectFromTable
		;;
		"deleteFromTable") deleteFromTable
		;;
		"listTables") listTables
		;;
		"dropTable") dropTable
		;;
                quit) 
                source ./db.sh
                ;;
		*)
		echo "wrong choice"
		;;
	esac
done
