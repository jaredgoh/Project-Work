use apacsale_reconciliation

declare @startdate datetime = 'xxxstartdatexxx'
declare @enddate datetime = 'xxxenddatexxx'


SELECT 
	
	DATEADD(dd, DATEDIFF(dd, 0, a.createddate), 0) dates,
	a.createddate createddatetime,
	a.id uniqueid,
	a.paymentid,
	a.com,
	3 et,    

    isnull(isnull(CASE
				 WHEN a.com IN ('AS','BA','CA','LA','EA','WS','OA','DA','TA','GE','HA') THEN 1
				 ELSE c.rate
			  END,
			  CASE
				 WHEN a.com IN ('AS','BA','CA','LA','EA','WS','OA','DA','TA','GE','HA') THEN 1
				 ELSE c2.rate
			  END),'') audrate,	
	   
    isnull(a.totalproductsprice,0) totalproductsprice,  
	isnull(a.totalproductstax,0) totalproductstax,
	a.totaldeliverycharge totaldeliverycharge,
	isnull(a.estdeliverytax,0) estdeliverytax,
	a.itemdiscount totalitemsdiscount,
	a.deliverydiscount totaldeliverydiscount,

	a.totalproductscost,
	isnull(a.totalproductsqty,0) totalproductsqty
	   
FROM (select
	lower(p.id) id,
	p.paymenttype paymentprovider,
	o.approveddate createddateAEST,
	o.approveddate createddate,
	lower(userID) uid,
	p.amount totalpaymentamount,
	isnull(p.paymentNo,o.ordernumber) paymentid,
	o.*,
	isnull(b.deliverydiscount,0) deliverydiscount,
	case when o.totalitemsdiscount=0 or o.totalitemsdiscount is null then ISNULL(b.itemdiscount,0) else o.totalitemsdiscount end itemdiscount
from
payments p 
join (
SELECT 
		oip.paymentID oip_paymentid,
        o.customercountryID com,
        o.orderNumber,  
		min(o.approveddate) approveddate,    
        sum(totalproductsqty) totalproductsqty,
        sum(CASE WHEN o.usePriorityMemberPrices = 0 THEN o.totalDeliveryPriceForMembers ELSE o.totalDeliveryPriceForPriorityMembers END) totaldeliverycharge,
		sum(CAST(ROUND(o.taxamount /(1 + o.taxamount)*CASE WHEN o.usePriorityMemberPrices = 0 THEN o.totalDeliveryPriceForMembers ELSE o.totalDeliveryPriceForPriorityMembers END,2,1) AS NUMERIC(36,2))) estdeliverytax,
        sum(CAST(ROUND(CASE WHEN o.usePriorityMemberPrices = 0 THEN oi.taxForMembers ELSE oi.taxForPriorityMembers END,2,1) AS NUMERIC(36,2))) totalproductstax,
        sum(CASE WHEN o.usePriorityMemberPrices = 0 THEN oi.totalItemsPriceForMembers ELSE oi.totalItemsPriceForPriorityMembers END) totalproductsprice,
		sum(totalproductscost) totalproductscost,
        sum(totaluniqueproductscount) totaluniqueproductscount,
        SUM(CASE WHEN o.usePriorityMemberPrices = 0 THEN totalitemsdiscountformembers ELSE totalitemsdiscountforprioritymembers END) totalitemsdiscount,
		count(distinct o.saleid) totalparentproductscount
FROM
	orders o 
	left join OrdersInPayments oip on oip.orderid=o.id
     LEFT JOIN (SELECT orderid,
						  SUM(isNULL (costsPrice,0)*itemscount) totalproductscost,
						  sum (isnull(originalitempriceformember,itempriceformember)*itemscount) totalitemspriceformembers, 
						  isnull(sum (originalitempriceformember*itemscount) - sum(itempriceformember*itemscount),0) totalitemsdiscountformembers,
						  sum (isnull(originalitempriceforprioritymember,itempriceforprioritymember)*itemscount) totalitemspriceforprioritymembers, 
						  isnull(sum (originalitempriceforprioritymember*itemscount) - sum(itempriceforprioritymember*itemscount),0) totalitemsdiscountforprioritymembers, 
						  SUM (itemscount) totalproductsqty,
                          COUNT(DISTINCT itemID) totaluniqueproductscount,
                          sum(isnull(taxAmount*originalitempriceformember/(1+taxAmount),0)*itemsCount) taxForMembers,
                          sum(isnull(taxAmount*originalitempriceforprioritymember/(1+taxAmount),0)*itemsCount) taxForPriorityMembers
                   FROM orderitems
                   WHERE 
				  
				   createddate>=dateadd(mm,-2,@startdate)
				   AND createddate<dateadd(mm,2,@enddate)
                   GROUP BY orderid) oi ON oi.orderid = o.id
where 
o.isdeleted=0
AND approveddate>=dateadd(mm,-2,@startdate)
AND approveddate<dateadd(mm,2,@enddate)
group by
        o.customercountryID ,
        oip.paymentid ,
		o.orderNumber) o on o.oip_paymentid=p.id
LEFT JOIN (SELECT p.paymentNo,
                          SUM(disc.deldiscountgiven) deliverydiscount,
                          SUM(disc.itemdiscountgiven) itemdiscount,
						  SUM(isNULL (amount,0)) - SUM(disc.deldiscountgiven) - SUM(disc.itemdiscountgiven) otherdiscount
                   FROM payments p
                     LEFT JOIN (SELECT vip.paymentid,
                                       SUM(CASE WHEN sp.sponsorshiptype = 5 THEN isNULL (sp.discountgiven,0) ELSE 0 END) deldiscountgiven,
                                       SUM(CASE WHEN sp.sponsorshiptype = 8 THEN isnull (sp.discountgiven,0) ELSE 0 END) itemdiscountgiven,
									   SUM(CASE WHEN sp.sponsorshiptype not in (5,8) THEN isnull (sp.discountgiven,0) ELSE 0 END) otherdiscountgiven
                                FROM vouchersinpayments vip
                                  JOIN sponsorship sp
                                    ON vip.voucherid = sp.id
                                   AND sp.isdeleted = 0
                                WHERE vip.isdeleted = 0
                                GROUP BY vip.paymentid) disc ON disc.paymentID = p.id
                   WHERE paymenttype >= 31
                   AND   paymenttype <= 33
                   AND   entrytype = 1
				   AND createddate>=dateadd(mm,-3,@startdate)
				   AND createddate<dateadd(mm,3,@enddate)
                   GROUP BY p.paymentNO) b ON b.paymentNo = p.paymentNo
where p.createddate>=@startdate
and p.createddate<@enddate
and (p.paymenttype<31 or p.paymenttype>33)
and p.isdeleted=0
and o.com not in ('WS','NS','AO','3A','3N','CM','GE','NW','PW','TP')
and p.entrytype=1
) a
  LEFT JOIN currencies c
         ON c.countryid = a.com
        AND c.month = month (a.createddateAEST)
        AND c.year = year (a.createddateAEST)
        AND c.currencyid = 'AUD'
  LEFT JOIN currencies c2
         ON c2.countryid = a.com
        AND datediff(mm,cast(cast(c2.year as varchar(50)) + '-' + cast(c2.month as varchar(50)) + '-01' as datetime),
			dateadd(mm, datediff(mm, 0, a.createddateAEST),0))=1		
        AND c2.currencyid = 'AUD'

