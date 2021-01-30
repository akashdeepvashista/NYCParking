/*
 * Create Schema for data base NYCParking
 */
use master
go

drop database if exists NYCParking
go

create database NYCParking
go

use NYCParking
go

drop schema if exists staging
go

CREATE SCHEMA staging;  
GO 


/*
 * Creating table dbo.logger for logging errors.
 */

drop table if exists dbo.logger
go

create table dbo.logger
(
id int identity(1,1),
sourceName varchar(200) not null,
sourceType varchar(200) not null,
errordesc nvarchar(max) not null,
dateandtime datetime not null default getdate()
)

go

/*
 * Creating table [staging].[parkingviolations] for copying data from csv file.
 */

DROP TABLE if exists [staging].[parkingviolations]
GO

CREATE TABLE [staging].[parkingviolations](
	[Summons_Number] [varchar](50) NULL,
	[Plate_ID] [varchar](50) NULL,
	[Registration_State] [varchar](50) NULL,
	[Plate_type] [varchar](50) NULL,
	[Issue_Date] [varchar](50) NULL,
	[Violation_Code] [varchar](50) NULL,
	[Vehicle_Body_Type] [varchar](50) NULL,
	[Vehicle_Make] [varchar](50) NULL,
	[Issuing_Agency] [varchar](50) NULL,
	[Street_Code1] [varchar](50) NULL,
	[Street_Code2] [varchar](50) NULL,
	[Street_Code3] [varchar](50) NULL,
	[Vehicle_Expiration Date] [varchar](50) NULL,
	[Violation_Location] [varchar](50) NULL,
	[Violation_Precinct] [varchar](50) NULL,
	[Issuer_Precinct] [varchar](50) NULL,
	[Issuer_Code] [varchar](50) NULL,
	[Issuer_Command] [varchar](50) NULL,
	[Issuer_Squad] [varchar](50) NULL,
	[Violation_Time] [varchar](50) NULL,
	[First_Observed] [varchar](50) NULL,
	[Violation_County] [varchar](50) NULL,
	[Violation_Front_Opposite] [varchar](50) NULL,
	[House_Number] [varchar](50) NULL,
	[Street_Name] [varchar](50) NULL,
	[Intersecting_Street] [varchar](50) NULL,
	[Date_First_Observed] [varchar](50) NULL,
	[Law_Section] [varchar](50) NULL,
	[Sub_Division] [varchar](50) NULL,
	[Violation_Legal_Code] [varchar](50) NULL,
	[Days_Parking_Effect] [varchar](50) NULL,
	[From_Hours_Effect] [varchar](50) NULL,
	[To_Hours_Effect] [varchar](50) NULL,
	[Vehicle_Color] [varchar](50) NULL,
	[Unregistered_Vehicle] [varchar](50) NULL,
	[Vehicle_Year] [varchar](50) NULL,
	[Meter_Number] [varchar](50) NULL,
	[Feet_Curb] [varchar](50) NULL,
	[Violation_Post_Code] [varchar](50) NULL,
	[Violation_Description] [varchar](50) NULL,
	[Standing_Violation] [varchar](50) NULL,
	[Hydrant_Violation] [varchar](50) NULL,
	[Double_Parking_Violation] [varchar](50) NULL--,
	--[Latitude] [varchar](50) NULL,
	--[Longitude] [varchar](50) NULL,
	--[Community_Board] [varchar](50) NULL,
	--[Community_Council ] [varchar](50) NULL,
	--[Census_Tract] [varchar](50) NULL,
	--[BIN] [varchar](50) NULL,
	--[BBL] [varchar](50) NULL,
	--[NTA] [varchar](50) NULL
) ON [PRIMARY]
GO

/*
 * Creating tables for the database in 3NF form
 */

drop table if exists tickets
go
drop table if exists addresstiming
go
drop table if exists issuer
go
drop table if exists lawcode
go
drop table if exists tickets
go
drop table if exists vehicles
go
drop table if exists vehicleplatetype
go

create table addresstiming
(
as_of_dt date not null,
addressparkingID int not null primary key identity(1,1),
houseNum varchar(10) null,
streetname varchar(50) null,
intersectingstreet varchar(50) null,
daysparkingineffect varchar(7) null,
fromhoursineffect varchar(7) null,
tohoursineffect varchar(7) null,
violationcounty varchar(3) null
)
go

