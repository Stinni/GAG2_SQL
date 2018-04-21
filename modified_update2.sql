USE innheimta;
GO
dbcc freeproccache WITH NO_INFOMSGS; -- Throw away execution plans, among other things
dbcc dropcleanbuffers WITH NO_INFOMSGS; -- Empty the (block) buffer cache
GO
-- Basic
SET STATISTICS TIME, IO ON;
GO
-- Query to run
--------------------------------------------------
	update 
		krafa
	set
		tilvisun = 'UPPF�R�_TILV�SUN'
		,sedilnumer = '1234567'
		,athugasemd_1 = 'Athugi� a� h�gt er a� grei�a inn � kr�funa � netb�nkum sem sty�ja vi� �� virkni.'
		,athugasemd_2 = 'Krafan ver�ur send � milliinnheimtu s� h�n ekki a� fullu greidd � eindaga!'
		,mynt_id = 'EUR'
	WHERE
		samningur_id in ( select id from samningur where vidskiptamadur_id = 281 )
		AND annar_kostnadur IS NULL
		AND upphaed > 1
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
GO
