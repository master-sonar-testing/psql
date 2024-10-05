/*
	triger namenjen za ogranicenje kategorizacije KLIJENT
*/
IF OBJECT_ID('ParkingServis.tr_klijent','TR') IS NOT NULL
	DROP TRIGGER ParkingServis.tr_klijent;
GO
CREATE TRIGGER ParkingServis.tr_klijent
ON ParkingServis.KLIJENT
INSTEAD OF INSERT,UPDATE
AS
BEGIN
	declare @klijent_id as int, @fizicko as int, @pravno as int, @preduzetnik as int,@email as varchar(50), @klij_tel as varchar(50), @ulica as varchar(100), @br_ulice as varchar(10), @mesto as varchar(70);
	set @klijent_id = (select klijent_id from inserted);
	set @fizicko = (select fizickol_id from inserted);
	set @pravno = (select pravnol_id from inserted);
	set @preduzetnik = (select preduzetnik_id from inserted);
	set @email = (select email from inserted);
	set @klij_tel = (select klij_tel from inserted);
	set @ulica = (select ulica from inserted);
	set @br_ulice = (select br_ulice from inserted);
	set @mesto = (select mesto from inserted);

	IF @@ROWCOUNT = 0 RETURN;
	SET NOCOUNT ON;

	IF (@klijent_id IN (select klijent_id from ParkingServis.KLIJENT))
		BEGIN
			declare @novo_f as int, @novo_p as int, @novi_p as int;
			set @fizicko = (select fizickol_id from deleted)
			set @novo_f = (select fizickol_id from inserted);
			set @pravno = (select pravnol_id from deleted);
			set @novo_p = (select pravnol_id from inserted);
			set @preduzetnik = (select preduzetnik_id from deleted);
			set @novi_p = (select preduzetnik_id from inserted);

			IF UPDATE(fizickol_id)
				begin
					if (@preduzetnik is null or @pravno is null)
						begin
							RAISERROR ('Klijent moze biti samo fizicko ili pravno lice ili preduzetnik.',16,0);
							ROLLBACK TRANSACTION;
						end
					else
						UPDATE ParkingServis.KLIJENT set fizickol_id = @novo_f where klijent_id = @klijent_id;
				end
			else if UPDATE(pravnol_id)
				begin
					if (@preduzetnik is null or @fizicko is null)
						begin
							RAISERROR ('Klijent moze biti samo fizicko ili pravno lice ili preduzetnik.',16,0);
							ROLLBACK TRANSACTION;
						end
					else
						UPDATE ParkingServis.KLIJENT set pravnol_id = @novo_p where klijent_id = @klijent_id;
				end
			else if UPDATE(preduzetnik_id)
				begin
					if (@fizicko is null or @pravno is null)
						begin
							RAISERROR ('Klijent moze biti samo fizicko ili pravno lice ili preduzetnik.',16,0);
							ROLLBACK TRANSACTION;
						end
					else
						UPDATE ParkingServis.KLIJENT set preduzetnik_id = @novi_p where klijent_id = @klijent_id;
				end
		end
	ELSE
		BEGIN
			if (@fizicko in (select fizickol_id from ParkingServis.FIZICKO_LICE) and @pravno in (select pravnol_id from ParkingServis.PRAVNO_LICE)
				and @preduzetnik in (select preduzetnik_id from ParkingServis.PREDUZETNIK))
				begin
					RAISERROR ('Klijent moze biti samo fizicko ili pravno lice ili preduzetnik.',16,0);
					ROLLBACK TRANSACTION;
				end
			else if (@fizicko in (select fizickol_id from ParkingServis.FIZICKO_LICE) and @pravno in (select pravnol_id from ParkingServis.PRAVNO_LICE))
				begin
					RAISERROR ('Klijent moze biti samo fizicko ili pravno lice .',16,0);
					ROLLBACK TRANSACTION;
				end
			else if (@pravno in (select pravnol_id from ParkingServis.PRAVNO_LICE) and @preduzetnik in (select preduzetnik_id from ParkingServis.PREDUZETNIK))
				begin
					PRINT 'Klijent moze da bude samo pravno lice ili samo preduzetnik.';
					RAISERROR ('Klijent moze biti samo pravno lice ili preduzetnik.',16,0);
					ROLLBACK TRANSACTION;
				end
			else if (@fizicko in (select fizickol_id from ParkingServis.FIZICKO_LICE) and @preduzetnik in (select preduzetnik_id from ParkingServis.PREDUZETNIK))
				begin
					RAISERROR ('Klijent moze biti samo fizicko lice ili preduzetnik.',16,0);
					ROLLBACK TRANSACTION;
				end
			IF (@fizicko in (select fizickol_id from ParkingServis.FIZICKO_LICE))
				BEGIN
					set @pravno = NULL;
					SET @preduzetnik = NULL;
					INSERT INTO ParkingServis.KLIJENT(klijent_id,email,klij_tel,ulica,br_ulice,fizickol_id,pravnol_id,preduzetnik_id,mesto)
					VALUES (@klijent_id,@email,@klij_tel,@ulica,@br_ulice,@fizicko,@pravno,@preduzetnik,@mesto);
				END
			ELSE IF (@pravno in (select pravnol_id from ParkingServis.PRAVNO_LICE))
				BEGIN
					set @fizicko = NULL;
					set @preduzetnik = NULL;
					INSERT INTO ParkingServis.KLIJENT(klijent_id,email,klij_tel,ulica,br_ulice,fizickol_id,pravnol_id,preduzetnik_id,mesto)
					VALUES (@klijent_id,@email,@klij_tel,@ulica,@br_ulice,@fizicko,@pravno,@preduzetnik,@mesto);
				END
			ELSE IF (@preduzetnik in (select preduzetnik_id from ParkingServis.PREDUZETNIK))
				BEGIN 
					set @pravno = NULL;
					set @fizicko = NULL;
					INSERT INTO ParkingServis.KLIJENT(klijent_id,email,klij_tel,ulica,br_ulice,fizickol_id,pravnol_id,preduzetnik_id,mesto)
					VALUES (@klijent_id,@email,@klij_tel,@ulica,@br_ulice,@fizicko,@pravno,@preduzetnik,@mesto);
				END
		END
