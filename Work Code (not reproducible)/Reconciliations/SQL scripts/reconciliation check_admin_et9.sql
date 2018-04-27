use apacsale_reconciliation
declare @startdate datetime = 'xxxstartdatexxx'
declare @enddate datetime = 'xxxenddatexxx'

select
	DATEADD(dd, DATEDIFF(dd, 0, b.createddate), 0) dates,
	b.createddate createddatetime,
	b.id uniqueid,
	isnull(b.returnid,'') returnid,
	b.com,
	9 et,
	CASE
         WHEN b.com IN ('AS','BA','CA','LA','EA','WS','OA','DA','TA','GE','HA') THEN 1
         ELSE c.rate
       END audrate,

	b.totaldiscountamount,
	b.totalpaymentamount,
	(totalpaymentamount+totaldiscountamount)*TaxPercent/(1+TaxPercent) totaltaxamount

from(
select
	   com,
	   a.id,
	   a.paymentid,
	   returnid,
	   taxpercent,

	   min(a.createddate) createddate,
	   sum(case when pseq=1 and paymenttype not in (31,32,33) then amount else 0 end) totalpaymentamount,
	   sum(case when pseq=1 and paymenttype=32 then amount else 0 end) totaldiscountamount
	   
	 
from(
SELECT 
	lower(ref.id) id,
	ref.closeddate createddate,
	p.paymentNo paymentid,
	ref.ran returnid,
	o.customercountryid com,
	p.paymenttype,
	isnull(p.amount,0) amount,
	isnull(ref.creditamount,0) totaldiscountamount,
	isnull(o.taxamount,0) taxpercent,
	isnull(ref.refundedamount,0) totalpaymentamount,
	ROW_NUMBER ( ) OVER (partition by ref.invoiceno,ref.ran,p.paymenttype order by p.createddate) pseq

  FROM returns ref
  left join returnsinpayments rip on rip.returnid=ref.id and rip.isdeleted=0
  left join payments p on p.id=rip.paymentid and p.isdeleted=0
  left join orders o on o.invoiceno=ref.invoiceno and o.isdeleted=0

  where ref.closeddate>=@startdate 
		and ref.closeddate<@enddate
		and ref.returnstatus = 2 
		and ref.isdeleted =0
		and p.paymentno is not null
  ) a

  group by
	id,
	paymentid,
	taxpercent,
	com,
	returnid
	
 )b
 LEFT JOIN currencies c
         ON c.countryid = b.com
        AND c.month = month (b.createddate)
        AND c.year = year (b.createddate)
        AND c.currencyid = 'AUD'
 LEFT JOIN (select paymentNo, min(paymenttype) paymentprovider from payments where entrytype = 1 group by paymentNo) a2 on b.paymentid = a2.paymentNo
 	
where
	b.com not in ('WS','NS','AO','3A','3N','CM','GE','NW','PW','TP')

 

