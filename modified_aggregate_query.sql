USE innheimta;

GO

dbcc freeproccache; -- Throw away execution plans, among other things
dbcc dropcleanbuffers; -- Empty the (block) buffer cache

GO

IF NOT EXISTS (
	SELECT [name] 
	FROM sys.tables
	WHERE [name] = 'performance_logging'
) CREATE TABLE performance_logging(
	id BIGINT IDENTITY,
	cpu_time_microseconds BIGINT,
	wallclock_time_microseconds BIGINT,
	rows_returned BIGINT,
	logical_reads BIGINT,
	physical_reads BIGINT,
	logical_writes BIGINT,
	execution_count BIGINT,
	query_string VARCHAR(5000)
);

GO

DECLARE @iterations INT = 5;
DECLARE @currentIteration INT = 0;

WHILE @currentIteration < @iterations
BEGIN
	SET STATISTICS TIME, IO ON;
	-- Query to measure
	--SELECT * FROM vidskiptamadur WHERE id = 470;

	-- Summa greiddra krafna einstaklinga, per útibú, eftir póstnúmeri kröfuhafa (skráning í heimilisfang hefur forgang umfram þjóðskrá) og greiðslutímabili. Fyrir svæði utan 1xx póstnúmeraseríunnar.
	SELECT
		DISTINCT k.banki, isnull( ph.postnumer, pt.postnumer ) AS Póstnúmer, YEAR( h.bokunardagur ) AS Ár, sum( CONVERT( NUMERIC(30,0), k.upphaed_til_greidslu ) ) AS Heildarupphæð
	FROM
		krafa k,
		samningur s,
		tegund_logadila tl,
		hreyfing h,
		tegund_hreyfingar th,
		thjodskra t
		LEFT OUTER JOIN postnumer pt ON ( t.postnumer_id = pt.postnumer ),
		vidskiptamadur v
		LEFT OUTER JOIN heimilisfang hf ON ( v.heimilisfang_id = hf.id )
		LEFT OUTER JOIN postnumer ph ON ( hf.postnumer_id = ph.postnumer )
	WHERE
		s.id = k.samningur_id
		AND v.id = s.vidskiptamadur_id
		AND v.kennitala = t.kennitala
		AND t.tegund_logadila_id = tl.id
		AND tl.lysing = 'Einstaklingur'
		AND pt.postnumer not like '1%' 
		AND ph.postnumer not like '1%' 
		AND k.astand_id in ( SELECT DISTINCT id FROM krafa_astand WHERE lysing = 'Greidd' )
		AND h.krafa_id = k.id
		AND h.tegund_hreyfingar_id = th.id
		AND th.lysing = 'Greiðsla'
		AND k.annar_kostnadur is null
		AND k.annar_vanskilakostnadur is null
		AND k.fyrri_afslattur is null
		AND k.seinni_afslattur is null
	GROUP BY
		k.banki, isnull( ph.postnumer, pt.postnumer ), YEAR( h.bokunardagur )
	HAVING 
		YEAR( h.bokunardagur ) > 2007
	ORDER BY 
		k.banki, isnull( ph.postnumer, pt.postnumer ), YEAR( h.bokunardagur )

	-- Store measurements
	INSERT INTO performance_logging(cpu_time_microseconds, wallclock_time_microseconds, rows_returned, logical_reads, physical_reads, logical_writes, execution_count, query_string)
	SELECT TOP 1
	q.last_worker_time, q.last_elapsed_time, q.last_rows, q.last_logical_reads, q.last_physical_reads, q.last_logical_writes, q.execution_count, t.query_string
	FROM sys.dm_exec_query_stats q
	
	CROSS APPLY
	(SELECT SUBSTRING(TEXT, statement_start_offset/2 + 1,
	(CASE WHEN statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(MAX),text)) * 2 ELSE statement_end_offset END - statement_start_offset)/2) AS query_string
	FROM sys.dm_exec_sql_text(q.sql_handle)) AS t

	ORDER BY q.last_execution_time DESC;

	--SET STATISTICS TIME, IO OFF;

	SET @currentIteration = @currentIteration + 1;
END;

GO
SELECT * FROM performance_logging ORDER BY 1 ASC;
GO
TRUNCATE TABLE performance_logging;
