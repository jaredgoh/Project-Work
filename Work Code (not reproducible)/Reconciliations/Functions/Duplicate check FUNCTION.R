#===========================================================================================#
# Reconciliation Checks for ADMIN, REDSHIFT and Drill for et3 ; et4 ; et5 ; et7 ; et8 ; et9 # 
#===========================================================================================#

#-----------------------------------------------------------------------------------------------
# 
# Usage Instructions
#-----------------------------------------------------------------------------------------------

# 1. Function is called in 'Duplicate check FUNCTION.R'
# 2. It takes variable dash_output and eventcount_2 and combines them



#-----------------------------------------------------------------------------------------------
#
# Modifying data for desired csv output 
#-----------------------------------------------------------------------------------------------

DUPLICATE_CHECK = function(df_dashboard, eventcount_2) {

output = df_dashboard %>% filter(metricname == 'events') %>% mutate(metricname = 'totalevents') %>%
  left_join(eventcount_2, by = c('dates','com','et')) %>%
  mutate(actualvalue = total_event_count) %>% select(-total_event_count) %>% bind_rows(df_dashboard)

return(output)
} 
