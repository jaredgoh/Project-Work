
use apacsale_reconciliation

declare @startdate datetime = 'xxxstartdatexxx'
declare @enddate datetime = 'xxxenddatexxx'


SELECT 

	DATEADD(dd, DATEDIFF(dd, 0, a.createddate), 0) dates,
	a.createddate createddatetime,
	a.id uniqueid,
	a.invoiceid,
    a.com, 
	5 et,
	
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
	        
FROM (SELECT o.approveddate createddateAEST,
             o.customercountryID com,
             o.approveddate createddate,
			 lower(o.id) id,
             LOWER(o.customerID) uid,
             o.orderNumber paymentid,
             o.totalItemsCount totalproductsqty,
             CASE
               WHEN o.usePriorityMemberPrices = 0 THEN o.totalDeliveryPriceForMembers
               ELSE o.totalDeliveryPriceForPriorityMembers
             END totaldeliverycharge,
             CAST(ROUND(o.taxamount /(1 + o.taxamount)*CASE WHEN o.usePriorityMemberPrices = 0 THEN o.totalDeliveryPriceForMembers ELSE o.totalDeliveryPriceForPriorityMembers END,2,1) AS NUMERIC(36,2)) estdeliverytax,
             CAST(ROUND(CASE WHEN o.usePriorityMemberPrices = 0 THEN oi.taxformembers else oi.taxforprioritymembers end,2,1) AS NUMERIC(36,2)) totalproductstax,
             CASE
               WHEN o.usePriorityMemberPrices = 0 THEN CASE
               WHEN st.name = 'Service' THEN oi.totalItemsPriceForMembers - oi.totalproductscost
               ELSE oi.totalItemsPriceForMembers
             END 
			 ELSE CASE
               WHEN st.name = 'Service' THEN oi.totalItemsPriceForPriorityMembers - oi.totalproductscost
               ELSE oi.totalItemsPriceForPriorityMembers
             END END totalproductsprice,
     
             CASE
               WHEN st.name = 'Service' THEN 0
               ELSE isnull(oi.totalproductscost,0)
             END totalproductscost,
             isnull(oi.totaluniqueproductscount,0) totaluniqueproductscount,
             isnull(o.invoicenumber,isnull(o.invoiceNo,'')) invoiceid,
             o.taxamount,
	             CASE WHEN isnull(oi.totalItemsDiscountForMembers,0)=0 or isnull(oi.totalItemsDiscountForPriorityMembers,0)=0 
					THEN (CASE WHEN isnull(a.totalitemrev,0)=0 
					THEN 0 
					ELSE isnull(b.itemdiscount,0)*isnull (CASE WHEN o.usePriorityMemberPrices = 0 THEN oi.totalitemspriceformembers ELSE oi.totalitemspriceforprioritymembers END,0) / a.totalitemrev END)
					ELSE CASE WHEN  o.usePriorityMemberPrices = 0 THEN oi.totalItemsDiscountForMembers ELSE oi.totalItemsDiscountForPriorityMembers END END itemdiscount,	
             CASE WHEN isNULL (a.totalDeliveryrev,0) = 0 THEN 0 ELSE isnull (b.Deliverydiscount,0)*isnull (CASE WHEN o.usePriorityMemberPrices = 0 THEN o.totalDeliveryPriceForMembers ELSE o.totalDeliveryPriceForPriorityMembers END,0) / a.totalDeliveryrev END Deliverydiscount

      FROM orders o
        LEFT JOIN (SELECT orderid,
                          SUM(isNULL (costsPrice,0)*itemscount) totalproductscost,
						  sum (isnull(originalitempriceformember,itempriceformember)*itemscount) totalitemspriceformembers, 
						  sum (originalitempriceformember*itemscount) - sum(itempriceformember*itemscount) totalitemsdiscountformembers,
						  sum (isnull(originalitempriceforprioritymember,itempriceforprioritymember)*itemscount) totalitemspriceforprioritymembers, 
						  sum (originalitempriceforprioritymember*itemscount) - sum(itempriceforprioritymember*itemscount) totalitemsdiscountforprioritymembers,
						  sum(isnull(taxAmount*originalitempriceformember/(1+taxAmount),0)*itemscount) taxformembers,
						  sum(isnull(taxAmount*originalitempriceforprioritymember/(1+taxAmount),0)*itemscount) taxforprioritymembers,
                          COUNT(DISTINCT itemID) totaluniqueproductscount
                   FROM orderitems
                   WHERE isdeleted = 0
				   AND createddate>=dateadd(mm,-3,@startdate)
				   AND createddate<dateadd(mm,3,@enddate)
                   GROUP BY orderid) oi ON oi.orderid = o.id
        LEFT JOIN sales s
               ON s.id = o.saleid
              AND s.isdeleted = 0
        LEFT JOIN stocktypes st
               ON st.id = s.stocktypeid
              AND st.isdeleted = 0
        
      

        LEFT JOIN (SELECT od.orderNumber,
                          SUM(CASE WHEN od.usePriorityMemberPrices = 0 THEN od.totalDeliveryPriceForMembers ELSE od.totalDeliveryPriceForPriorityMembers END) totaldeliveryrev,
                          SUM(CASE WHEN od.usePriorityMemberPrices = 0 THEN od.totalItemsPriceForMembers ELSE od.totalItemsPriceForPriorityMembers END) totalitemrev
                   FROM orders od
                   WHERE od.isdeleted = 0
                   AND   od.ordernumber IS NOT NULL
				   AND approveddate>=@startdate
				   AND approveddate<@enddate
                   GROUP BY od.orderNumber) a ON a.orderNumber = o.orderNumber
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
                   GROUP BY p.paymentNO) b ON b.paymentNo = o.orderNumber
      WHERE o.approveddate >= @startdate
      AND   o.approveddate < @enddate
      AND   o.isDeleted = 0
	  AND   o.customercountryid not in ('WS','NS','AO','3A','3N','CM','GE','NW','PW','TP')
	  AND   o.approveddate is not null
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


