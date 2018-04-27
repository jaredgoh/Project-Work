#===========================================================================================#
# Getting latitude and longtitudes from postcode for locations and plotting it on a map     # 
#===========================================================================================#


#folder_path = system('git rev-parse --show-toplevel', intern = TRUE)
setwd('C:/Users/JaredGoh/Desktop/Ahead of the Curve/R secrets Github Repo/R-secrets/Geospatial plotting/plotting project')
#source('C:/Users/JaredGoh/Desktop/Working Enviroment/load_utility_codes_new.R')
library(ggmap)
library(tidyverse)
library(readxl)

#-----------------------------------------------------------------------------------------------
#
# Reading Data
#-----------------------------------------------------------------------------------------------

excel_sheets(path = 'locations to plot.xlsx')

# reading data for macdonalds locations
basedata_mac = read_excel('locations to plot.xlsx', sheet = 'Macdonalds') %>% 
  mutate(postcode = str_extract(Address, '[sS]ingapore \\d{6}$')) %>% filter(!is.na(postcode))
# checking if any row doesnt have postcode in the standard format 
test = basedata_mac[-grep('[sS]ingapore \\d{6}$',basedata_mac$postcode),]


# reading data for gv locations
basedata_gv = read_excel('locations to plot.xlsx', sheet = 'GV') %>%
  mutate(postcode = str_extract(Address, '[sS]ingapore \\d{6}$')) %>% filter(!is.na(postcode))
  

# reading data for koi locations
basedata_koi = read_excel('locations to plot.xlsx', sheet = 'Koi') %>%
  mutate(postcode = str_extract(Address, '[sS]ingapore \\d{6}|[sS]\\(\\d{6}\\)'),
         postcode = str_replace(postcode, '[sS]\\((\\d{6})\\)', 'Singapore \\1')) %>% filter(!is.na(postcode))

test = basedata_koi[-grep('[sS]ingapore \\d{6}$',basedata_koi$postcode),]






#-----------------------------------------------------------------------------------------------
#
# Data Wrangling
#-----------------------------------------------------------------------------------------------

inputlist = list(macdonalds = basedata_mac, gv = basedata_gv, koi = basedata_koi) 

plotdata = map(inputlist, function(i) {

d = i$postcode

out = map(d, function(i) {
  gcd = geocode(i, output = 'latlona', source = 'google')

  while (all(is.na(gcd))) {
    gcd = geocode(i, output = 'latlona', source = 'google')
  }
  data.frame(input_postcode = i, lon = gcd$lon, lat = gcd$lat)
  })

postcode_lonlat = reduce(out, rbind)    
data.frame(address = i$Address,postcode_lonlat)      
      
})
save.image()    

#-----------------------------------------------------------------------------------------------
#
# Plotting Data
#-----------------------------------------------------------------------------------------------

map <- get_map(location = 'Singapore', zoom = 11, color = 'bw')

ggmap(map) + 
  geom_point(data = plotdata$macdonalds, aes(x =lon, y= lat, col = 'blue')) +
  geom_point(data = plotdata$gv, aes(x =lon, y=lat, col = 'green')) +
  geom_point(data = plotdata$koi, aes(x =lon, y=lat, col = 'magenta')) +
  scale_colour_manual(name = 'colour legend', 
         values =c('blue'='blue','green'='green', 'magenta'='magenta'), labels = c('Macdonalds','GV','Koi')) +
  labs( title = 'You Hungry For A Movie ?')



