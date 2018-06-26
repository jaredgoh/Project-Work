#================================================#
# Data Query Functions for Reconciliation Checks # 
#================================================#


#-----------------------------------------------------------------------------------------------
# 
# Usage Instructions
#-----------------------------------------------------------------------------------------------

# 1. Function is called in 'CORE LOGIC FUNCTION.R'
# 2. Used to query either admin, drill or redshift databases
# 3. Function comprises of GET_DATA_ADMIN, GET_DATA_DRILL and GET_DATA_REDSHIFT functions


#-----------------------------------------------------------------------------------------------
#
# Running SQL script for Admin 
#-----------------------------------------------------------------------------------------------

GET_DATA_ADMIN = function(startdate, enddate, table_year, et, conn) {

filename =  file.path(folder_path,'Data Quality Checks','Reconciliations', 'SQL scripts','reconciliation check_admin_xxxetxxx.sql')  
#filename = c("Data Quality Checks/Reconciliations/SQL scripts/reconciliation check_admin_xxxetxxx.sql")
filename = gsub("xxxetxxx", et, filename)


SQLquery = read_file(filename) %>% paste(collapse="")
SQLquery = gsub("\t"," ", SQLquery)
SQLquery = gsub("\n"," ", SQLquery)
SQLquery = gsub("\r"," ", SQLquery)
SQLquery = gsub("xxxstartdatexxx", startdate, SQLquery)
SQLquery = gsub("xxxenddatexxx", enddate, SQLquery)

query_table <- dbGetQuery(conn, SQLquery)

output = data.frame(query_table)

return(output)

}


#-----------------------------------------------------------------------------------------------
# 
# Running SQL script for Drill
#-----------------------------------------------------------------------------------------------

GET_DATA_DRILL = function(startdate, enddate, table_year, et, conn ) {

filename =  file.path(folder_path,'Data Quality Checks','Reconciliations', 'SQL scripts','reconciliation check_drill_xxxetxxx.sql') 
#filename = c("Data Quality Checks/Reconciliations/SQL scripts/reconciliation check_drill_xxxetxxx.sql")
filename = gsub("xxxetxxx", et, filename)

mySQL = read_file(filename) %>% paste(collapse="")
mySQL = gsub("\t"," ", mySQL)
mySQL = gsub("\n"," ", mySQL)
mySQL = gsub("\r"," ", mySQL)
mySQL = gsub("xxxstartdatexxx", startdate, mySQL)
mySQL = gsub("xxxenddatexxx", enddate, mySQL)
mySQL = gsub("xxxtable_datexxx", table_year, mySQL)

output <- data.frame(dbGetQuery(conn, mySQL))

return(output)

}


#-----------------------------------------------------------------------------------------------
# 
# Running SQL script for Redshift
#-----------------------------------------------------------------------------------------------

GET_DATA_REDSHIFT = function(startdate, enddate, table_year, et, conn) {

filename =  file.path(folder_path,'Data Quality Checks','Reconciliations', 'SQL scripts','reconciliation check_redshift_xxxetxxx.sql') 
#filename = c("Data Quality Checks/Reconciliations/SQL scripts/reconciliation check_redshift_xxxetxxx.sql")
filename = gsub("xxxetxxx", et, filename)

mySQL = read_file(filename) %>% paste(collapse="")
mySQL = gsub("\t"," ", mySQL)
mySQL = gsub("\n"," ", mySQL)
mySQL = gsub("\r"," ", mySQL)
mySQL = gsub("xxxstartdatexxx", startdate, mySQL)
mySQL = gsub("xxxenddatexxx", enddate, mySQL)
mySQL = gsub("xxxtable_datexxx", table_year, mySQL)

output <- data.frame(dbGetQuery(conn, mySQL))

return(output)

}


#-----------------------------------------------------------------------------------------------
# 
# Running SQL script for Redshift Duplicate checks
#-----------------------------------------------------------------------------------------------

EVENT_COUNT_REDSHIFT = function(startdate, enddate, table_year, et, conn) {

filename =  file.path(folder_path,'Data Quality Checks','Reconciliations', 'SQL scripts','duplicate check_redshift.sql') 

# adjusting et to required format to gsub
et_sub = paste("'",et[1], sep = '')
for (i in 2:NROW(et)) {
et_sub = paste(et_sub, et[i], sep = "','")  
}
et_sub = gsub('$',"'",et_sub)
et_sub = gsub('et','',et_sub)


mySQL = read_file(filename) %>% paste(collapse="")
mySQL = gsub("\t"," ", mySQL)
mySQL = gsub("\n"," ", mySQL)
mySQL = gsub("\r"," ", mySQL)
mySQL = gsub("xxxstartdatexxx", startdate, mySQL)
mySQL = gsub("xxxenddatexxx", enddate, mySQL)
mySQL = gsub("xxxtable_datexxx", table_year, mySQL)
mySQL = gsub("xxxetxxx", et_sub,mySQL)


output <- data.frame(dbGetQuery(conn, mySQL))

return(output)

}


