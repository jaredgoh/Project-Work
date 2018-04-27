use apacsale_reconciliation

declare @startdate datetime = 'xxxstartdatexxx'
declare @enddate datetime = 'xxxenddatexxx'
		
select
	DATEADD(dd, DATEDIFF(dd, 0, b.createddate), 0) dates,
	b.createddate createddatetime,
	b.id uniqueid,
	b.refundid,
	b.com,
	8 et,
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
	   refundid,
	   taxpercent,
	   
	   min(a.createddate ) createddate,
	   sum(case when pseq=1 and paymenttype not in (31,32,33) then amount else 0 end) totalpaymentamount,
	   sum(case when pseq=1 and paymenttype=32 then amount else 0 end) totaldiscountamount
	   

from(
SELECT 
	lower(ref.id) id,
	ref.createddate,
	p.paymentNo paymentid,
	isnull(ref.refundnumber,'')  refundid,
	ref.customercountryid com,
	p.paymenttype,
	p.amount,
	ref.totaldiscountamount,
	isnull(o.taxamount,0) taxpercent,
	ref.totalamountforpay totalpaymentamount,
	ROW_NUMBER ( ) OVER (partition by ref.id,p.paymenttype order by p.createddate) pseq

  FROM Refunds ref
  left join refundsinpayments rfip ON ref.id=rfip.refundid and rfip.isdeleted=0
  left join payments p ON rfip.paymentid = p.id and p.isdeleted=0 
  left join orders o on ref.orderid=o.id and o.isdeleted=0

  where 
    ref.createddate>=@startdate
	and ref.createddate<@enddate
	and ref.isdeleted=0
	and p.paymentno is not null
  ) a
  group by
	id,
	paymentid,
	taxpercent,
	com,
	refundid  
)b
 LEFT JOIN currencies c
         ON c.countryid = b.com
        AND c.month = month (b.createddate)
        AND c.year = year (b.createddate)
        AND c.currencyid = 'AUD'
 LEFT JOIN (select paymentNo , min(paymenttype) paymentprovider from payments where entrytype = 1 group by paymentNo) a2 on b.paymentid = a2.paymentNo
 
where
	b.com not in ('WS','NS','AO','3A','3N','CM','GE','NW','PW','TP')

