create table issuer
(
as_of_dt date not null,
issuerCode int not null primary key,
issuerpercent int null,
issuercommand varchar(5) null,
issuersquad varchar(5) null
)
go


create table lawcode
(
as_of_dt date not null,
lawcodeid int not null primary key identity(1,1),
violationcode varchar(2) null,
violationdescription varchar(50) null,
lawsection varchar(3) null,
subdivision varchar(2) null
)
go

create table vehicleplatetype
(
as_of_dt date not null,
platetypeID int not null identity(1,1),
platetype char(3) not null primary key,
platedescription varchar(100) null
)
go

create table vehicles
(
as_of_dt date not null,
plateID varchar(8) not null primary key,
registrationstate char(2) null,
platetype char(3) not null constraint fk_platetype foreign key references dbo.vehicleplatetype(platetype),
vehiclebodytype char(6) null,
vehiclemake char(6) null,
vehicleexpdate date null,
vehiclecolor varchar(10) null,
vehicleyear smallint null,
unregisteredvehicles bit null
)
go

create table tickets
(
as_of_dt date not null,
summonsnumber bigint not null
,plateid varchar(8) not null constraint fk_plateID foreign key references dbo.vehicles(plateID)
,issuedate date null,
issuingagency char(1) null,
streetcode1 int null,
streetcode2 int null,
streetcode3 int null,
voilationlocation int null,
violationprecint int null,
issuerID int not null constraint fk_issuerID foreign key references dbo.issuer(issuerCode)
,violationtime varchar(5) null,
violationfrontopposite char(1) null,
lawcodeID int not null constraint fk_lawcode foreign key references dbo.lawcode(lawcodeid)
,addressparktimeID int not null constraint fk_addressparktimeID foreign key references dbo.addresstiming(addressparkingID)
,ispaid bit not null
,amount money not null
,severity tinyint not null
)
go

/*
 * Creating user defined Stored Procedure to log the errords to logger table.
 */

drop proc if exists dbo.usp_logger
go

create proc usp_logger
(
@sourceName varchar(100),
@sourceType varchar(100),
@errDesc nvarchar(max)
)
as
begin

insert into dbo.logger(sourceName,sourceType,errordesc)
values(@sourceName,@sourceType,@errDesc)

end
go

/*
 * Creating user defined Stored Procedure to copy data from csv file to staging table.
 */

drop proc if exists staging.usp_bulkinsertcsv
go

create proc staging.usp_bulkinsertcsv
as
begin

begin try

truncate table [staging].[parkingviolations]

bulk insert [staging].[parkingviolations]
from 'D:\AD_Project\Parking_Violations_Issued_-_Fiscal_Year_2017.csv'
with
(
  FIELDTERMINATOR =','
, ROWTERMINATOR = '0x0a'
,FIRSTROW=2
,maxerrors=1
,batchsize=1000
,lastrow=400001
,format='CSV'
)
end try
begin catch
 declare @errMsg nvarchar(max),@procName varchar(100)
 select @errMsg=ERROR_MESSAGE(),@procName=OBJECT_NAME(@@PROCID)
exec dbo.usp_logger @procName,'Stored Procedure',@errMsg;
throw 50000,@errMsg,1

end catch
end
go
 --Exec staging.usp_bulkinsertcsv
 --GO
/*
 * Create user defined Stored Procedure to clean Plate_Type collumn and Update the colour inconsistencies in vehicle color column.
 */
drop proc if exists staging.usp_cleanTables
go

create proc staging.usp_cleanTables
as
begin

delete
	FROM [NYCParking].[staging].[parkingviolations]
	where 
	Violation_Description is null 
	and 
	Violation_Post_Code is null 
	and
	First_Observed is null
	and 
	Intersecting_Street is null


ALTER TABLE NYCParking.staging.parkingviolations
ADD Plate_Desc VARCHAR(50)


