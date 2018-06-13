#===========================================================================================#
# Reconciliation Checks for ADMIN, REDSHIFT and Drill for et3 ; et4 ; et5 ; et7 ; et8 ; et9 # 
#===========================================================================================#

#-----------------------------------------------------------------------------------------------
# 
# Usage Instructions
#-----------------------------------------------------------------------------------------------

# 1. CORE_LOGIC_FUNCTION() is the main function to call the process
# 2. It outputs one xlsx file by default
# 3. If dashboard_feedfile == T it will output a dashboard format ready csv file for feeding 
# 3. Set the relevant paremeters in the Setting manual parameters section ONLY

#setwd('C:/Users/JaredGoh/Desktop/Working Enviroment/Git Repo/data-scripts')
#setwd(here::here())
#-----------------------------------------------------------------------------------------------
# 
# Setting manual parameters 
#-----------------------------------------------------------------------------------------------

# Set your et to check
## any from ('et3','et4','et5','et7','et8','et9')
et_index = c('et3','et4','et5','et7','et8','et9')

# Set the dashboard event you want to feed too
# et = 90 for Data Reconcilication - Scheduled
# et = 91 for Data Reconciliation - Ad-hoc
et_dashboard = 90


# Set your database to check
## 2 values from ('ADMIN', 'REDSHIFT', 'DRILL')
## PLEASE put your REFERENCE DATABASE FIRST as this will be taken to be the original 
database_index = c('ADMIN','REDSHIFT')


# Set your date range 
## Date formats must be in 'yyyy-mm-dd' FOR SYDNEY TIME ZONE 
## NOTE startdate is inclusive and enddate is EXCLUSIVE
startdate = c('2018-04-19')
enddate = c('2018-04-20')

# Do you want to feed your results into the dashboard ?
dashboard_feedfile = T


#-----------------------------------------------------------------------------------------------
# 
# Setting automatic parameters and sourcing functions (customise at your own risk)
#-----------------------------------------------------------------------------------------------

# Stores path to git folder location
folder_path = system('git rev-parse --show-toplevel', intern = TRUE)

# Sources load package function and core logic function
source(file.path(folder_path,'Data Quality Checks','Reconciliations','Functions','CORE LOGIC FUNCTION.R'))
source(file.path(folder_path,'Data Quality Checks','Reconciliations','Install packages.R'))

# Stores your creds from the Documents path 
creds = read_json(paste(path.expand('~'),'\\creds.json', sep = ''))


# Set your file output path
## this output path specifies where the xlsx file will be saved to
output_path = file.path(folder_path,'Data Quality Checks','Reconciliations')


#-----------------------------------------------------------------------------------------------
# 
# Calling the function
#-----------------------------------------------------------------------------------------------
start.time <- Sys.time()

dash_output = CORE_LOGIC_FUNCTION (et_index = et_index,
                                   et_dashboard = et_dashboard,
                                   database_index = database_index,
                                   startdate = startdate,
                                   enddate = enddate,
                                   folder_path = folder_path,
                                   output_path = output_path,
                                   creds = creds,
                                   dashboard_feedfile = dashboard_feedfile)


end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken



