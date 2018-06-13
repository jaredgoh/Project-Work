select
	date_trunc('day', CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate)) dates,
    com,
	et,
	count(1) total_event_count

    
from 
	dclive.transactionsxxxtable_datexxx
 where 	
   CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate) >= 'xxxstartdatexxx'
   and CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate) < 'xxxenddatexxx'
   and com not in ('WS','NS','AO','CM','GE','NW','PW','TP')
   and (ug != 'U')
   and et in (xxxetxxx) 

group by
	dates, com, et 
order by 
	dates