END

--provera trigera
INSERT INTO ParkingServis.KLIJENT(klijent_id,email,klij_tel,ulica,br_ulice,fizickol_id,pravnol_id,preduzetnik_id,mesto)
VALUES (19,'proba@email','0645879987','Neka Ulica','12c',8,null,1,'Kikinda');

INSERT INTO ParkingServis.KLIJENT(klijent_id,email,klij_tel,ulica,br_ulice,fizickol_id,pravnol_id,preduzetnik_id,mesto)
VALUES (20,'proba@email','0645879987','Neka Ulica','12c',null,1,null,'Kikinda');

select @klijent_id, @email from ParkingServis.KLIJENT where klijent_id = 20;

DELETE FROM ParkingServis.KLIJENT where klijent_id = 20;

INSERT INTO ParkingServis.FIZICKO_LICE
VALUES (8,'Milica','Savic');

update ParkingServis.KLIJENT
set preduzetnik_id = 1
where klijent_id = 20;
/*
	TRIGER 1:

	Triger je namenjen da prilikom dodavanja novog ili izmene postojeceg parkiralista proveri u kojoj se zoni parkiraliste nalazi
	i po zadatoj zoni da postavi ogranicenje vremena trajanja parkinga na posmatranom parkiralistu.
	Ukoliko se vrsi dodavanje novog parkiralista, posmatra se kom gradu i kojoj zoni pripada parkiraliste koje se unosi
	i onda triger gazi unetu vrednost za trajanje parkinga i postavlja je na predefinisanu vrednost koja vazi u gradu i zoni u kojoj je
	parkiraliste.
	U slucaju azuriranje zone u kojoj se nalazi parkiraliste, triger postavlja vrednost trajanja na predefinisanu za grad i zonu u kojoj je
	parkiraliste.

	Trajanje parkinga po zonama u razlicitim gradovima:
	-crvena = 120min(NS) 60(BG) 60(SU)
	-plava = neograniceno 
	-zuta = 120min(BG) 60(KI) 60(SU)
	-zelena = 180min(BG) 24h(SU)
	-ljubicasta = 30min
*/

