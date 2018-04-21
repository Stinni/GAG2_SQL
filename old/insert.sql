dbcc freeproccache; -- Throw away execution plans, among other things
dbcc dropcleanbuffers; -- Empty the (block) buffer cache

set nocount on;

declare @vskm_id int = 1;

declare @samningur_id int = ( select top 1 id from samningur where vidskiptamadur_id = @vskm_id order by id );
declare @astand_id int = ( select top 1 id from krafa_astand order by id );
declare @greidandi_id bigint = ( select top 1 id from greidandi where samningur_id = @samningur_id order by id);
declare @banki int = 101;
declare @hofudbok int = 66;
declare @numer int = 1;
declare @gjalddagi date = cast('1/1/2013' as date );
declare @eindagi date = cast( '1/15/2013' as date );
declare @nidurfellingardagur date = cast( '1/1/2017' as date );
declare @upphaed numeric(18,2) = 1001;
declare @tilvisun nvarchar(16) = 'PRÓFUN_EYÐA';
declare @vanskilagjaldskodi_id nvarchar(1) = (select top 1 id from vanskilagjaldskodi order by id ) ;
declare @drattarvaxtastofnkodi nvarchar(1) = ( select top 1 id from drattarvaxtastofnkodi order by id );  
declare @drattarvaxtaregla_id nvarchar(1) = ( select top 1 id from drattarvaxtaregla order by id );
declare @mynt nvarchar(3) = ( select top 1 id from mynt order by 1 );
declare @gengiskodi_id nvarchar(1) = ( select top 1 id from gengiskodi order by 1 );
declare @greidslukodi_id nvarchar(1) = ( select top 1 id from greidslukodi order by 1 );
declare @afslattarkodi int = ( select top 1 id from afslattarkodi order by 1 );

declare @index int = 0;
declare @timeTotal bigint = 0;
declare @iterations int = 1000;

while( @index < @iterations )
begin
	insert into krafa ( samningur_id, astand_id, greidandi_id, banki, hofudbok, numer, gjalddagi, eindagi, nidurfellingardagur, upphaed, tilvisun, vanskilagjaldskodi_id
	,drattarvaxtastofnkodi_id, drattarvaxtaregla_id, mynt_id, gengiskodi_id, greidslukodi_id, afslattarkodi_id
	,stada_tilkynningar_og_greidslugjald_1, stada_tilkynningar_og_greidslugjald_2, stada_fyrra_vanskilagjald, stada_seinna_vanskilagjald, stada_annar_kostnadur
	,stada_annar_vanskilakostnadur, stada_drattarvextir, stada_afslattur, upphaed_til_greidslu )
	values
	(
		@samningur_id, @astand_id, @greidandi_id, @banki, @hofudbok, @numer, @gjalddagi, @eindagi, @nidurfellingardagur, @upphaed, @tilvisun, @vanskilagjaldskodi_id
		,@drattarvaxtastofnkodi, @drattarvaxtaregla_id, @mynt, @gengiskodi_id, @greidslukodi_id, @afslattarkodi
		,0, 0, 0, 0, 0, 0, 0, 0, @upphaed
	);
	set @index += 1;
	set @numer += 1;
end;
PRINT 'Iterations: ' + convert( nvarchar, @iterations );


set nocount off;
delete krafa where tilvisun = 'PRÓFUN_EYÐA'; -- You should perform this cleanup in order for all other measurements to remain unchanged.
