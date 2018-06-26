use Apacsale_Reconciliation

declare @startdate datetime = 'xxxstartdatexxx'
declare @enddate datetime = 'xxxenddatexxx'


select
dates,
createddatetime,
uniqueid,
com,
totalproductsqty,
totalproductsprice,
totalproductscost,
totalproductstax,
isnull(isnull(CASE
				 WHEN a.com IN ('AS','BA','CA','LA','EA','WS','OA','DA','TA','GE','HA') THEN 1
				 ELSE c.rate
			  END,
			  CASE
				 WHEN a.com IN ('AS','BA','CA','LA','EA','WS','OA','DA','TA','GE','HA') THEN 1
				 ELSE c2.rate
			  END),'') audrate,
4 et

from
(select distinct 
		lower(oi.id) uniqueid,
		o.customercountryid com,
		DATEADD(dd, DATEDIFF(dd, 0, approveddate), 0) dates,
		min(approveddate) createddatetime,
		sum(itemscount) totalproductsqty,
		sum(case when o.useprioritymemberprices = 0 
				then isnull(originalitempriceformember,itempriceformember)*itemscount
				else isnull(originalitempriceforprioritymember,itempriceforprioritymember)*itemscount end) totalproductsprice,
		sum(isnull(costsprice,0)*itemscount) totalproductscost,
		sum(case when o.useprioritymemberprices = 0 
				then isnull(oi.taxAmount*originalitempriceformember/(1+oi.taxAmount),0)*itemscount 
				else isnull(oi.taxAmount*originalitempriceforprioritymember/(1+oi.taxAmount),0)*itemscount end) totalproductstax
	from orders o
	left join orderitems oi on oi.orderid = o.id and oi.isdeleted=0 
	where o.isdeleted = 0
		and approveddate >= @startdate
		and approveddate < @enddate
		and customercountryid not in ('WS','NS','AO','3A','3N','CM','GE','NW','PW','TP')
	group by
	DATEADD(dd, DATEDIFF(dd, 0, approveddate), 0),o.customercountryid,lower(oi.id)
) a

LEFT JOIN currencies c
         ON c.countryid = a.com
        AND c.month = month (a.createddatetime)
        AND c.year = year (a.createddatetime)
        AND c.currencyid = 'AUD'
LEFT JOIN currencies c2
         ON c2.countryid = a.com
        AND datediff(mm,cast(cast(c2.year as varchar(50)) + '-' + cast(c2.month as varchar(50)) + '-01' as datetime),
			dateadd(mm, datediff(mm, 0, a.createddatetime),0))=1		
        AND c2.currencyid = 'AUD'