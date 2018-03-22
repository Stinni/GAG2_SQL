dbcc freeproccache; -- Throw away execution plans, among other things
dbcc dropcleanbuffers; -- Empty the (block) buffer cache

-- Summa greiddra krafna einstaklinga, per útibú, eftir póstnúmeri kröfuhafa (skráning í heimilisfang hefur forgang umfram þjóðskrá) og greiðslutímabili. Fyrir svæði utan 1xx póstnúmeraseríunnar.
SELECT
 distinct k.banki, isnull( ph.postnumer, pt.postnumer ) as Póstnúmer, YEAR( h.bokunardagur ) as Ár, sum( CONVERT( NUMERIC(30,0), k.upphaed_til_greidslu ) ) as Heildarupphæð 
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
	