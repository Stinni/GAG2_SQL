dbcc freeproccache; -- Throw away execution plans, among other things
dbcc dropcleanbuffers; -- Empty the (block) buffer cache

update 
	krafa
set
	tilvisun = 'UPPFÆRÐ_TILVÍSUN'
	,sedilnumer = '1234567'
	,athugasemd_1 = 'Athugið að hægt er að greiða inn á kröfuna í netbönkum sem styðja við þá virkni.'
	,athugasemd_2 = 'Krafan verður send í milliinnheimtu sé hún ekki að fullu greidd á eindaga!'
	,mynt_id = 'EUR'
WHERE
	samningur_id in ( select id from samningur where vidskiptamadur_id = 281 )
	AND annar_kostnadur IS NULL
	AND upphaed > 1