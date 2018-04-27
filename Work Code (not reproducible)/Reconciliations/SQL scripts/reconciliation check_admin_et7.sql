use Apacsale_Reconciliation

declare @startdate datetime = 'xxxstartdatexxx'
declare @enddate datetime = 'xxxenddatexxx'

select  distinct 
			DATEADD(dd, DATEDIFF(dd, 0, createddate), 0) dates,
			createddate createddatetime,
			lower(id) uniqueid,
			countryid com,
			7 et

from Users

where
	isdeleted = 0
	and createddate >= @startdate
	and createddate < @enddate
	and countryid not in ('WS','NS','AO','3A','3N','CM','GE','NW','PW','TP')
	and (groupID != '9d432b6b-d63e-446f-a556-d7923216d9af')
	

