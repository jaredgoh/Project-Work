#===========================================================================================#
# Reconciliation Checks for ADMIN, REDSHIFT and Drill for et3 ; et4 ; et5 ; et7 ; et8 ; et9 # 
#===========================================================================================#

#-----------------------------------------------------------------------------------------------
# 
# Usage Instructions
#-----------------------------------------------------------------------------------------------

# 1. Function is called in 'CORE LOGIC FUNCTION.R' 
# 2. It takes variable dash_output and creates a csv that can be fed into Data Collector


#-----------------------------------------------------------------------------------------------
#
# Modifying data for desired csv output 
#-----------------------------------------------------------------------------------------------

DASH_FORMAT = function(filename, 
                       et_index,
                       et_dashboard,
                       database_index, 
                       startdate, 
                       enddate,
                       generateddate,
                       output_path) {

accountid <- '667fa4a4-b3f0-4391-b740-a26db510c2d7'
eventid <- 'e79c98f8-f777-4416-b13a-65446f079147'
et <- et_dashboard  

generateddate = paste(str_split(generateddate,' ', simplify = TRUE)[1], 
                      'T', 
                      str_split(generateddate,' ', simplify = TRUE)[2],
                      '.000000Z', sep = '')


output =  filename %>% rename(eventcompared = et) %>% rowwise() %>% 
  mutate(createddate = paste(as.character(dates), 'T00:00:00.000000Z', sep = ''),
         eventenqueuedutctime = createddate,
         generateddate = generateddate,
         accountid = accountid,
         eventid = eventid,
         et = et,
         dates_guid = gsub('-','',dates),
         et_guid = gsub('et','',eventcompared),
         et_guid = ifelse(nchar(et_guid < 4), str_pad(et_guid, 4, side = 'left', pad = 0), str_sub(et_guid,1,4)),
         originalsource_guid = paste(charToRaw(str_sub(originalsource,1,2)), collapse = ''),
         actualsource_guid = paste(charToRaw(str_sub(actualsource,1,2)), collapse = ''),
         com_guid = paste(charToRaw(com), collapse = ''),
         metricname_guid = paste(charToRaw(str_sub(metricname,1,4)), collapse = ''),
         metricname_guid = paste(metricname_guid, com_guid, sep = ''),
         #metricname_guid = ifelse(nchar(metricname) < 10,
         #                        str_pad(metricname, 10, side = 'left', pad = 0), str_sub(metricname,1,10)),
         #metricname_guid = paste(metricname_guid, com, sep = ''),
         id = paste(dates_guid, et_guid, originalsource_guid, actualsource_guid,
                    metricname_guid, sep = '-')) %>%
  select(id, createddate, eventenqueuedutctime, generateddate, accountid, eventid, et, com,
         metricname, eventcompared, originalvalue, actualvalue, originalsource, actualsource) %>%
  # modifying value output cause csv is too fking dumb to realise when not to use sf notation
  mutate(originalvalue = as.character(originalvalue),
         actualvalue = as.character(actualvalue))

# defining csv name 
output_filename = paste(paste(paste(tolower(database_index), collapse = '_'),
                        'reconchecks_feedcsv',
                        paste('et',paste(gsub('et','',et_index),collapse = ''),sep = ''),sep = '_'),
                        startdate,
                        enddate,
                        'csv', sep = '.') 

write_csv(output, file.path(output_path,output_filename), na = '')

}


