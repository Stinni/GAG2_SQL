dbcc freeproccache; -- Throw away execution plans, among other things
dbcc dropcleanbuffers; -- Empty the (block) buffer cache

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