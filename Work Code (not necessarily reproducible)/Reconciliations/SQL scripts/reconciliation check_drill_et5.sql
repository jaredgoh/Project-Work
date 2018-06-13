select
DATE_TRUNC('day', createddatetime) dates,
createddatetime,
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
(select
CASE
	WHEN createddate >= '2018-04-01 03:00' AND createddate < '2018-10-07 02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2017-04-02T03:00' AND createddate < '2017-10-01T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2016-04-03T03:00' AND createddate < '2016-10-02T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2015-04-05T03:00' AND createddate < '2015-10-04T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2014-04-06T03:00' AND createddate < '2014-10-05T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2013-04-07T03:00' AND createddate < '2013-10-06T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2012-04-01T03:00' AND createddate < '2012-10-07T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2011-04-03T03:00' AND createddate < '2011-10-02T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2010-04-04T03:00' AND createddate < '2010-10-03T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2009-04-05T03:00' AND createddate < '2009-10-04T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2008-04-06T03:00' AND createddate < '2008-10-05T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2007-03-25T03:00' AND createddate < '2007-10-28T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2006-04-02T03:00' AND createddate < '2006-10-29T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2005-03-27T03:00' AND createddate < '2005-10-30T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2004-03-28T03:00' AND createddate < '2004-10-31T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    WHEN createddate >= '2003-03-30T03:00' AND createddate < '2003-10-26T02:00' THEN DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '10' hour)
    ELSE DATE_ADD(CAST(CONCAT(SUBSTR(createddate, 1, 10), ' ', SUBSTR(createddate, 12, 8)) as TIMESTAMP), INTERVAL '11' hour)
    END createddatetime,
	cast(id as varchar) id,
    cast(invoiceid as varchar) invoiceid,
    com,
    cast(totalproductsqty as float) totalproductsqty,
    cast(totalproductsprice as float) totalproductsprice,
    cast(totalproductscost as float) totalproductscost,
    cast(totaldeliverycharge as float) totaldeliverycharge,
    cast(totalproductstax as float) totalproductstax,
	cast(estdeliverytax as float) estdeliverytax,
	cast(estdeliverycost as float) estdeliverycost,
	cast(totalitemsdiscount as float) totalitemsdiscount,
	cast(totaldeliverydiscount as float) totaldeliverydiscount,
	cast(audrate as float) audrate,
    et
from 
	dcevents.transactions.`xxxtable_datexxx`
 where et = '5'
and cast(createddate as date) >= DATE_SUB(date 'xxxstartdatexxx', interval '1' day)
and cast(createddate as date) < DATE_ADD(date 'xxxenddatexxx', interval '1' day)
and com not in ('WS','NS','AO','CM','GE','NW','PW','TP')
and ug not in  ('U'))
where cast(createddatetime as date) >= 'xxxstartdatexxx'
and cast(createddatetime as date) < 'xxxenddatexxx'



