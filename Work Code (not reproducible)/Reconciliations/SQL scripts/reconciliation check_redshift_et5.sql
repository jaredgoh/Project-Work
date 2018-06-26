select distinct
	date_trunc('day', CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate)) dates,
	CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate) createddatetime,
	id uniqueid,
	invoiceid,
	com,
	et,
	audrate,

	totalproductsprice,
	totalproductstax,
	totaldeliverycharge,
	estdeliverytax,
	totalitemsdiscount,
	totaldeliverydiscount,

	totalproductscost,
	totalproductsqty

from 
	dclive.transactionsxxxtable_datexxx
 where 	
   CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate) >= 'xxxstartdatexxx'
   and CONVERT_TIMEZONE('UTC','Australia/Sydney',createddate) < 'xxxenddatexxx'
   and com not in ('WS','NS','AO','CM','GE','NW','PW','TP')
   and (ug != 'U')
   and et = 5

order by 
	dates