IF OBJECT_ID('ParkingServis.tr_trajanje_parkiralista','TR') IS NOT NULL
	DROP TRIGGER ParkingServis.tr_trajanje_parkiralista;
GO
CREATE TRIGGER ParkingServis.tr_trajanje_parkiralista
ON ParkingServis.PARKIRALISTE
INSTEAD OF INSERT,UPDATE
AS
BEGIN
	IF @@ROWCOUNT = 0 RETURN;
	SET NOCOUNT ON;

	declare @park_id int, @zona as varchar(200),@grad as varchar(50), @sluzba_id as int;
	set @park_id = (select park_id from inserted);
	set @zona = (select zona from inserted where park_id = @park_id);
	set @sluzba_id = (select sluzba_id from inserted where park_id = @park_id);
	set @grad = (select grad from PARKING_SLUZBA where sluzba_id = @sluzba_id);

	if (@park_id in (select park_id from PARKIRALISTE))
		begin 
			if UPDATE(zona)
			begin
				if @zona = 'ljubicasta'
				UPDATE PARKIRALISTE SET trajanje_park = 30,zona=@zona WHERE park_id = @park_id;
			else if @zona = 'plava'
				UPDATE PARKIRALISTE SET trajanje_park = NULL,zona=@zona WHERE park_id = @park_id;
			else if @zona = 'zelena'
				begin
					if @grad = 'Beograd'
						UPDATE PARKIRALISTE SET trajanje_park = 180,zona=@zona WHERE park_id = @park_id;
					else if @grad = 'Subotica'
						UPDATE PARKIRALISTE SET trajanje_park = 1440,zona=@zona WHERE park_id = @park_id;
					else if @grad = 'Nis'
						UPDATE PARKIRALISTE SET trajanje_park = 60,zona=@zona WHERE park_id = @park_id;
					else
						Print ('Zona: '+@zona+' ne vazi u gradu: '+@grad);
				end
			else if @zona = 'zuta'
				UPDATE PARKIRALISTE SET trajanje_park = 120,zona=@zona WHERE park_id = @park_id;
			else if @zona = 'crvena'
				begin
					if (@grad in ('Novi Sad','Nis'))
						UPDATE PARKIRALISTE SET trajanje_park = 120,zona=@zona WHERE park_id = @park_id;
					else if (@grad in ('Beograd','Kikinda','Subotica'))
						UPDATE PARKIRALISTE SET trajanje_park = 60,zona=@zona WHERE park_id = @park_id;
				end
			else 
				PRINT ('Zona koja je uneta nije validna');
			end
		end
	else
		begin
			declare @br_mesta as int, @dnevna_k as bit, @ulica as varchar(100), @vrsta_park as varchar(200);
			set @br_mesta = (select br_mesta from inserted);
			set @dnevna_k = (select dnevna_karta from inserted);
			set @ulica = (select ulica from inserted);
			set @vrsta_park = (select vrsta_park from inserted);

			if @zona = 'ljubicasta'
				begin
					INSERT INTO PARKIRALISTE(park_id,br_mesta,dnevna_karta,ulica,zona,sluzba_id,vrsta_park,trajanje_park)
					VALUES (@park_id,@br_mesta,@dnevna_k,@ulica,@zona,@sluzba_id,@vrsta_park,30);
				end
			else if @zona = 'plava'
				begin
					INSERT INTO PARKIRALISTE(park_id,br_mesta,dnevna_karta,ulica,zona,sluzba_id,vrsta_park,trajanje_park)
					VALUES (@park_id,@br_mesta,@dnevna_k,@ulica,@zona,@sluzba_id,@vrsta_park,1440);
				end
			else if @zona ='zelena'
				begin
					if @grad = 'Beograd'
						begin		
							INSERT INTO PARKIRALISTE(park_id,br_mesta,dnevna_karta,ulica,zona,sluzba_id,vrsta_park,trajanje_park)
							VALUES (@park_id,@br_mesta,@dnevna_k,@ulica,@zona,@sluzba_id,@vrsta_park,180);
						end
					else if @grad = 'Subotica'
						begin		
							INSERT INTO PARKIRALISTE(park_id,br_mesta,dnevna_karta,ulica,zona,sluzba_id,vrsta_park,trajanje_park)
							VALUES (@park_id,@br_mesta,@dnevna_k,@ulica,@zona,@sluzba_id,@vrsta_park,1440);
						end
					else if @grad = 'Nis'
						begin		
							INSERT INTO PARKIRALISTE(park_id,br_mesta,dnevna_karta,ulica,zona,sluzba_id,vrsta_park,trajanje_park)
							VALUES (@park_id,@br_mesta,@dnevna_k,@ulica,@zona,@sluzba_id,@vrsta_park,60);
						end
				end
			else if @zona = 'zuta'
				begin
					INSERT INTO PARKIRALISTE(park_id,br_mesta,dnevna_karta,ulica,zona,sluzba_id,vrsta_park,trajanje_park)
					VALUES (@park_id,@br_mesta,@dnevna_k,@ulica,@zona,@sluzba_id,@vrsta_park,120);
				end
			else if @zona = 'crvena'
				begin
					if (@grad in ('Novi Sad','Nis'))
						begin
							INSERT INTO PARKIRALISTE(park_id,br_mesta,dnevna_karta,ulica,zona,sluzba_id,vrsta_park,trajanje_park)
							VALUES (@park_id,@br_mesta,@dnevna_k,@ulica,@zona,@sluzba_id,@vrsta_park,120);
						end
					else if (@grad in ('Beograd','Kikinda','Subotica'))
						begin
							INSERT INTO PARKIRALISTE(park_id,br_mesta,dnevna_karta,ulica,zona,sluzba_id,vrsta_park,trajanje_park)
							VALUES (@park_id,@br_mesta,@dnevna_k,@ulica,@zona,@sluzba_id,@vrsta_park,60);
						end
				end
			else 
				PRINT ('Zona koja je uneta nije validna');
		end
