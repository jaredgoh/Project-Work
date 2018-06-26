#===========================================================================================#
# Reconciliation Checks for ADMIN, REDSHIFT and Drill for et3 ; et4 ; et5 ; et7 ; et8 ; et9 # 
#===========================================================================================#

#-----------------------------------------------------------------------------------------------
# 
# Usage Instructions
#-----------------------------------------------------------------------------------------------

# 1. Function sources 'Query data Function.R' and 'Feed to dashboard file Function.R' and 'Duplicate check Function.R'
# 2. Contains core logic to calculate relevant metrics e.g. revenue, margin and 
#    does row checks for data errors
# 3. Function outputs one xlsx file and one csv file 


CORE_LOGIC_FUNCTION = function (et_index,
                                et_dashboard,
                                database_index,
                                startdate,
                                enddate,
                                folder_path,
                                output_path,
                                creds,
                                dashboard_feedfile = F) {

#-----------------------------------------------------------------------------------------------
#
# Initial error handling and setting java memory 
#-----------------------------------------------------------------------------------------------  
  
# Sets java max memory to prvent out of memory issues  
options(java.parameters = "-Xmx10000m")

# Checks input data are all strings  
if(!(all(is.character(et_index), is.character(database_index),
    is.character(startdate), is.character(enddate),
    is.character(folder_path), is.character(output_path), is.list(creds)))) {

  stop('Moron, your inputs are of the wrong format. Can you not see the examples given ?')
}

# Logic not written to check 3 databases 
if(NROW(database_index) >= 3) {

  stop('Hey idiot this thing can only check TWO data sources at a time. Y u no understand dis?')
}

# Checks no duplicate values were inputted
if((any(duplicated(toupper(database_index))) | any(duplicated(tolower((et_index))))) == TRUE) {

  stop('dafuq you doing ? Stop checking something against itself')
}

#-----------------------------------------------------------------------------------------------
#
# Setting automatic parameters and sourcing functions
#-----------------------------------------------------------------------------------------------

# Sets generateddate
generateddate = Sys.time()
  
# Sets specific table year
table_year = year(startdate)

# Sources the query data function
source(file.path(folder_path,'Data Quality Checks','Reconciliations','Functions','QUERY DATA FUNCTION.R'))
source(file.path(folder_path,'Data Quality Checks','Reconciliations','Functions','Feed to dashboard file FUNCTION.R'))
source(file.path(folder_path,'Data Quality Checks','Reconciliations','Functions','Duplicate check FUNCTION.R'))

# Set up the parameters to connect Redshift
# REDSHIFT_conn <- src_postgres(dbname = 'datacollector',
#                            host = 'datawarehouse.csfctidvelp2.ap-southeast-2.redshift.amazonaws.com',
#                            port = 5439,
#                            user = creds$Redshift$user,
#                            password = creds$Redshift$password)

redshift_driver <- JDBC(driverClass = 'com.amazon.redshift.jdbc42.Driver',
                     classPath = creds$Redshift$classpath)

REDSHIFT_conn <- dbConnect(drv = redshift_driver,
                        url = 'jdbc:redshift://datawarehouse.csfctidvelp2.ap-southeast-2.redshift.amazonaws.com:5439/datacollector',
                        user = creds$Redshift$user,
                        password = creds$Redshift$password)


# Set up the parameters to connect to MS SQL
mssql_driver <- JDBC(driverClass = 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
                     classPath = creds$Admin$classpath)

ADMIN_conn <- dbConnect(drv = mssql_driver,
                        url = 'jdbc:sqlserver://192.168.79.102\\PRE',
                        user = creds$Admin$user,
                        password = creds$Admin$password)


# Set up the parameters to connect to Drill
drill_driver =  JDBC(driverClass = "org.apache.drill.jdbc.Driver",
                     classPath = creds$Drill$classpath)


tryCatch(DRILL_conn <- dbConnect(drv = drill_driver,
                     url = 'jdbc:drill:drillbit=40.126.252.146:31010,13.75.156.135:31010,40.126.243.202:3101',
                     user = creds$Drill$user,
                     password = creds$Drill$password),
           error= function(e) c('connection failed'))



#-----------------------------------------------------------------------------------------------
#
# Reading Data
#-----------------------------------------------------------------------------------------------

# Reading Data from the first database in the input parameter

basedata_1 <- map(seq_along(et_index), function(x) {

get(gsub('xxdatabasexx',database_index[1],'GET_DATA_xxdatabasexx'))(startdate = startdate,
                                                                    enddate = enddate,
                                                                    table_year = table_year,
                                                                    et = et_index[x],
                                                                    conn = get(paste(database_index[1],'_conn',sep=''))) %>%
    mutate(dates = as.Date(as.character(dates)),
           createddatetime = as.character(createddatetime)
           ) %>% replace(is.na(.),0)

}) %>% setNames(et_index)


# Reading Data from the second database in the input parameter
basedata_2 <- map(seq_along(et_index), function(x) {

get(gsub('xxdatabasexx',database_index[2],'GET_DATA_xxdatabasexx'))(startdate = startdate,
                                                                    enddate = enddate,
                                                                    table_year = table_year,
                                                                    et = et_index[x],
                                                                    conn = get(paste(database_index[2],'_conn',sep=''))) %>%
    mutate(dates = as.Date(as.character(dates)),
           createddatetime = as.character(createddatetime)
           ) %>% replace(is.na(.),0)

}) %>% setNames(et_index)


# Querying total number of non distinct events from the actual database source to check duplicates
eventcount_2 <- 
  get(gsub('xxdatabasexx',database_index[2],'EVENT_COUNT_xxdatabasexx'))(startdate = startdate,
                                                                         enddate = enddate,
                                                                         table_year = table_year,
                                                                         et = et_index,
                                                                         conn = get(paste(database_index[2],'_conn',sep=''))) %>%
  mutate(dates = as.Date(as.character(dates)),
         et = paste('et', et, sep = ''))
  


#-----------------------------------------------------------------------------------------------
#
# Full_join basedata_1 and basedata_2 for comparison
#-----------------------------------------------------------------------------------------------

analysisdata = map(seq_along(et_index), function(x) {

  full_join(basedata_1[[et_index[x]]], basedata_2[[et_index[x]]],
            by = c('dates' = 'dates',
                   'uniqueid' = 'uniqueid',
                   'com' = 'com'))
}) %>% setNames(et_index)

dash_basedata = list(basedata_1, basedata_2) %>% setNames(database_index)

#-----------------------------------------------------------------------------------------------
#
# Calculates the relevant dashboard metrics for each ET and total incidents
#-----------------------------------------------------------------------------------------------

# Initialise totalincidents to keep track of incidents for each et by day
totalincidents = c()


#----------------------------
# ET3 checks and calculations
#----------------------------
if ('et3' %in% et_index) {

  ## modifies data for dashboard output
  for (x in 1:NROW(database_index)) {

    dash_basedata[[database_index[x]]][['et3']] = dash_basedata[[database_index[x]]][['et3']] %>% group_by(dates,com) %>%
      summarise(revenue = sum((totalproductsprice - totalproductstax + totaldeliverycharge - estdeliverytax -
                               totalitemsdiscount - totaldeliverydiscount)*audrate),
                margin = sum((totalproductsprice - totalproductstax + totaldeliverycharge - estdeliverytax -
                               totalitemsdiscount - totaldeliverydiscount - totalproductscost)*audrate),
                events = n(),
                et = 'et3'
                )
  }

  ## identifies discrepancies between the 2 databases for detailed output
  analysisdata[['et3']] = analysisdata[['et3']] %>%
    mutate(audrate_diff = abs(round(audrate.x - audrate.y,2)),
           totalproductsprice_diff = abs(round(totalproductsprice.x - totalproductsprice.y,2)),
           totalproductstax_diff = abs(round(totalproductstax.x - totalproductstax.y,2)),
           totaldeliverycharge_diff = abs(round(totaldeliverycharge.x - totaldeliverycharge.y,2)),
           estdeliverytax_diff = abs(round(estdeliverytax.x - estdeliverytax.y,2)),
           totalitemsdiscount_diff = abs(round(totalitemsdiscount.x - totalitemsdiscount.y,2)),
           totaldeliverydiscount_diff = abs(round(totaldeliverydiscount.x - totaldeliverydiscount.y,2)),
           totalproductscost_diff = abs(round(totalproductscost.x - totalproductscost.y,2)),
           totalproductsqty_diff = abs(round(totalproductsqty.x - totalproductsqty.y,2))
           ) %>%
    filter((audrate_diff != 0) | is.na(audrate_diff) |
           totalproductsprice_diff != 0| is.na(totalproductsprice_diff) |
           (totalproductstax_diff >= 0.10) | is.na(totalproductstax_diff) |
           totaldeliverycharge_diff != 0 | is.na(totaldeliverycharge_diff) |
           (estdeliverytax_diff >= 0.10) | is.na(estdeliverytax_diff) |
           (totalitemsdiscount_diff >= 0.10) | is.na(totalitemsdiscount_diff) |
           totaldeliverydiscount_diff != 0 | is.na(totaldeliverydiscount_diff) |
           totalproductscost_diff != 0 | is.na(totalproductscost_diff) |
           totalproductsqty_diff != 0 | is.na(totalproductsqty_diff)) %>%
    setNames(gsub('\\.x', paste('_',tolower(database_index[1]),sep=''), names(.))) %>%
    setNames(gsub('\\.y', paste('_',tolower(database_index[2]),sep=''), names(.)))

  totalincidents = analysisdata[['et3']] %>% group_by(dates) %>% summarise(incidents = n()) %>%
   mutate(et = 'et3') %>% bind_rows(totalincidents)
}


#----------------------------
# ET4 checks and calculations
#----------------------------
if ('et4' %in% et_index) {

  ## modifies data for dashboard output
  for (x in 1:NROW(database_index)) {

    dash_basedata[[database_index[x]]][['et4']] = dash_basedata[[database_index[x]]][['et4']] %>% group_by(dates,com) %>%
      summarise(events = n(),
                et = 'et4')
  }

  ## identifies discrepancies between the 2 databases for detailed output
  analysisdata[['et4']] = analysisdata[['et4']] %>%
    mutate(audrate_diff = abs(round(audrate.x - audrate.y,2)),
           totalproductsprice_diff = abs(round(totalproductsprice.x - totalproductsprice.y,2)),
           totalproductstax_diff = abs(round(totalproductstax.x - totalproductstax.y,2)),
           totalproductscost_diff = abs(round(totalproductscost.x - totalproductscost.y,2)),
           totalproductsqty_diff = abs(round(totalproductsqty.x - totalproductsqty.y,2))
           ) %>%
    filter((audrate_diff != 0) | is.na(audrate_diff) |
           totalproductsprice_diff != 0| is.na(totalproductsprice_diff) |
           (totalproductstax_diff >= 0.10) | is.na(totalproductstax_diff) |
           totalproductscost_diff != 0 | is.na(totalproductscost_diff) |
           totalproductsqty_diff != 0 | is.na(totalproductsqty_diff)) %>%
    setNames(gsub('\\.x', paste('_',tolower(database_index[1]),sep=''), names(.))) %>%
    setNames(gsub('\\.y', paste('_',tolower(database_index[2]),sep=''), names(.)))

  totalincidents = analysisdata[['et4']] %>% group_by(dates) %>% summarise(incidents = n()) %>%
   mutate(et = 'et4') %>% bind_rows(totalincidents)
}


#----------------------------
# ET5 checks and calculations
#----------------------------
if ('et5' %in% et_index) {

  ## modifies data for dashboard output
  for (x in 1:NROW(database_index)) {

    dash_basedata[[database_index[x]]][['et5']] = dash_basedata[[database_index[x]]][['et5']] %>% group_by(dates,com) %>%
      summarise(revenue = sum((totalproductsprice - totalproductstax + totaldeliverycharge - estdeliverytax -
                               totalitemsdiscount - totaldeliverydiscount)*audrate),
                margin = sum((totalproductsprice - totalproductstax + totaldeliverycharge - estdeliverytax -
                               totalitemsdiscount - totaldeliverydiscount - totalproductscost)*audrate),
                events = n(),
                et = 'et5')
  }

  ## identifies discrepancies between the 2 databases for detailed output
  analysisdata[['et5']] = analysisdata[['et5']] %>%
    mutate(audrate_diff = abs(round(audrate.x - audrate.y,2)),
           totalproductsprice_diff = abs(round(totalproductsprice.x - totalproductsprice.y,2)),
           totalproductstax_diff = abs(round(totalproductstax.x - totalproductstax.y,2)),
           totaldeliverycharge_diff = abs(round(totaldeliverycharge.x - totaldeliverycharge.y,2)),
           estdeliverytax_diff = abs(round(estdeliverytax.x - estdeliverytax.y,2)),
           totalitemsdiscount_diff = abs(round(totalitemsdiscount.x - totalitemsdiscount.y,2)),
           totaldeliverydiscount_diff = abs(round(totaldeliverydiscount.x - totaldeliverydiscount.y,2)),
           totalproductscost_diff = abs(round(totalproductscost.x - totalproductscost.y,2)),
           totalproductsqty_diff = abs(round(totalproductsqty.x - totalproductsqty.y,2))
           ) %>%
    filter((audrate_diff != 0) | is.na(audrate_diff) |
           totalproductsprice_diff != 0| is.na(totalproductsprice_diff) |
           (totalproductstax_diff >= 0.10) | is.na(totalproductstax_diff) |
           totaldeliverycharge_diff != 0 | is.na(totaldeliverycharge_diff) |
           (estdeliverytax_diff >= 0.10) | is.na(estdeliverytax_diff) |
           (totalitemsdiscount_diff >= 0.10) | is.na(totalitemsdiscount_diff) |
           totaldeliverydiscount_diff != 0 | is.na(totaldeliverydiscount_diff) |
           totalproductscost_diff != 0 | is.na(totalproductscost_diff) |
           totalproductsqty_diff != 0 | is.na(totalproductsqty_diff)) %>%
    setNames(gsub('\\.x', paste('_',tolower(database_index[1]),sep=''), names(.))) %>%
    setNames(gsub('\\.y', paste('_',tolower(database_index[2]),sep=''), names(.)))

  totalincidents = analysisdata[['et5']] %>% group_by(dates) %>% summarise(incidents = n()) %>%
   mutate(et = 'et5') %>% bind_rows(totalincidents)
}


#----------------------------
# ET7 checks and calculations
#----------------------------
if ('et7' %in% et_index) {

  ## modifies data for dashboard output
  for (x in 1:NROW(database_index)) {

    dash_basedata[[database_index[x]]][['et7']] = dash_basedata[[database_index[x]]][['et7']] %>% group_by(dates,com) %>%
      summarise(events = n(),
                et = 'et7')
  }

  ## identifies discrepancies between the 2 databases for detailed output
  analysisdata[['et7']] = analysisdata[['et7']] %>%
    filter(is.na(createddatetime.x) | is.na(createddatetime.y)) %>%
    setNames(gsub('\\.x', paste('_',tolower(database_index[1]),sep=''), names(.))) %>%
    setNames(gsub('\\.y', paste('_',tolower(database_index[2]),sep=''), names(.)))

  totalincidents = analysisdata[['et7']] %>% group_by(dates) %>% summarise(incidents = n()) %>%
   mutate(et = 'et7') %>% bind_rows(totalincidents)
}


#----------------------------
# ET8 checks and calculations
#----------------------------
if ('et8' %in% et_index) {

  ## modifies data for dashboard output
  for (x in 1:NROW(database_index)) {

    dash_basedata[[database_index[x]]][['et8']] = dash_basedata[[database_index[x]]][['et8']] %>% group_by(dates,com) %>%
      summarise(refunds = sum((totaldiscountamount + totalpaymentamount - totaltaxamount)*audrate),
                events = n(),
                et = 'et8')
  }

  ## identifies discrepancies between the 2 databases for detailed output
  analysisdata[['et8']] = analysisdata[['et8']] %>%
    mutate(audrate_diff = abs(round(audrate.x - audrate.y,2)),
           totaldiscountamount_diff = abs(round(totaldiscountamount.x - totaldiscountamount.y,2)),
           totalpaymentamount_diff = abs(round(totalpaymentamount.x - totalpaymentamount.y,2)),
           totaltaxamount_diff = abs(round(totaltaxamount.x - totaltaxamount.y,2))
           ) %>%
    filter((audrate_diff != 0) | is.na(audrate_diff) |
           totaldiscountamount_diff != 0| is.na(totaldiscountamount_diff) |
           totalpaymentamount_diff != 0 | is.na(totalpaymentamount_diff) |
           (totaltaxamount_diff >= 0.10) | is.na(totaltaxamount_diff)) %>%
    setNames(gsub('\\.x', paste('_',tolower(database_index[1]),sep=''), names(.))) %>%
    setNames(gsub('\\.y', paste('_',tolower(database_index[2]),sep=''), names(.)))

  totalincidents = analysisdata[['et8']] %>% group_by(dates) %>% summarise(incidents = n()) %>%
   mutate(et = 'et8') %>% bind_rows(totalincidents)
}


#----------------------------
# ET9 checks and calculations
#----------------------------
if ('et9' %in% et_index) {

  ## modifies data for dashboard output
  for (x in 1:NROW(database_index)) {

    dash_basedata[[database_index[x]]][['et9']] = dash_basedata[[database_index[x]]][['et9']] %>% group_by(dates,com) %>%
      summarise(returns = sum((totaldiscountamount + totalpaymentamount - totaltaxamount)*audrate),
                events = n(),
                et = 'et9')
  }

  ## identifies discrepancies between the 2 databases for detailed output
  analysisdata[['et9']] = analysisdata[['et9']] %>%
    mutate(audrate_diff = abs(round(audrate.x - audrate.y,2)),
           totaldiscountamount_diff = abs(round(totaldiscountamount.x - totaldiscountamount.y,2)),
           totalpaymentamount_diff = abs(round(totalpaymentamount.x - totalpaymentamount.y,2)),
           totaltaxamount_diff = abs(round(totaltaxamount.x - totaltaxamount.y,2))
           ) %>%
    filter((audrate_diff != 0) | is.na(audrate_diff) |
           totaldiscountamount_diff != 0| is.na(totaldiscountamount_diff) |
           totalpaymentamount_diff != 0 | is.na(totalpaymentamount_diff) |
           (totaltaxamount_diff >= 0.10) | is.na(totaltaxamount_diff)) %>%
    setNames(gsub('\\.x', paste('_',tolower(database_index[1]),sep=''), names(.))) %>%
    setNames(gsub('\\.y', paste('_',tolower(database_index[2]),sep=''), names(.)))

  totalincidents = analysisdata[['et9']] %>% group_by(dates) %>% summarise(incidents = n()) %>%
   mutate(et = 'et9') %>% bind_rows(totalincidents)
}


#-----------------------------------------------------------------------------------------------
#
# Outputs
#-----------------------------------------------------------------------------------------------

#---------------------
# Output for dashboard
#---------------------
dash_output = map(seq_along(database_index), function(x) {

  dash_basedata[[database_index[x]]] %>% bind_rows() %>%
    gather(key = metricname, value = !!database_index[x],-c(dates,et,com)) 
   
}) %>% setNames(database_index) %>%
  Reduce(function(df1,df2) full_join(df1,df2, by = c('dates','et','com','metricname')), .) %>%
  rename(originalvalue = !!database_index[1], actualvalue = !!database_index[2]) %>% 
  mutate(originalsource = !!database_index[1],
         actualsource = !!database_index[2])
dash_output = dash_output %>% mutate(originalvalue = round(originalvalue,2),
                                     actualvalue = round(actualvalue,2))



#--------------------------------------
# Modifying to include duplicate checks 
#--------------------------------------
# function takes dash_output and combines it with
# total number of non distinct events from the actual database source

dash_output = DUPLICATE_CHECK(df_dashboard = dash_output, eventcount_2)


#----------------------------------------------------
# formating data into required csv format for feeding
#----------------------------------------------------
if (dashboard_feedfile == T) {
  
DASH_FORMAT(filename = dash_output,
            et_index = et_index,
            et_dashboard = et_dashboard,
            database_index = database_index,
            startdate = startdate,
            enddate = enddate,
            generateddate = generateddate,
            output_path = output_path)
}

#-----------------------------
# detailed output of incidents
#-----------------------------

# Outputs dates, et, number of events in both sources, number of rows with incident, and row % error
summary_events = dash_output %>% filter(metricname == 'events') %>% replace(is.na(.),0) %>% 
  select(dates,et, originalvalue, actualvalue) %>% group_by(dates, et) %>% summarise_all(sum) %>% 
  left_join(totalincidents, by = c('dates','et')) %>% replace(is.na(.),0) %>% rowwise() %>%
  mutate(`% error` = round(incidents/max(originalvalue,actualvalue)*100,2)) %>%
 rename(!!database_index[1] := originalvalue, !!database_index[2] := actualvalue)

# Outputs dates, et and row % error
confluence_page_summary = summary_events %>% select(dates,et,`% error`) %>% spread(et, `% error`) %>%
  replace(is.na(.),0)

# Outputs dates, et, metricname, original and actual value, original and actual source,
# number of rows with incident, and % error for that metric
revenue_margin_checks = dash_output %>% rowwise() %>%
  mutate(abs_diff = round(abs(originalvalue - actualvalue),2),
         `% error` = round(abs(originalvalue - actualvalue)/originalvalue*100,2))
 
# Outputs duplicates check for the actualsource database
# remember totalevents are the non distinct queries and events are the distinct queries
# note - ADMIN cannot have duplicates as MSQL must have unique rows 
duplicate_checks = dash_output %>% filter(metricname %in% c('totalevents','events')) %>%
  select(dates,com,et,metricname,actualvalue,actualsource) %>% spread(metricname, actualvalue) %>%
  mutate(duplicate_rows = totalevents - events)

# Creates excel output 
output_filename = paste(paste(paste(tolower(database_index), collapse = '_'),
                        'reconciliationchecks',
                        paste('et',paste(gsub('et','',et_index),collapse = ''),sep = ''),sep = '_'),
                        str_split(startdate,' ',2,simplify = TRUE)[1],
                        str_split(enddate,' ',2,simplify = TRUE)[1],
                        'xlsx', sep = '.')

xl.workbook.add()
xl.sheet.add(xl.sheet.name = 'confluence page summary')
xlc[a1] = confluence_page_summary
xl.sheet.add(xl.sheet.name = 'summary events')
xlc[a1] = summary_events
xl.sheet.add(xl.sheet.name = 'revenue margin checks')
xlc[a1] = revenue_margin_checks
xl.sheet.add(xl.sheet.name = 'duplicate checks')
xlc[a1] = duplicate_checks

for (i in 1:NROW(et_index)) {
  xl.sheet.add(xl.sheet.name = et_index[i])
  xlc[a1] = analysisdata[[et_index[i]]]
}

xl.sheet.delete(xl.sheet = 'Sheet1')
xl.sheet.activate('confluence page summary')
xl.workbook.save(file.path(output_path, output_filename))
xl.workbook.close()

return(dash_output)
}





  