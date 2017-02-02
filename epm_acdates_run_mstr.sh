#!/bin/ksh
############################################################################
#                                                                          #
# Name:   epm_acdates_run_mstr.sh                                          #
#                                                                          #
# Description: First step of GPI run process to calculate the dates        #
#              for the GPI Run based on the key date ( run_dt )            #
#                                                                          #
#                                                                          #
############################################################################
# Date        By         Modification                                      #
# __________  __________ ________________________________________________  #
# 09/14/2016  T89228[OK] QA:CHG0162867 PROD:CHG0162868 Release 12 Changes  #
# 10/27/2016  T81657[SV] QA:CHG0167414 PROD:CHG0167415 Final run ACDATES   #
#                                    		 	update issue fix   		   #
# 02/02/2017  T83049[RM] QA:CHG0167414 PROD:CHG0167415 Final run ACDATES   #
############################################################################

date +"*** `basename $0` Executing  %Y%m%d %T"

set -e
trap 'exit_rtn' ERR

function exit_rtn
{
dbcrc=$?
if test $dbcrc -eq 0
then
  exit 0
else
  echo "Error found... $epm_script terminating"
  exit $dbcrc
fi
}


echo " "
echo "EPM_PGM_DIR is $EPM_PGM_DIR"
echo "EPM_SEC_DIR is $EPM_SEC_DIR"
echo "EPM_TEMPFILS_DIR is $EPM_TEMPFILS_DIR"
echo " "

#TWS_SCHED_ALIAS=`echo $UNISON_JOB |cut -f1 -d'.' |cut -f2 -d'#'`
#TWS_SCHED=`echo $UNISON_JOB |sed -e "s,${TWS_SCHED_ALIAS},${UNISON_SCHED},g"`


run_day=$(date +"%a")
echo RUN_DAY: $run_day

if [ $run_day == "Fri" ]; 
then   
	rpt_ver_cd="F"
	echo "Final Run REPORT VERSION CODE IS : $rpt_ver_cd"
	## new year check ##
	mth=$(date +"%m")
	if [ $mth == "01" ];
	then 
		echo "It is January, Run is for previous year December"
		yr=$(( `date +'%Y'` - 1 ))
		mnth="12"
		pst_per=$yr$mnth
		echo "PST PER ${pst_per}"
	else
		pst_per=$(( `date +'%Y%m'` - 1))
		echo "PST PER ${pst_per}"
	fi
elif [ $run_day == "Tue" ]; 
then
	rpt_ver_cd="A"
	echo "Accrual Run REPORT VERSION CODE IS : $rpt_ver_cd"
	pst_per=$((`date +'%Y%m'`))
	echo "PST PER ${pst_per}"
else
echo "Not a Valid day for run"
fi

#sed  -f $epm_nonsec_fil -f $epm_sec_fil \
#sed-f '/apps/dev/epm/files/epm_nonsec.fil' -f '/home/t83049/sec/epm_sec.fil'
sed -e "s,&pst_per,${pst_per},g" \
    -e "s,&rpt_ver_cd,${rpt_ver_cd},g" \
    -e "s,__LOGNAME__,${LOGNAME},g" \
    -e "s,__TWS_SCHED__,$TWS_SCHED,g" \
/home/t83049/devops/`basename $0 .sh`.btq > /home/t83049/devops/`basename $0 .sh`_btq.tmp
bteq < /home/t83049/devops/DDL.btq
bteq < /home/t83049/devops/`basename $0 .sh`_btq.tmp

rm /home/t83049/devops/`basename $0 .sh`_btq.tmp
 
date +"*** `basename $0` Completed  %Y%m%d %T"

exit 0
