/*
	PROCEDURA 1:
	
	Procedura koja proverava da li je za vozilo koje je parkirano na konkretnom parkiralistu
	parking vazeci, odnosno da li je isteklo vreme parkiranja.
	Za potrebe ove procedure koristi se funkcija provera_isteka, kojoj se prosledjuju:
		-datum parkiranja vozila,
		-vreme pocetka parkiranja,
		-vreme kraja parkiranja,
		-vreme provere isteka,
		-datum provere parkiranja,
		-dnevna karta(1-dozvoljena, 0-nije dozvoljena)
	Procedura ce ispisivati rezultat u obliku:
		Za vozilo <registracija> parking je <istekao/nije istekao> 
*/

IF OBJECT_ID ('ParkingServis.pc_provera_park','P') IS NOT NULL
	DROP PROC ParkingServis.pc_provera_park;
GO
CREATE PROC ParkingServis.pc_provera_park
(
	@registracija as varchar(11),
	@parkiraliste as int,
	@vreme_provere as time,
	@datum_provere as date
)
AS
BEGIN
	declare @datum_park as date, @vreme_pocetka as time, @vreme_kraja as time,@sluzba as int, @dnevna as bit,@reg_br as int;
	set @reg_br = (select reg_br from ParkingServis.VOZILO where reg_oznaka like '%@registracija%');
	set @datum_park = (select datum_park from ParkingServis.PARKIRANO_NA where reg_br = @reg_br and park_id = @parkiraliste);
	set @vreme_pocetka = (select vreme_pocetka from ParkingServis.PARKIRANO_NA where reg_br = @reg_br and park_id = @parkiraliste);
	set @vreme_kraja = (select vreme_kraja from ParkingServis.PARKIRANO_NA where reg_br = @reg_br and park_id = @parkiraliste);
	set @sluzba = (select distinct sluzba_id from ParkingServis.PARKIRANO_NA where park_id = @parkiraliste);
	set @dnevna = (select dnevna_karta from ParkingServis.PARKIRALISTE where park_id = @parkiraliste and sluzba_id = @sluzba);
	declare @zona as varchar(20) = (select zona from PARKIRALISTE where park_id = @parkiraliste);
	declare @isteklo int = ParkingServis.provera_isteka(@datum_park, @vreme_pocetka, @vreme_kraja, @vreme_provere, @datum_provere, @dnevna, @zona);

	declare @grad as varchar(50), @ulica as varchar(100);
	set @grad = (select grad from ParkingServis.PARKING_SLUZBA where sluzba_id = @sluzba);
	set @ulica = (select ulica from ParkingServis.PARKIRALISTE where park_id = @parkiraliste);

	if(@isteklo = 0)
		begin
			PRINT ('Za vozilo sa registarskom oznakom: '+@registracija+', parking na parkiralistu: '+@ulica+'('+@grad+'): NIJE ISTEKAO');
		end
	else if (@isteklo = 1)
		begin
			PRINT ('Za vozilo sa registarskom oznakom: '+@registracija+', parking na parkiralistu: '+@ulica+'('+@grad+'): ISTEKAO');
			EXEC ParkingServis.pc_kaznjavanje @datum_provere, @vreme_provere, @registracija, 1, @parkiraliste; 
		end
	RETURN;
END
GO

declare @date varchar(10) = '22-05-2021';
declare @d date = convert(date,@date,103);
declare @time varchar(10) = '21:17';
declare @t time = convert(time,@time,103);
EXEC ParkingServis.pc_provera_park 'NS-246-SS', 1, @t, @d;

declare @d1 as date, @t1 as time;
set @d1 = CONVERT(date,GETDATE(),103);
set @t1 = CONVERT(time,GETDATE(),103);
EXEC ParkingServis.pc_provera_park 'NS-246-SS', 1, @t1, @d1;

select * from ParkingServis.VRSTA_KAZNE;
select * from ParkingServis.KAZNA;
select * from ParkingServis.VOZILO;
select * from ParkingServis.PARKIRANO_NA;
delete from ParkingServis.KAZNA where reg_br = 2;
/*
	PROCEDURA 2:

	Procedura koja ce u slucaju da je za vozilo istekao parking izvrsiti izdavanje kazne.
	Procedura ce prihvatati registraciju vozila i vrstu kazne koja ce biti izdata.
	Koristi funkciju za proveru parkinga.
*/
IF OBJECT_ID ('ParkingServis.pc_kaznjavanje','P') IS NOT NULL
	DROP PROC ParkingServis.pc_kaznjavanje;
GO
CREATE PROC ParkingServis.pc_kaznjavanje
(
	@datum as date,
	@vreme as time,
	@vozilo as varchar(11),
	@kazna as int,
	@parkiraliste as int
)
AS
BEGIN
	declare @serijski_broj as int,@reg_br as int, @vrsta_kazne as varchar(40), @uplata as int;
	set @serijski_broj = (next value for ParkingServis.seq_serijski_broj);
	set @reg_br = (select reg_br from ParkingServis.VOZILO where reg_oznaka = @vozilo);
	set @vrsta_kazne = (select vrsta_naziv from ParkingServis.VRSTA_KAZNE where vrsta_id = @kazna);
	set @uplata = (select za_uplatu from ParkingServis.VRSTA_KAZNE where vrsta_id = @kazna);

	declare @sluzba as int = (select sluzba_id from ParkingServis.PARKIRANO_NA where park_id = @parkiraliste and reg_br = @reg_br); 

	INSERT INTO ParkingServis.KAZNA(serijski_br,vrsta_id,reg_br) VALUES (@serijski_broj,@kazna,@reg_br);
	
	PRINT ('Za vozilo sa registarskim oznakama: '+@vozilo+', izdata je kazna:');
	PRINT ('Serijski broj: ' + cast(@serijski_broj as varchar));
	PRINT ('Datum i vreme izdavanja: ' + cast(@datum as varchar) + ' ' + cast(@vreme as varchar))
	PRINT ('Vrsta kazne: '+ @vrsta_kazne);
	PRINT ('Za uplatu: '+ cast(@uplata as varchar));

	
	UPDATE ParkingServis.PARKIRANO_NA set datum_izd = @datum where reg_br = @reg_br and park_id = @parkiraliste;
	UPDATE ParkingServis.PARKIRANO_NA set vreme_izd = @vreme where reg_br = @reg_br and park_id = @parkiraliste;
END
GO

create sequence ParkingServis.seq_serijski_broj as int
start with 8757
minvalue 8757
increment by 1
cycle

select * from ParkingServis.KAZNA;
select * from ParkingServis.PARKIRANO_NA;
select * from ParkingServis.VOZILO;

DELETE FROM ParkingServis.KAZNA where reg_br = 1;

drop sequence ParkingServis.seq_serijski_broj
--citanje vrednosti sekvence
select next value for ParkingServis.seq_serijski_broj