END;

--Provera trigera:
select @park_id, @ulica, @br_mesta from ParkingServis.PARKIRALISTE where park_id = 1;--bio je u crvenoj
insert into ParkingServis.PARKIRALISTE values (1,90,0,'Trg Republike','crvena',2,'otvoreno',20);
UPDATE ParkingServis.PARKIRALISTE SET zona = 'crvena' where park_id = 1;

--treba jos malo da proverim
UPDATE ParkingServis.PARKIRALISTE SET zona = 'zelena' where park_id = 1;--vrati ce odgovor da zelena ne vazi u novom sadu
/*
	TRIGER 2:

	Triger koji ce na osnovu vrednosti vremena pocetka parkinga odrediti kada je vreme kraja parkiranja.
	Vreme ce odrediti tako sto ce prilikom update tabele PARKIRANO_NA, unetu vrednost za pocetak parkinga
	sabrati sa vremenom trajanja parkinga u zoni u kojoj je parkirano vozilo.
	Iz trigera se poziva funkcija izracunaj_vreme koja ce da vrati vreme kraja parkinga.
*/
IF OBJECT_ID('ParkingServis.tr_vreme_kraja','TR') IS NOT NULL
	DROP TRIGGER ParkingServis.tr_vreme_kraja;
GO
CREATE TRIGGER ParkingServis.tr_vreme_kraja
ON ParkingServis.PARKIRANO_NA
INSTEAD OF INSERT, UPDATE
AS
BEGIN
	declare @zona as varchar(200),@grad as varchar(50), @vreme_p as time, @trajanje as int, @vreme_k as time, @park_id as int, @sluzba_id as int, @regbr as int,
	@dat_izd as date, @vreme_izd as time, @kontrolor as int, @datum_park as date;
	set @park_id = (select park_id from inserted);
	set @sluzba_id = (select sluzba_id from inserted);
	set @zona = (select zona from ParkingServis.PARKIRALISTE where park_id = @park_id);
	set @grad = (select grad from ParkingServis.PARKING_SLUZBA where sluzba_id = @sluzba_id);
	set @vreme_p = (select vreme_pocetka from inserted);
	set @trajanje = (select trajanje_park from ParkingServis.PARKIRALISTE where park_id = @park_id);
	set @regbr = (select reg_br from inserted);
	set @dat_izd = (select datum_izd from inserted);
	set @vreme_izd = (select vreme_izd from inserted);
	set @kontrolor = (select kontrolor_id from inserted);
	set @datum_park = (select datum_park from inserted);
	set @vreme_k = ParkingServis.izracunaj_vreme(@vreme_p,@trajanje)

	IF UPDATE(park_id)
		begin
			UPDATE ParkingServis.PARKIRANO_NA set park_id = @park_id, vreme_pocetka= @vreme_p,vreme_kraja = @vreme_k where reg_br = @regbr;
		end
	ELSE if UPDATE(sluzba_id)
		BEGIN
			UPDATE ParkingServis.PARKIRANO_NA set sluzba_id = @sluzba_id, vreme_kraja = @vreme_k where reg_br = @regbr;
		END
	ELSE IF UPDATE(datum_izd)
		begin
			declare @datum_provere as date;
			set @datum_provere = (select datum_izd from inserted);
			set @regbr = (select reg_br from deleted);
			set @park_id = (select park_id from deleted);
			set @sluzba_id = (select sluzba_id from ParkingServis.PARKIRALISTE where park_id = @park_id);
			UPDATE ParkingServis.PARKIRANO_NA set datum_izd = @datum_provere where reg_br = @regbr and park_id = @park_id and sluzba_id = @sluzba_id;
		end
	ELSE IF UPDATE(vreme_izd)
		begin
			declare @vreme_provere as time;
			set @vreme_provere = (select vreme_izd from inserted);
			set @regbr = (select reg_br from deleted);
			set @park_id = (select park_id from deleted);
			set @sluzba_id = (select sluzba_id from ParkingServis.PARKIRALISTE where park_id = @park_id);
			UPDATE ParkingServis.PARKIRANO_NA set vreme_izd = @vreme_provere where reg_br = @regbr and park_id = @park_id and sluzba_id = @sluzba_id;
		end
	ELSE 
		BEGIN
			INSERT INTO ParkingServis.PARKIRANO_NA(reg_br,park_id,sluzba_id,datum_izd,vreme_izd,kontrolor_id,datum_park,vreme_pocetka,vreme_kraja)
			VALUES (@regbr,@park_id,@sluzba_id,@dat_izd,@vreme_izd,@kontrolor,@datum_park,@vreme_p,ParkingServis.izracunaj_vreme(@vreme_p,@trajanje));
		END
END
GO

--PROVERA TRIGERA
select @park_id, @reg_br, @datum_izd, @vreme_izd from ParkingServis.PARKIRANO_NA
select @park_id, @ulica, @br_mesta from ParkingServis.PARKIRALISTE
select @park_id, @grad from ParkingServis.PARKING_SLUZBA
SELECT @klijent_id, @reg_br FROM ParkingServis.VOZILO
SELECT @kontrolor_id, @sluzba_id, @zap_ime, @zap_prz FROM ParkingServis.KONTROLOR
INSERT INTO ParkingServis.PARKIRANO_NA(reg_br,park_id,sluzba_id,kontrolor_id,datum_park,vreme_pocetka) VALUES (8,1,2,1,GETDATE(),'14:31')
DELETE FROM ParkingServis.PARKIRANO_NA WHERE reg_br = 8;

INSERT INTO ParkingServis.PARKIRANO_NA(reg_br,park_id,sluzba_id,kontrolor_id,datum_park,vreme_pocetka) VALUES (12,9,4,8,GETDATE(),'10:00')
UPDATE ParkingServis.PARKIRANO_NA set park_id = 10 WHERE reg_br = 12;