declare @query nvarchar(max)

			set @query='

			UPDATE  NYCParking.staging.parkingviolations
			SET Plate_Type = ''THC''
			WHERE Plate_Type = ''999''

			UPDATE  NYCParking.staging.parkingviolations
			SET Plate_Desc = ''Commercial Vehicle''
			WHERE Plate_Type = ''COM''

			UPDATE  NYCParking.staging.parkingviolations
			SET Plate_Desc = ''Passenger''
			WHERE Plate_Type = ''PAS''

			UPDATE  NYCParking.staging.parkingviolations
			SET Plate_Desc = ''Special Passenger - Vanity''
			WHERE Plate_Type = ''SRF''

			UPDATE  NYCParking.staging.parkingviolations
			SET Plate_Desc = ''Household Carrier Tractor''
			WHERE Plate_Type = ''THC''

			UPDATE  NYCParking.staging.parkingviolations
			SET Plate_Desc = ''Taxi''
			WHERE Plate_Type = ''OMT''

			UPDATE  NYCParking.staging.parkingviolations
			SET Plate_Desc = ''Rental''
			WHERE Plate_Type = ''OMS''
			';
			EXEC (@query);
			

			drop table if exists #colors
			

			create table #colors
			(
			id int identity(1,1)
			,colorname varchar(max)
			,colorcode varchar(4) unique
			)


			insert into #colors
			(colorname,colorcode)
			values('black','blk')
			,('cream','crm')
			,('gray','gry')
			,('white','whi')
			,('beige','bge')
			,('brown','bro')
			,('camouflage','cam')
			,('tan','tan')
			,('taupe','tpe')
			,('blue','blu')
			,('blue, dark','dbl')
			,('blue, light','lbl')
			,('green','grn')
			,('green, dark','dgr')
			,('green, light','lgr')
			,('teal','tea')
			,('turquoise','trq')
			,('aluminum','sil')
			,('bronze','brz')
			,('chrome','com')
			,('copper','cpr')
			,('--gold','gld')
			,('orange','org')
			,('pink','pnk')
			,('red','red')
			,('yellow','yel')
			,('amethyst','ame')
			,('burgundy/maroon','mar')
			,('lavender','lav')
			,('mauve','mve')
			,('purple','ple')
			
			
			

			merge NYCParking.staging.parkingviolations p
			using #colors t
			on lower(p.Vehicle_Color)=lower(t.colorcode)
			when matched
			then update set
			p.vehicle_Color=t.colorname;
			

			update p
			set p.Vehicle_Color='blue'
			from NYCParking.staging.parkingviolations p inner join
			#colors c 
			on p.Vehicle_Color<>c.colorcode		

	--add new columns
	alter table NYCParking.staging.parkingviolations
	add isPaid bit not null default CRYPT_GEN_RANDOM(1)%2

	alter table NYCParking.staging.parkingviolations
	add amount money not null default (500 + ROUND( 1500 *RAND(convert(varbinary, newid())), 0))

	alter table NYCParking.staging.parkingviolations
	add severity tinyint not null default 0
end
go
--Exec staging.usp_cleanTables
-- GO
/*
 * Create user defined Stored Procedure to update staging table.
-- */
-- drop proc if exists staging.usp_updateStaging
--go

--create proc staging.usp_updateStaging
--as
--begin

--	update NYCParking.staging.parkingviolations
--	set severity = case
--	when convert(int,Violation_Code)>=0 and convert(int,Violation_Code) <=10 then 0
--	when convert(int,Violation_Code)>=11 and convert(int,Violation_Code) <=20 then 1
--when convert(int,Violation_Code)>=21 and convert(int,Violation_Code)<=30 then 2
--when convert(int,Violation_Code)>=31 and convert(int,Violation_Code)<=40 then 3
--when convert(int,Violation_Code)>=41 and convert(int,Violation_Code)<=50 then 4
--when convert(int,Violation_Code)>=51 and convert(int,Violation_Code)<=60 then 5
--when convert(int,Violation_Code)>=61 and convert(int,Violation_Code)<=70 then 6
--when convert(int,Violation_Code)>=71 and convert(int,Violation_Code)<=80 then 7
--when convert(int,Violation_Code)>=81 and convert(int,Violation_Code)<=90 then 8
--when convert(int,Violation_Code)>=91 and convert(int,Violation_Code)<=100 then 9
--end;

--end
--GO

--exec staging.usp_updateStaging
--go
/*
 * Create user defined Stored Procedure usp_loadNYCParking to load data to database from staging table.
 */

--drop proc if exists dbo.usp_loadNYCParking
--go

