#-----------------------------------------------------------------------------------------------
#
# Introduction
#-----------------------------------------------------------------------------------------------
library(readxl)
library(excel.link)
setwd('C:/Users/JaredGoh/Desktop/Working Enviroment/Fraud/Ad hoc Fraud investigations/Effect of resetting passwords for old accounts')
source('C:/Users/JaredGoh/Desktop/Working Enviroment/load_utility_codes_new.R')

## Data is taking from 'resetting based on account age.xlsx'

# Calculating total_registrations by account age
# Calculating plotdata 
basedata = read_excel('resetting based on account age.xlsx', sheet = 'basedata') %>% 
  mutate(totalbuyer_rev = firstbuyer_rev + repeatbuyer_rev)

rev_mth = basedata %>%
  group_by(createddate_aest) %>%
  summarise(monthly_rev = sum(totalbuyer_rev))


plotdata = basedata %>% filter(!is.na(account_age)) %>% 
  left_join(rev_mth, by = c('createddate_aest')) %>%
  mutate(`pct of totalbuyer rev` = round(totalbuyer_rev / monthly_rev * 100,2),
         `pct of firstbuyer rev` = round(firstbuyer_rev / monthly_rev * 100,2),
         `pct of repeatbuyer rev` = round(repeatbuyer_rev / monthly_rev * 100,2)) %>% 
  arrange(createddate_aest,desc(account_age)) %>% group_by(createddate_aest) %>%
  mutate(`pct cumulative totalbuyer` = cumsum(`pct of totalbuyer rev`),
         `pct cumulative firstbuyer` = cumsum(`pct of firstbuyer rev`),
         `pct cumulative repeatbuyer` = cumsum(`pct of repeatbuyer rev`)) %>%
  ungroup()


# reg_accountage = basedata %>% filter(!is.na(account_age), createddate_aest == as.POSIXct('2018-04-01', tz = 'UTC')) %>% 
#   select(account_age, total_registrations) %>% group_by(account_age) %>%
#   summarise(total_reg = sum(total_registrations))

  
# Calculating registrations by if you bought before
  
  basedata_reg = read_excel('resetting based on account age.xlsx', sheet = 'basedata_reg') %>%
    arrange(desc(account_age))%>% mutate(summed_reg = neverboughtbefore + boughtbefore)
  
  total_reg = sum(basedata_reg$summed_reg)
  
  reg_accountage = data.frame(basedata_reg,total_reg) %>%
    mutate(`cumulative neverboughtbefore` = cumsum(`neverboughtbefore`),
           `cumulative boughtbefore` = cumsum(`boughtbefore`),
           `pct cumulative neverboughtbefore` = round(`cumulative neverboughtbefore`/`total_reg`*100,2),
           `pct cumulative boughtbefore` = round(`cumulative boughtbefore`/`total_reg`*100,2))
# outputs    
  
  xl.workbook.open('resetting based on account age.xlsx')
  xl.sheet.activate('R output')
  xlc[a1] = plotdata
  xl.sheet.activate('total_registrations')
  xlc[a1] = reg_accountage
  

  
  
  
  
  
#-----------------------------------------------------------------------------------------------
#
# Plotting cumulative pct of totalbuyer monthly revenue by account age
#----------------------------------------------------------------------------------------------- 

plotdata %>%
  ggplot() +
  geom_point(aes(x = account_age, y = `pct cumulative totalbuyer`, group = createddate_aest, col = as.factor(createddate_aest))) + 
  geom_smooth(aes(x = account_age, y = `pct cumulative totalbuyer`, group = createddate_aest, col = as.factor(createddate_aest)), se = FALSE) +
    
  geom_point(data = plotdata %>% select(account_age, `pct cumulative totalbuyer`) %>% 
              group_by(account_age) %>% summarise(`pct cumulative totalbuyer` = mean(`pct cumulative totalbuyer`)),
             aes(x = account_age, y = `pct cumulative totalbuyer`)) +
    
  geom_text(data = plotdata %>% select(account_age, `pct cumulative totalbuyer`) %>% 
              group_by(account_age) %>% summarise(`pct cumulative totalbuyer` = round(mean(`pct cumulative totalbuyer`),2)),
            aes(x = account_age, y = `pct cumulative totalbuyer`, 
                label = `pct cumulative totalbuyer`), position = position_nudge(y = -5)) +
    
  scale_x_reverse() + scale_colour_discrete(name = 'revenue months') +
  labs(title = 'Cumulative % of totalbuyer monthly revenue by account age')#,
      # x = 'Quartile Loss',
      # y = 'Value')
   

