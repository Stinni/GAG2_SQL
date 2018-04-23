
SELECT
ph.postnumer as Póstnúmer, YEAR( h.bokunardagur ) as Ár
FROM krafa k:
k.banki (distinct)
sum( k.upphaed_til_greidslu ) as Heildarupphæð
k.annar_kostnadur is null
k.annar_vanskilakostnadur is null
k.fyrri_afslattur is null
k.seinni_afslattur is null
k.astand_id in ( SELECT DISTINCT id FROM krafa_astand WHERE lysing = 'Greidd' )

FROM samningur s:
s.id = k.samningur_id

FROM hreyfing h:
h.krafa_id = k.id
h.tegund_hreyfingar_id = 5

FROM thjodskra t:
t.tegund_logadila_id = 1

FROM (LEFT OUTER JOIN) postnumer pt ON ( t.postnumer_id = pt.postnumer ):
pt.postnumer not like '1%'

FROM vidskiptamadur v:
v.id = s.vidskiptamadur_id
v.kennitala = t.kennitala

FROM (LEFT OUTER JOIN) heimilisfang hf ON ( v.heimilisfang_id = hf.id ):

FROM (LEFT OUTER JOIN) postnumer ph ON ( hf.postnumer_id = ph.postnumer ):
ph.postnumer not like '1%'




GROUP BY
	k.banki, isnull( ph.postnumer, pt.postnumer ), YEAR( h.bokunardagur )
HAVING 
	YEAR( h.bokunardagur ) > 2007
ORDER BY 
	k.banki, isnull( ph.postnumer, pt.postnumer ), YEAR( h.bokunardagur )

/*GO
-- Statistics off
SET STATISTICS TIME, IO OFF;*/
