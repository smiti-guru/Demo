#!/bin/ksh
##############################################################################
# modifications:                                                             #
# date       by         description                                          #
# __________ __________ _____________________________________________________#
# 2015-12-18 RM T84621  QA:CHG0137441    prod:           -- original release #
#                                                                            #
##############################################################################

#file permission check for 744
file_permission_validation(){
if [ -f $1 ]
then
var='-rwxr--r--'
var1=`ls -l $1 |awk '{print $1}'`
if [ $var == $var1 ]
then
echo "file permission check : passed" 
else
echo "file permission check : failed" 
echo "invalid : please change file permissions for $1 as 744" 
fi
elif [ -d $1 ]
then
echo "input is a directory"
var='-rwxr--r--'
ls -l $1 |awk '{OFS="|"} {print $1,$9}'|sed 1d  > abc2.tmp
echo "file permissions not as required: "
echo "please check the file_permission_check.log for details"
cat abc2.tmp |awk '{FS="|"} { if ($1 != "-rwxr--r--") print $2}' > file_permission_check.log
exit 0
else
echo "input is not a directory nor a file"
echo "pleae provide a valid name" 
fi
} 
cr_validation(){ 
grep -ni ".logon" $1 > 1.tmp
var=`awk '{FS=":"} {print $1;}' 1.tmp`
#echo $var
head -"$var" $1 >2.tmp
grep -rinw "$2" 2.tmp >3.tmp
if [ -s 3.tmp ]
then
echo "CR number check       : Passed"
else
echo "CR number check       : Failed" 
fi
} # two parameters filename and cr_number

db_hardcoding_check(){
rm db_name_check.txt
awk '{FS="/"} {print $3}' "$2" | sort -iu | grep -i '[A-Z]' > 11.log
for line in `cat 11.log`
do 
grep -i "$line" "$1" >> db_name_check.txt
done
if [ ! -s db_name_check.txt ]
then
echo "DB hardcode check     : Passed"
else
echo "DB hardcode check     : Failed"
exit 1
#echo " following database names are hard-coded at : `cat db_name_check.txt`" 
fi
} #two parameters file_name to be validated and non sec file names

#short forms of insert update and delete validation
statement_short_form_validation ()
{
grep -inw "ins" "$1" > statement_validation.log
grep -inw "del" "$1" >> statement_validation.log
grep -inw "upd" "$1" >> statement_validation.log
grep -inw "sel" "$1" >> statement_validation.log
if [ -s statement_validation.log ]
then
echo "one of the short forms sel,ins,upd,del is used in the scriptb at below lines"
echo "pleae replace them with SELECT ,INSERT,UPDATE,DELETE respectively"
`cat statement_validation.log`|cut -d ':' -f1 
else
echo "statement short form check :passed" 
fi
} #file_name is the parameter

#step5
#control M  character check
control_character_check()
{
od -x $1 | grep '0d' > control_char_check.log
if [ -s control_char_check.log ]
then 
echo "ControlM check        : Failed"
#echo "please check the log file control_char_check.log for details"
else
echo "ControlM check        : Passed" 
fi
} # one parameter file_name

#step 6
char_length_check()
{
awk '{print i++ "," length+1}' "$1" >1.log
awk '{FS=","} {if($2>=80) print $1+1;}' 1.log > 2.log
if [ ! -s 2.log ]
then
echo "Char length check     : Passed"
else
echo "Char length check     : Failed"
echo "Script failed as the number of characters are exceeding 80"
exit 1
fi
} #one parameter file name

# echo "enter the file name to be validated"
# read file_name

# echo "enter the cr number"
# read cr_no

# echo "enter the non_sec file name"
# read non_sec_file

echo " ================================= "

chmod 744 $1

#file_permission_validation $1

char_length_check $1

#control_character_check $1

#cr_validation $1 $2

db_hardcoding_check $1 $3

echo " ================================= "

exit