#-----------------------------------------------------------------------------------------------
#
# Plotting cumulative pct of firstbuyers monthly revenue by account age
#----------------------------------------------------------------------------------------------- 

plotdata %>%
  ggplot() +
  geom_point(aes(x = account_age, y = `pct cumulative firstbuyer`, group = createddate_aest, col = as.factor(createddate_aest))) + 
  geom_smooth(aes(x = account_age, y = `pct cumulative firstbuyer`, group = createddate_aest, col = as.factor(createddate_aest)), se = FALSE) +
    
  geom_point(data = plotdata %>% select(account_age, `pct cumulative firstbuyer`) %>% 
              group_by(account_age) %>% summarise(`pct cumulative firstbuyer` = mean(`pct cumulative firstbuyer`)),
             aes(x = account_age, y = `pct cumulative firstbuyer`)) +
    
  geom_text(data = plotdata %>% select(account_age, `pct cumulative firstbuyer`) %>% 
              group_by(account_age) %>% summarise(`pct cumulative firstbuyer` = round(mean(`pct cumulative firstbuyer`),2)),
            aes(x = account_age, y = `pct cumulative firstbuyer`, 
                label = `pct cumulative firstbuyer`), position = position_nudge(y = -0.5)) +
    
  scale_x_reverse() + scale_colour_discrete(name = 'revenue months') +
  labs(title = 'Cumulative % of firstbuyers monthly revenue by account age')#,
      # x = 'Quartile Loss',
      # y = 'Value')
  
  
#-----------------------------------------------------------------------------------------------
#
# Plotting cumulative pct of repeatbuyers monthly revenue by account age
#----------------------------------------------------------------------------------------------- 

plotdata %>%
  ggplot() +
  geom_point(aes(x = account_age, y = `pct cumulative repeatbuyer`, group = createddate_aest, col = as.factor(createddate_aest))) + 
  geom_smooth(aes(x = account_age, y = `pct cumulative repeatbuyer`, group = createddate_aest, col = as.factor(createddate_aest)), se = FALSE) +
    
  geom_point(data = plotdata %>% select(account_age, `pct cumulative repeatbuyer`) %>% 
              group_by(account_age) %>% summarise(`pct cumulative repeatbuyer` = mean(`pct cumulative repeatbuyer`)),
             aes(x = account_age, y = `pct cumulative repeatbuyer`)) +
    
  geom_text(data = plotdata %>% select(account_age, `pct cumulative repeatbuyer`) %>% 
              group_by(account_age) %>% summarise(`pct cumulative repeatbuyer` = round(mean(`pct cumulative repeatbuyer`),2)),
            aes(x = account_age, y = `pct cumulative repeatbuyer`, 
                label = `pct cumulative repeatbuyer`), position = position_nudge(y = -5)) +
    
  scale_x_reverse() + scale_colour_discrete(name = 'revenue months') +
  labs(title = 'Cumulative % of repeatbuyers monthly revenue by account age')#,
      # x = 'Quartile Loss',
      # y = 'Value')



# 
# plotdata %>%
#   ggplot() + aes(x = account_age, y = `pct cumulative`) + 
#     geom_boxplot(data = cross_validation_m4_results) +
#     geom_boxplot(data = cross_validation_m4_allcoms_results) +
#     geom_boxplot(data = cross_validation_m4_allcoms_as_results) +
#     geom_boxplot(data = cross_validation_m4_no_teamname_results) +
#     geom_boxplot(data = cross_validation_m4_no_stocktype_results) +
#     geom_boxplot(data = cross_validation_m4_no_stocktype_no_teamname_results) +
#     geom_boxplot(data = validation_m31_results) +
#   labs(title = 'Quartile Loss of Models',
#        x = 'Quartile Loss',
#        y = 'Value') +
#     guides(shape = FALSE) #+ facet_wrap(~quantile_loss, scales = 'free') 
