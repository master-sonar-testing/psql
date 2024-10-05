/*
	FUNKCIJA 1:

	Funkcija izracunaj_vreme koja se poziva iz trigera tr_vreme_park.
	Funkcija za prosledjeno vreme pocetka parkinga i zonu u kojoj je vozilo parkirano, vraca vreme kada parking
	treba da bude zavrsen.
	Vreme kraja je povratna vrednost funkcije.

	-crvena = 120min(NS) 60(BG) 60(SU)
	-plava = neograniceno 
	-zuta = 120min(BG) 60(KI) 60(SU)
	-zelena = 180min(BG) 24h(SU)
	-ljubicasta = 30min
*/
IF OBJECT_ID('ParkingServis.izracunaj_vreme','FN') IS NOT NULL 
	DROP FUNCTION ParkingServis.izracunaj_vreme;
GO
CREATE FUNCTION ParkingServis.izracunaj_vreme
(
	@vreme_pocetka as time,
	@trajanje as int
)
RETURNS time
AS
BEGIN
	declare @vreme_kraja as time;
	set @vreme_kraja = DATEADD(MINUTE,@trajanje,@vreme_pocetka);
	return @vreme_kraja;
END
GO

SELECT ParkingServis.izracunaj_vreme('12:30',45) as 'Vreme kraja';

/*
	FUNKCIJA 2:

	Funkcija provera_isteka proverava na osnovu prosledjenih vremena:
		-vreme pocetka parkiranja,
		-vreme kraja parkiranja,
		-vreme provere parkinga
	izracunava da li je istekao parking za posmatrano vozilo.
	Ako je rezultat funkcije:
		-1 - istekao je parking
		-0 - nije istekao parking
	Funkcija ce biti pozivana kroz proceduru pa ce rezultati biti jasnije ispisani (1 = istekao parking, 0 = nije istekao parking)
*/
IF OBJECT_ID ('ParkingServis.provera_isteka','FN') IS NOT NULL
	DROP FUNCTION ParkingServis.provera_isteka;
GO
CREATE FUNCTION ParkingServis.provera_isteka
(
	@datum_park as date,
	@vreme_pocetka as time,
	@vreme_kraja as time,
	@vreme_provere as time,
	@datum_provere as date,
	@dnevna as bit,
	@zona as varchar(20)
)
RETURNS int
AS
BEGIN
	-- 1 - isteklo, 0 - nije isteklo
	declare @rezultat as int;

	if (@datum_provere = @datum_park)
		begin
			IF (@vreme_kraja is NULL)
				BEGIN
					if @dnevna = 1 or @zona = 'plava'
						set @rezultat = 0;
					else if @dnevna = 0 or @zona != 'plava'
						set @rezultat = 1;
				END
			else
				begin
					if (@vreme_provere between @vreme_pocetka and @vreme_kraja)
						set @rezultat = 0;
					else
						set @rezultat = 1;
				end
		end
	else
		begin
			declare @dan as date = DATEADD(DAY, 1, @datum_park);
			declare @sati as time = DATEADD(MINUTE, 1440, @vreme_pocetka);
			IF (@vreme_kraja is NULL)
				BEGIN
					if @zona = 'plava' 
						set @rezultat = 0;

					if @dnevna = 1
						begin
							if @datum_provere = @dan and @vreme_provere <= @sati
								begin
									set @rezultat = 0;
								end
							else
								begin
									set @rezultat = 1;
								end
						end
					else
						begin
								set @rezultat = 1;
						end
				END
			else
				begin
					set @rezultat = 1;
				end
		end

	return @rezultat;
END;
GO

--provera fje
select * from ParkingServis.PARKIRANO_NA where reg_br = 1;
declare @currdate date = convert(date,getdate());
declare @date varchar(10) = '30-05-2021'
declare @timeDiff int = ParkingServis.provera_isteka(convert(date,@date,103),'11:00','12:00','11:50',@currdate,1,'crvena');
select @timeDiff as "Istekao parking"

/*
declare @date varchar(10) = '30-05-2021'
declare @timeDiff int = ParkingServis.provera_isteka(convert(date,@date,103),'11:00',null,'11:45',@currdate,1,'crvena');
declare @timeDiff int = ParkingServis.provera_isteka(convert(date,@date,103),'11:00',null,'10:45',@currdate,1,'crvena');
declare @timeDiff int = ParkingServis.provera_isteka(convert(date,@date,103),'11:00','12:00','11:50',@currdate,1,'crvena');
*/


SELECT GETDATE();
select convert(date,getdate());
--declare @date varchar(10) = '22-05-2021'
select convert(date,@date,103);