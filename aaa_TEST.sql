dbcc freeproccache WITH NO_INFOMSGS; -- Throw away execution plans, among other things
dbcc dropcleanbuffers; -- Empty the (block) buffer cache

GO

SET STATISTICS TIME, IO ON;

GO

SELECT DISTINCT(id) FROM innheimta.dbo.vidskiptamadur WHERE id = 470;

GO

SELECT last_worker_time, last_elapsed_time, last_rows, last_logical_reads, last_physical_reads, last_logical_writes, execution_count, query_string
FROM sys.dm_exec_query_stats
CROSS APPLY (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
	(CASE WHEN statement_end_offset = -1
	THEN LEN(CONVERT(nvarchar(MAX),text)) * 2
	ELSE statement_end_offset
	END - statement_start_offset)/2) AS query_string
	FROM sys.dm_exec_sql_text(sql_handle)
	) AS query_text