--create proc dbo.usp_loadNYCParking
--as
--begin

--begin try
--begin transaction
--			declare @as_of_Dt date;
--			select @as_of_Dt = convert(date,getdate())
			
--			--delete from NYCParking.dbo.addresstiming where as_of_dt=@as_of_Dt
--			insert into NYCParking.dbo.addresstiming
--			(
--			as_of_dt
--			,houseNum
--			,streetname
--			,intersectingstreet
--			,daysparkingineffect
--			,fromhoursineffect
--			,tohoursineffect
--			,violationcounty
--			)
--			select
--			distinct
--			@as_of_Dt
--			,convert(varchar(10),House_Number)
--			,convert(varchar(50),Street_Name)
--			,convert(varchar(50),Intersecting_Street)
--			,convert(varchar(7),Days_Parking_Effect)
--			,convert(varchar(7),From_Hours_Effect)
--			,convert(varchar(7),To_Hours_Effect)
--			,convert(varchar(3),Violation_County)
--			from NYCParking.staging.parkingviolations;
			
--			--delete from NYCParking.dbo.issuer where as_of_dt=@as_of_Dt;

--			WITH cte AS (
--					SELECT 
--						--@as_of_Dt
--								CONVERT(int,Issuer_Code) as Issuer_Code
--			,convert(int,Issuer_Precinct) as Issuer_Precinct
--			,convert(varchar(5),Issuer_Command) as Issuer_Command
--			,convert(varchar(5),Issuer_Squad) as Issuer_Squad
--						,ROW_NUMBER() OVER (
--							PARTITION BY 
--								Issuer_Code
--								--,Issuer_Precinct
--								--,Issuer_Command
--								--,Issuer_Squad
--							ORDER BY 
--								Issuer_Code
--						) row_num
--				from NYCParking.staging.parkingviolations
--				)
--				DELETE FROM cte
--				WHERE row_num > 1;

--			insert into NYCParking.dbo.issuer
--			(
--			as_of_dt
--			,issuerCode
--			,issuerpercent
--			,issuercommand
--			,issuersquad
--			)
--			select
--			distinct
--			@as_of_Dt
--			,CONVERT(int,Issuer_Code)
--			,convert(int,Issuer_Precinct)
--			,convert(varchar(5),Issuer_Command)
--			,convert(varchar(5),Issuer_Squad)
--			from NYCParking.staging.parkingviolations
			
			
--			--delete from NYCParking.dbo.lawcode where as_of_dt=@as_of_Dt
--			insert into NYCParking.dbo.lawcode
--			(
--			as_of_dt
--			,violationcode
--			,violationdescription
--			,lawsection
--			,subdivision
--			)
--			select
--			distinct
--			@as_of_Dt
--			,convert(varchar(2),Violation_Code)
--			,CONVERT(varchar(50),Violation_Description)
--			,convert(varchar(3),Law_Section)
--			,convert(varchar(2),Sub_Division)
--			from NYCParking.staging.parkingviolations

--			--delete from NYCParking.dbo.vehicleplatetype where as_of_dt=@as_of_Dt
--			insert into NYCParking.dbo.vehicleplatetype
--			(
--			as_of_dt
--			--,platetypeID
--			,platetype
--			,platedescription
--			)
--			select
--			distinct
--			@as_of_Dt
--			--,CONVERT(int,Plate_ID)
--			,CONVERT(char(3),Plate_type)
--			,CONVERT(varchar(100),plate_Desc)
--			from NYCParking.staging.parkingviolations;

--			--delete from NYCParking.dbo.vehicles where as_of_dt=@as_of_Dt;

--			WITH cte AS (
--					SELECT 
--						--@as_of_Dt
--						CONVERT(varchar(8),Plate_ID) as Plate_ID
--						,convert(char(2),Registration_State) as Registration_State
--						,(select platetypeID from NYCParking.dbo.vehicleplatetype where platetype=Plate_type) as platetypeID
--						,CONVERT(char(6),Vehicle_Body_Type) as Vehicle_Body_Type
--						,CONVERT(char(6),Vehicle_Make) as Vehicle_Make
--						,case when len([Vehicle_Expiration Date])<> 1 or len([Vehicle_Expiration Date])<> 2 then NULL
--						else [Vehicle_Expiration Date]
--						end as [Vehicle_Expiration Date]
--						,CONVERT(varchar(10),Vehicle_Color ) as Vehicle_Color
--						,CONVERT(smallint,Vehicle_Year) as Vehicle_Year
--						,CONVERT(bit,Unregistered_Vehicle) as Unregistered_Vehicle
--						,ROW_NUMBER() OVER (
--							PARTITION BY 
--								plate_id
--							ORDER BY 
--								plate_id
--						) row_num
--				from NYCParking.staging.parkingviolations
--				)
--				DELETE FROM cte
--				WHERE row_num > 1;
				
