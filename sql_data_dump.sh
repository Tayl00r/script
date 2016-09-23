#!/bin/bash

#数据库信息定义
#mysql_db="dcetl"
mysql_host="172.20.0.161"  
mysql_user="dcetl"  
mysql_pwd="dcetl"
mysql_port="3306"
currentDate=$(date +”%d-%m-%y--%h:%m:%s”)
all_viewName=""
all_dbName=""
#指定目录下面创建文件夹
mkdir mysql$currentDate
cd mysql$currentDate/


#获取服务器上的schema列表
resultSchema=$(mysql -u$mysql_user -p$mysql_pwd -h$mysql_host -P$mysql_port -e"select SCHEMA_NAME from information_schema.SCHEMATA where SCHEMA_NAME not in('information_schema','performance_schema','mysql');")
schemaname=${resultSchema#*SCHEMA_NAME}
dbarray=($schemaname)
#拼接数据库名
for i in "${!dbarray[@]}"; do
	echo ${dbarray[$i]}
	all_dbName="$all_dbName"" ""${dbarray[$i]}"
	#echo $all_dbName
	#获取服务器上的视图名称列表
	result=$(mysql -u$mysql_user -p$mysql_pwd -h$mysql_host -P$mysql_port -e"select table_name from information_schema.TABLES where TABLE_TYPE = 'VIEW' and TABLE_SCHEMA ='${dbarray[$i]}';")
	view=${result#*table_name}
	viewarray=($view)
	#echo "test1"
	now_viewName=""
	len=${#viewarray[@]}
	
	if [ $len != "0"]; then

		#echo "test2"
		#拼接--ignore-table 和视图名称
		for j in "${!viewarray[@]}"; do
			#echo ${viewarray[$j]}
			all_viewName="$all_viewName"" --ignore-table ""${dbarray[$i]}.${viewarray[$j]}"
			now_viewName="$now_viewName"" ""${viewarray[$j]}"
			echo $all_viewName
		done
		echo "===========$now_viewName========"
		mysqldump  -u$mysql_user -p$mysql_pwd -h$mysql_host -P$mysql_port ${dbarray[$i]} $now_viewName >view${dbarray[$i]}.sql
	fi
done
echo " 数据库表结构、数据导出start，开始时间[`date`]"


#导出数据库表结构、数据
echo "导出数据库表结构、数据"
mysqldump  -u$mysql_user -p$mysql_pwd -h$mysql_host -P$mysql_port --databases $all_dbName  $all_viewName --skip-lock-tables >table_data.sql

mysqldump -dt -u$mysql_user -p$mysql_pwd -h$mysql_host -P$mysql_port --all-databases -R --triggers --skip-lock-tables >fun_trigger.sql

echo "数据库导出end，结束时间[`date`]"
