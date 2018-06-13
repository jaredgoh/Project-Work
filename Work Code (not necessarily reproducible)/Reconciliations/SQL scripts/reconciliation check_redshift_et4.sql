select distinct 
	date_trunc('day', CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate)) dates,
	CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate) createddatetime,
	id uniqueid,
	com,
    productsqty totalproductsqty,
	productprice*productsqty totalproductsprice,
	productcost*productsqty totalproductscost,
	producttax*productsqty totalproductstax,
	audrate,
	et
	
		
 	
from 
	dclive.transactionsxxxtable_datexxx
 where 	
   CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate) >= 'xxxstartdatexxx'
   and CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate) < 'xxxenddatexxx'
   and com not in ('WS','NS','AO','CM','GE','NW','PW','TP')
   and (ug != 'U')
   and et = 4 
   
order by 
	dates
 
