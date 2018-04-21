USE master;
GO
RESTORE DATABASE innheimta
FROM disk = 'C:\GAG2\innheimta.Bak'
WITH REPLACE,
	MOVE 'innheimta' to 'C:\GAG2\innheimta.mdf',
	MOVE 'innheimta_Log' to 'C:\GAG2\innheimta.log'
GO
dbcc freeproccache WITH NO_INFOMSGS; -- Throw away execution plans, among other things
dbcc dropcleanbuffers WITH NO_INFOMSGS; -- Empty the (block) buffer cache
GO