--				insert into NYCParking.dbo.vehicles
--			(
--			as_of_dt
--			,plateID
--			,registrationstate
--			,platetype
--			,vehiclebodytype
--			,vehiclemake
--			,vehicleexpdate
--			,vehiclecolor
--			,vehicleyear
--			,unregisteredvehicles
--			)
--			select
--			distinct
--			@as_of_Dt
--			,CONVERT(varchar(8),Plate_ID)
--			,convert(char(2),Registration_State)
--			,convert(char(3),Plate_type)
--			,CONVERT(char(6),Vehicle_Body_Type)
--			,CONVERT(char(6),Vehicle_Make)
--			,case when len([Vehicle_Expiration Date])<> 1 or len([Vehicle_Expiration Date])<> 2 then NULL
--			else [Vehicle_Expiration Date]
--			end
--			,CONVERT(varchar(10),Vehicle_Color)
--			,CONVERT(smallint,Vehicle_Year)
--			,CONVERT(bit,Unregistered_Vehicle)
--			from NYCParking.staging.parkingviolations

--			--delete from NYCParking.dbo.tickets where as_of_dt=@as_of_Dt
--			insert NYCParking.dbo.tickets
--			(
--			as_of_dt
--			,summonsnumber
--			,plateid
--			,issuedate
--			,issuingagency
--			,streetcode1
--			,streetcode2
--			,streetcode3
--			,voilationlocation
--			,violationprecint
--			,issuerID
--			,violationtime
--			,violationfrontopposite
--			,lawcodeID
--			,addressparktimeID
--			,ispaid
--			,amount
--			,severity
--			)
--			select
--			distinct
--			@as_of_Dt
--			,CONVERT(bigint,Summons_Number)
--			,CONVERT(varchar(8),Plate_ID)
--			,convert(date,Issue_Date)
--			,convert(char(1),Issuing_Agency)
--			,CONVERT(int,Street_Code1)
--			,CONVERT(int,Street_Code2)
--			,CONVERT(int,Street_Code3)
--			,CONVERT(int,Violation_Location)
--			,CONVERT(int,Violation_Precinct)
--			,CONVERT(int,Issuer_Code)
--			,CONVERT(varchar(5),Violation_Time)
--			,CONVERT(char(1),Violation_Front_Opposite)
--			,lc.lawcodeid
--			,ad.addressparkingID
--			,convert(bit,ispaid)
--			,convert(money,amount)
--			,convert(tinyint,severity)
--			from NYCParking.staging.parkingviolations pv
--			inner join NYCParking.dbo.lawcode lc
--			on pv.Violation_Code=lc.violationcode
--			and pv.Law_Section=lc.lawsection
--			and pv.Sub_Division=lc.subdivision
--			inner join NYCParking.dbo.addresstiming ad
--			on ad.streetname=pv.Street_Name
--			and ad.houseNum=pv.House_Number
--			and ad.intersectingstreet=pv.Intersecting_Street
--			and ad.daysparkingineffect=pv.Days_Parking_Effect
--			and ad.fromhoursineffect=pv.From_Hours_Effect
--			and ad.tohoursineffect=pv.To_Hours_Effect
--			and ad.violationcounty=pv.Violation_County
--			commit;


--end try
--begin catch
--	rollback transaction
--	 declare @errMsg nvarchar(max),@procName varchar(100)
-- select @errMsg=ERROR_MESSAGE(),@procName=OBJECT_NAME(@@PROCID)
--exec nycparking.dbo.usp_logger @procName,'Stored Procedure',@errMsg;
--throw 50000,@errMsg,1
--end catch

--end
--GO

 --Exec dbo.usp_loadNYCParking
 --GO