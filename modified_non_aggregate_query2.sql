USE innheimta;
GO
dbcc freeproccache; -- Throw away execution plans, among other things
dbcc dropcleanbuffers; -- Empty the (block) buffer cache
GO
-- Basic
SET STATISTICS TIME, IO ON;
GO
-- Query to run
--------------------------------------------------
	-- Payee with a registered home in the greidandi table has precedence to the one in thjodskra.  
	SELECT  i.skilabod_a_greidslusedla
		,i.id
		,i.kennitala
		,i.nafn
		,ISNULL( heimili_heimili, heimili_thjodskra ) as heimili
		,ISNULL( postnumer_heimili, postnumer_thjodskra ) as postnumer
		,ISNULL( stadur_heimili, stadur_thjodskra ) as stadur
	INTO
		#Temp
	FROM
	(
		SELECT 
			g.skilabod_a_greidslusedla
			,g.id
			,t.kennitala
			,t.nafn
			,t.heimili as heimili_thjodskra
			,pt.postnumer as postnumer_thjodskra
			,pt.stadur as stadur_thjodskra
			,ph.postnumer as postnumer_heimili
			,ph.stadur as stadur_heimili
			,h.heimili_1 as heimili_heimili
		FROM
			vidskiptamadur v
			,greidandi g
			LEFT OUTER JOIN heimilisfang h ON ( g.heimilisfang_id = h.id )
			LEFT OUTER JOIN postnumer ph ON ( h.postnumer_id = ph.postnumer )
			,thjodskra t
			LEFT OUTER JOIN postnumer pt ON ( t.postnumer_id = pt.postnumer )
		WHERE
			v.id = g.vidskiptamadur_id
			AND t.kennitala = v.kennitala
	) i;
	SELECT
		k.id
		,ka.lysing as ástand
		,k.banki
		,k.hofudbok
		,k.numer
		,k.gjalddagi
		,k.eindagi
		,k.nidurfellingardagur
		,k.upphaed
		,k.tilvisun
		,k.sedilnumer
		,k.vidskiptanumer
		,vk.lysing as vanskilagjaldstegund
		,ds.lysing as dráttarvaxtastofnkóði
		,dr.lysing as dráttarvaxtaregla
		,k.mynt_id
		,m.gjaldmidill
		,gk.lysing as gengiskóði
		,grk.lysing as greiðslukóði
		,ak.lysing as afsláttarkóði
		,k.athugasemd_1
		,k.athugasemd_2
		,k.stada_tilkynningar_og_greidslugjald_1
		,k.stada_tilkynningar_og_greidslugjald_2
		,k.stada_fyrra_vanskilagjald
		,k.stada_seinna_vanskilagjald
		,k.stada_annar_kostnadur
		,k.stada_annar_vanskilakostnadur
		,k.stada_drattarvextir
		,k.stada_afslattur
		,k.upphaed_til_greidslu
		,s.visir
		,t.kennitala as kennitala_greiðanda
		,t.nafn as nafn_greiðanda
		,t.skilabod_a_greidslusedla
		,t.heimili as heimili_greiðanda
		,t.postnumer as póstnúmer_greiðanda
		,t.stadur as staður_greiðanda
	FROM
		krafa k
		LEFT OUTER JOIN vanskilagjaldskodi vk ON( k.vanskilagjaldskodi_id = vk.id )
		LEFT OUTER JOIN drattarvaxtastofnkodi ds ON( k.drattarvaxtastofnkodi_id = ds.id )
		LEFT OUTER JOIN drattarvaxtaregla dr ON( k.drattarvaxtaregla_id = dr.id )
		LEFT OUTER JOIN mynt m ON( k.mynt_id = m.id )
		LEFT OUTER JOIN gengiskodi gk ON( k.gengiskodi_id = gk.id )
		LEFT OUTER JOIN greidslukodi grk ON( k.greidslukodi_id = grk.id )
		LEFT OUTER JOIN afslattarkodi ak ON( k.afslattarkodi_id = ak.id )
		,samningur s
		,#Temp t
		,krafa_astand ka
	WHERE
		t.id = k.greidandi_id
		AND s.id = k.samningur_id
		AND ka.id = k.astand_id
		-- All scenarios
		/*AND k.samningur_id in ( select id from samningur where vidskiptamadur_id = '200' /*{1,10,40,200}*/ )*/
		-- Test each of the following scenarios separetely
		-- Scenario 1
		/*
		AND k.gjalddagi between cast('1/1/2008' as date ) and cast('1/1/2009' as date )
		AND k.astand_id in ( select id from krafa_astand where lysing = 'Greidd' )
		*/
		-- Sccenario 2
		
		-- Keep this in synch with with the customer filtering above!
		AND k.samningur_id = ( select top 1 id from samningur where vidskiptamadur_id = '1' order by id ) /*{1,10,40,200}*/
		AND k.gjalddagi between cast('1/1/2010' as date ) and cast('1/1/2013' as date )
		AND k.tilvisun IS NOT NULL
		
		-- Scenario 3
		/*
		AND k.astand_id in ( select id from krafa_astand where lysing = 'Ógreidd' )
		AND EXISTS ( SELECT * FROM hreyfing h WHERE h.krafa_id = k.id AND h.innborgunardagur IS NOT NULL AND h.tegund_hreyfingar_id in ( SELECT id FROM tegund_hreyfingar where lysing = 'Innborgun' ) )
		*/
	;
	drop table #Temp;
--------------------------------------------------
GO
SET STATISTICS TIME, IO OFF;
GO
SELECT last_worker_time AS CPU_time_microseconds, last_elapsed_time AS wallclock_time_microseconds, last_rows AS rows_returned, last_logical_reads AS logical_reads, last_physical_reads AS physical_reads, last_logical_writes AS logical_writes, execution_count, query_string
FROM sys.dm_exec_query_stats
CROSS APPLY (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
	(CASE WHEN statement_end_offset = -1
	THEN LEN(CONVERT(nvarchar(MAX),text)) * 2
	ELSE statement_end_offset
	END - statement_start_offset)/2) AS query_string
	FROM sys.dm_exec_sql_text(sql_handle)
	) AS query_text
