/*
 * Create Schema for data base NYCParking
 */
use master
go

drop database if exists NYCParking_DW
go

create database NYCParking_DW
go

use NYCParking_DW
go

drop schema if exists [extract]
go

create schema [extract];
go

drop schema if exists [load]
go

create schema [load]
go

drop table if exists [extract].tickets
go
drop table if exists [extract].addresstiming
go
drop table if exists [extract].issuer
go
drop table if exists [extract].lawcode
go
drop table if exists [extract].tickets
go

drop table if exists [extract].vehicles
go
drop table if exists [extract].vehicleplatetype
go

create table NYCParking_DW.[extract].addresstiming
(
houseNum varchar(max) null,
streetname varchar(max) null,
intersectingstreet varchar(max) null,
daysparkingineffect varchar(max) null,
fromhoursineffect varchar(max) null,
tohoursineffect varchar(max) null,
violationcounty varchar(max) null
)
go
--houseNum , intersectingstreet and streetname

create table NYCParking_DW.[extract].issuer
(
issuerCode varchar(max) null,
issuerpercent varchar(max) null,
issuercommand varchar(max) null,
issuersquad varchar(max) null
)
go
--issuercode

create table NYCParking_DW.[extract].lawcode
(
violationcode varchar(max) null,
violationdescription varchar(max) null,
lawsection varchar(max) null,
subdivision varchar(max) null
)
go
--violationcode,subdivision

create table NYCParking_DW.[extract].vehicleplatetype
(
platetype varchar(max) null,
platedescription varchar(max) null
)
go

create table NYCParking_DW.[extract].vehicles
(
plateID varchar(max) null,
registrationstate varchar(max) null,
platetype varchar(max) null,
vehiclebodytype varchar(max) null,
vehiclemake varchar(max) null,
vehicleexpdate varchar(max) null,
vehiclecolor varchar(max) null,
vehicleyear varchar(max) null,
unregisteredvehicles varchar(max) null
)
go
--plateID

create table NYCParking_DW.[extract].tickets
(
summonsnumber varchar(max) null,
plateid varchar(max) null,
issuedate varchar(max) null,
issuingagency varchar(max) null,
streetcode1 varchar(max) null,
streetcode2 varchar(max) null,
streetcode3 varchar(max) null,
voilationlocation varchar(max) null,
violationprecint varchar(max) null,
issuerCode varchar(max) null,
violationtime varchar(max) null,
violationfrontopposite varchar(max) null,
violationcode varchar(max) null,
subdivision varchar(max) null,
houseNum varchar(max) null,
intersectingstreet varchar(max) null,
streetname varchar(max) null
,ispaid bit not null
,amount money not null
,severity tinyint not null
)
GO

DROP TABLE IF EXISTS NYCParking_DW.[load].FactViolationMeasures
GO
DROP TABLE IF EXISTS NYCParking_DW.[load].DimTickets
GO
DROP TABLE IF EXISTS NYCParking_DW.[load].DimAddressTiming
GO
DROP TABLE IF EXISTS NYCParking_DW.[load].DimIssuer
GO
DROP TABLE IF EXISTS NYCParking_DW.[load].DimLawCode
GO
DROP TABLE IF EXISTS NYCParking_DW.[load].DimVehicles
GO
DROP TABLE IF EXISTS NYCParking_DW.[load].DimDate
GO
DROP TABLE IF EXISTS NYCParking_DW.[load].DimVehiclePlateType
GO

drop SEQUENCE if exists addressTimingId
go
drop SEQUENCE if exists ticketId
go
drop SEQUENCE if exists issuerId
go
drop SEQUENCE if exists lawCodeId
go
drop SEQUENCE if exists vehicleId
go
drop SEQUENCE if exists vehiclePlateTypeId
go


CREATE SEQUENCE addressTimingId
START WITH 530000
INCREMENT BY 1
GO

CREATE SEQUENCE ticketId
START WITH 1126000
INCREMENT BY 1
GO

CREATE SEQUENCE issuerId
START WITH 1210500000
INCREMENT BY 1
GO

CREATE SEQUENCE lawCodeId
START WITH 420
INCREMENT BY 1
GO

CREATE SEQUENCE vehicleId
START WITH 2400
INCREMENT BY 1
GO

CREATE SEQUENCE vehiclePlateTypeId
START WITH 1000
INCREMENT BY 1
GO

CREATE TABLE NYCParking_DW.[load].DimAddressTiming
(
addressTimingKey INT NOT NULL PRIMARY KEY DEFAULT (NEXT VALUE FOR addressTimingId),
houseNum VARCHAR(10) NULL,
streetname VARCHAR(30) NULL,
intersectingstreet VARCHAR(30) NULL,
daysparkingineffect VARCHAR(10) NULL,
fromhoursineffect VARCHAR(10) NULL,
tohoursineffect VARCHAR(10) NULL,
violationcounty VARCHAR(10) NULL
)
GO

CREATE TABLE NYCParking_DW.[load].DimIssuer
(
issuerKey INT IDENTITY NOT NULL PRIMARY KEY,
issuerCode VARCHAR(10) NULL,
issuerpercent VARCHAR(10) NULL,
issuercommand VARCHAR(10) NULL,
issuersquad VARCHAR(10) NULL,
startdate DATE null,
enddate DATE null
)
GO

CREATE TABLE NYCParking_DW.[load].DimLawCode
(
lawCodeKey INT NOT NULL PRIMARY KEY DEFAULT (NEXT VALUE FOR lawCodeId),
violationcode VARCHAR(10) NULL,
violationdescription VARCHAR(30) NULL,
lawsection VARCHAR(10) NULL,
subdivision VARCHAR(10) NULL
)
GO

CREATE TABLE NYCParking_DW.[load].DimVehiclePlateType
(
vehiclePlateTypeKey INT NOT NULL PRIMARY KEY DEFAULT (NEXT VALUE FOR vehiclePlateTypeId),
platetype VARCHAR(10) NULL,
platedescription VARCHAR(30) NULL
)
GO

CREATE TABLE NYCParking_DW.[load].DimVehicles
(
vehicleKey INT IDENTITY NOT NULL PRIMARY KEY,
plateID VARCHAR(10) NULL,
registrationstate VARCHAR(10) NULL,
platetype VARCHAR(5) not NULL,
vehiclebodytype VARCHAR(10) NULL,
vehiclemake VARCHAR(10) NULL,
vehicleexpdate VARCHAR(10) NULL,
vehiclecolor VARCHAR(10) NULL,
vehicleyear SMALLINT NULL,
unregisteredvehicles BIT NULL,
startdate DATE null,
enddate DATE null
)
GO

CREATE TABLE NYCParking_DW.[load].DimTickets
(
ticketKey INT NOT NULL PRIMARY KEY DEFAULT (NEXT VALUE FOR ticketId),
summonsnumber BIGINT NULL,
plateid VARCHAR(10) NULL,
issuedate DATE NULL,
issuingagency VARCHAR(10) NULL,
streetcode1 VARCHAR(10) NULL,
streetcode2 VARCHAR(10) NULL,
streetcode3 VARCHAR(10) NULL,
voilationlocation VARCHAR(10) NULL,
violationprecint VARCHAR(10) NULL,
issuerID INT NULL,
violationtime VARCHAR(10) NULL,
violationfrontopposite VARCHAR(10) NULL,
lawcodeID INT not NULL,
addressparktimeID INT not NULL
,ispaid bit not null
,amount money not null
,severity tinyint not null
)
GO

CREATE TABLE NYCParking_DW.[load].DimDate (
	DateKey INT NOT NULL PRIMARY KEY,
	DateValue DATE NOT NULL,
	CYear SMALLINT NOT NULL,
	CMonth TINYINT NOT NULL,
	DayNo TINYINT NOT NULL,
	CQtr TINYINT NOT NULL,
	StartOfMonth DATE NOT NULL,
	EndOfMonth DATE NOT NULL,
	MonthName VARCHAR(9) NOT NULL,
	DayOfWeekName VARCHAR(9) NOT NULL
)
GO

CREATE TABLE NYCParking_DW.[load].FactViolationMeasures
(
ticketKey INT NOT NULL,
DateKey INT NOT NULL,
vehiclePlateTypeKey INT NOT NULL,
vehicleKey INT NOT NULL,
lawCodeKey INT NOT NULL,
issuerKey INT NOT NULL,
addressTimingKey INT NOT NULL,
Amount int not null,
--AvgAmount int not null,
paidpercentage tinyint not null,
avgseverity int not null,
CONSTRAINT FK_FactDimTickets FOREIGN KEY(TicketKey) REFERENCES NYCParking_DW.[load].DimTickets (ticketKey),
CONSTRAINT FK_FactDimDate FOREIGN KEY(DateKey) REFERENCES NYCParking_DW.[load].DimDate (DateKey),
CONSTRAINT FK_FactDimVehiclePlateType FOREIGN KEY(vehiclePlateTypeKey) REFERENCES NYCParking_DW.[load].DimVehiclePlateType (vehiclePlateTypeKey),
CONSTRAINT FK_FactDimVehicles FOREIGN KEY(vehicleKey) REFERENCES NYCParking_DW.[load].DimVehicles (vehicleKey),
CONSTRAINT FK_FactDimLawCode FOREIGN KEY(lawCodeKey) REFERENCES NYCParking_DW.[load].DimLawCode (lawCodeKey),
CONSTRAINT FK_FactDimIssuer FOREIGN KEY(issuerKey) REFERENCES NYCParking_DW.[load].DimIssuer (issuerKey),
CONSTRAINT FK_FactDimAddressTiming FOREIGN KEY(addressTimingKey) REFERENCES NYCParking_DW.[load].DimAddressTiming (addressTimingKey)
)
GO

/*
 *
 */

drop proc if exists [extract].usp_loadExtractTables
go

create proc [extract].usp_loadExtractTables
as
begin
begin try
--begin transaction
truncate table NYCParking_DW.[extract].addresstiming

insert into NYCParking_DW.[extract].addresstiming
(
	houseNum
			,streetname
			,intersectingstreet
			,daysparkingineffect
			,fromhoursineffect
			,tohoursineffect
			,violationcounty
)
select
	houseNum
			,streetname
			,intersectingstreet
			,daysparkingineffect
			,fromhoursineffect
			,tohoursineffect
			,violationcounty
from NYCParking.dbo.addresstiming

truncate table NYCParking_DW.[extract].issuer

insert into NYCParking_DW.[extract].issuer
(
		issuerCode
			,issuerpercent
			,issuercommand
			,issuersquad
)
select
		issuerCode
			,issuerpercent
			,issuercommand
			,issuersquad
from NYCParking.dbo.issuer

truncate table NYCParking_DW.[extract].lawcode

insert into NYCParking_DW.[extract].lawcode
(
			violationcode
			,violationdescription
			,lawsection
			,subdivision
)
select
			violationcode
			,violationdescription
			,lawsection
			,subdivision
from NYCParking.dbo.lawcode

truncate table NYCParking_DW.[extract].vehicleplatetype

insert into NYCParking_DW.[extract].vehicleplatetype
(
			platetype
			,platedescription
)
select
			platetype
			,platedescription
from NYCParking.dbo.vehicleplatetype


truncate table NYCParking_DW.[extract].vehicles

insert into NYCParking_DW.[extract].vehicles
(
				plateID
			,registrationstate
			,platetype
			,vehiclebodytype
			,vehiclemake
			,vehicleexpdate
			,vehiclecolor
			,vehicleyear
			,unregisteredvehicles
)
select
				plateID
			,registrationstate
			,platetype
			,vehiclebodytype
			,vehiclemake
			,vehicleexpdate
			,vehiclecolor
			,vehicleyear
			,unregisteredvehicles
from NYCParking.dbo.vehicles



truncate table NYCParking_DW.[extract].tickets

insert into NYCParking_DW.[extract].tickets
(
				summonsnumber
			,plateid
			,issuedate
			,issuingagency
			,streetcode1
			,streetcode2
			,streetcode3
			,voilationlocation
			,violationprecint
			,issuerCode
			,violationtime
			,violationfrontopposite
			,violationcode
			,subdivision
			,houseNum
			,intersectingstreet
			,streetname
			,ispaid
			,amount
			,severity

)
select
				summonsnumber
			,plateid
			,issuedate
			,issuingagency
			,streetcode1
			,streetcode2
			,streetcode3
			,voilationlocation
			,violationprecint
			,i.issuerCode
			,violationtime
			,violationfrontopposite
			,v.violationcode
			,v.subdivision
			,a.houseNum,
			a.intersectingstreet,
			a.streetname
			,ispaid
			,amount
			,severity
from NYCParking.dbo.tickets t
INNER JOIN NYCParking.dbo.issuer i
ON i.issuerCode = t.issuerID
INNER JOIN NYCParking.dbo.addresstiming a
ON a.addressparkingID = t.addressparktimeID
INNER JOIN NYCParking.dbo.lawcode v
ON v.lawcodeid = t.lawcodeID

			--commit;


end try
begin catch
	--rollback transaction
	 declare @errMsg nvarchar(max),@procName varchar(100)
 select @errMsg=ERROR_MESSAGE(),@procName=OBJECT_NAME(@@PROCID)
exec nycparking.dbo.usp_logger @procName,'Stored Procedure',@errMsg;
throw 50000,@errMsg,1
end catch
end
GO	

/* 
 *
 */
 
 DROP PROCEDURE IF EXISTS load.usp_loadDimDate
 GO

CREATE PROCEDURE load.usp_loadDimDate 
    @DateValue DATE
AS
BEGIN
SET NOCOUNT ON;

    INSERT INTO NYCParking_DW.[load].DimDate

    SELECT CAST( YEAR(@DateValue) * 10000 + MONTH(@DateValue) * 100 + DAY(@DateValue) AS INT),
           @DateValue,
           YEAR(@DateValue),
           MONTH(@DateValue),
           DAY(@DateValue),
           DATEPART(qq,@DateValue),
           DATEADD(DAY,1,EOMONTH(@DateValue,-1)),
           EOMONTH(@DateValue),
           DATENAME(mm,@DateValue),
           DATENAME(dw,@DateValue)
		   WHERE CAST( YEAR(@DateValue) * 10000 + MONTH(@DateValue) * 100 + DAY(@DateValue) AS INT) NOT IN (SELECT DateKey from NYCParking_DW.[load].DimDate)
END
GO

----truncate table NYCParking_DW.[load].DimDate
--DECLARE @tempDateValue DATE = '2016-01-01' 
--WHILE @tempDateValue <= '2018-01-01'
--BEGIN
--	EXEC load.usp_loadDimDate @tempDateValue
--	SELECT @tempDateValue = DATEADD(day,1,@tempDateValue)
--END
--GO

/*
 * Store Procedure to load data to the transform tables
 */
 DROP PROCEDURE IF EXISTS [load].[usp_loadDimentionTables]
 GO
Create proc [load].[usp_loadDimentionTables]
as
begin
begin try
begin transaction

	UPDATE NYCParking_DW.[load].DimAddressTiming 
							SET 
							--houseNum = convert(varchar(10),e.houseNum),
							streetname = convert(varchar(30),e.streetname),
							intersectingstreet = convert(varchar(30),e.intersectingstreet),
							daysparkingineffect = convert(varchar(10),e.daysparkingineffect),
							fromhoursineffect = convert(varchar(10),e.fromhoursineffect)
							--tohoursineffect = convert(varchar(10),e.tohoursineffect),
							--violationcounty = convert(varchar(10),e.violationcounty)
							FROM NYCParking_DW.[extract].addresstiming e
							INNER JOIN NYCParking_DW.[load].DimAddressTiming l 
							ON e.houseNum = l.houseNum
							AND e.violationcounty = l.violationcounty
							AND e.fromhoursineffect = l.fromhoursineffect 

	INSERT INTO NYCParking_DW.[load].DimAddressTiming
	SELECT NEXT VALUE FOR addressTimingId AS addressTimingKey,
							convert(varchar(10),e.houseNum),
							convert(varchar(30),e.streetname),
							convert(varchar(30),e.intersectingstreet),
							convert(varchar(10),e.daysparkingineffect),
							convert(varchar(10),e.fromhoursineffect),
							convert(varchar(10),e.tohoursineffect),
							convert(varchar(10),e.violationcounty)
	FROM NYCParking_DW.[extract].addresstiming e
	WHERE NOT EXISTS ( SELECT 1
	FROM NYCParking_DW.[load].DimAddressTiming t
	WHERE e.houseNum = t.houseNum
	AND e.violationcounty = t.violationcounty
	AND e.fromhoursineffect = t.fromhoursineffect )

/*
MERGE [load].DimAddressTiming t USING (SELECT DISTINCT TOP 1000 * FROM [extract].addresstiming) AS e
			ON t.houseNum = e.houseNum AND t.violationcounty = e.violationcounty
			WHEN MATCHED
				THEN UPDATE SET
					t.houseNum = e.houseNum,
					t.streetname = e.streetname,
					t.intersectingstreet = e.intersectingstreet,
					t.daysparkingineffect = e.daysparkingineffect,
					t.fromhoursineffect = e.fromhoursineffect,
					t.tohoursineffect = e.tohoursineffect,
					t.violationcounty = e.violationcounty
			WHEN NOT MATCHED
			THEN INSERT (
							houseNum,
							streetname,
							intersectingstreet,
							daysparkingineffect,
							fromhoursineffect,
							tohoursineffect,
							violationcounty)
				VALUES(
							e.houseNum,
							e.streetname,
							e.intersectingstreet,
							e.daysparkingineffect,
							e.fromhoursineffect,
							e.tohoursineffect,
							e.violationcounty);
*/

/*
UPDATE [load].DimIssuer 
	SET 
	issuerpercent = convert(varchar(10),e.issuerpercent),
	issuercommand = convert(varchar(10),e.issuercommand),
	issuersquad = convert(varchar(10),e.issuersquad)
	FROM [extract].issuer e
	INNER JOIN [load].DimIssuer l ON e.issuerCode = l.issuerCode

INSERT INTO [load].DimIssuer
	SELECT NEXT VALUE FOR issuerId AS issuerKey,
			convert(varchar(10),e.issuerCode),
			convert(varchar(10),e.issuerpercent),
			convert(varchar(10),e.issuercommand),
			convert(varchar(10),e.issuersquad)
	FROM [extract].issuer e
	WHERE NOT EXISTS ( SELECT 1
	FROM [load].DimIssuer t
	WHERE e.issuerCode = t.issuerCode
	AND e.issuercommand = t.issuercommand)
	*/
	UPDATE NYCParking_DW.[load].DimLawCode 
	SET 
	violationdescription = convert(varchar(10),e.violationdescription),
	lawsection = convert(varchar(10),e.lawsection),
	subdivision = convert(varchar(10),e.subdivision)
	FROM NYCParking_DW.[extract].lawcode e
	INNER JOIN NYCParking_DW.[load].DimLawCode l ON e.violationcode = l.violationcode

INSERT INTO NYCParking_DW.[load].DimLawCode
	SELECT NEXT VALUE FOR lawCodeId AS lawCodeKey,
			convert(varchar(10),e.violationcode),
			convert(varchar(10),e.violationdescription),
			convert(varchar(10),e.lawsection),
			convert(varchar(10),e.subdivision)
	FROM NYCParking_DW.[extract].lawcode e
	WHERE NOT EXISTS ( SELECT 1
	FROM NYCParking_DW.[load].DimLawCode t
	WHERE e.violationcode = t.violationcode
	AND e.lawsection = t.lawsection)	

	UPDATE NYCParking_DW.[load].DimVehiclePlatetype 
	SET 
	platedescription = convert(varchar(10),e.platedescription)
	FROM NYCParking_DW.[extract].vehicleplatetype e
	INNER JOIN NYCParking_DW.[load].DimVehiclePlateType l ON e.platetype = l.platetype   												

INSERT INTO NYCParking_DW.[load].DimVehiclePlatetype
	SELECT NEXT VALUE FOR vehiclePlatetypeId AS vehiclePlatetypeKey,
			convert(varchar(10),e.platetype),
			convert(varchar(10),e.platedescription)
			
	FROM NYCParking_DW.[extract].vehicleplatetype e
	WHERE NOT EXISTS ( SELECT 1
	FROM NYCParking_DW.[load].DimVehiclePlateType t
	WHERE e.platetype = t.platetype)
/*
MERGE [load].DimVehicles t USING (SELECT DISTINCT * FROM [extract].vehicles) AS e
			ON e.plateID = t.plateID
	AND e.platetype = t.platetype
			WHEN MATCHED
				THEN UPDATE SET		
					t.vehicleexpdate = convert(varchar(10),e.vehicleexpdate),
					t.vehiclecolor = convert(varchar(10),e.vehiclecolor),
					t.unregisteredvehicles = convert(varchar(10),e.unregisteredvehicles);
				INSERT INTO [load].DimVehicles (
							plateID,
							registrationstate,
							platetype,
							vehiclebodytype,
							vehiclemake,
							vehicleexpdate,
							vehiclecolor,
							vehicleyear,
							unregisteredvehicles)
							SELECT convert(varchar(10),e.plateID),
							convert(varchar(10),e.registrationstate),
							convert(varchar(10),e.platetype),
							convert(varchar(10),e.vehiclebodytype),
							convert(varchar(10),e.vehiclemake),
							convert(varchar(10),e.vehicleexpdate),
							convert(varchar(10),e.vehiclecolor),
							convert(varchar(10),e.vehicleyear),
							convert(varchar(10),e.unregisteredvehicles) FROM [extract].vehicles e;

*/

UPDATE l
	SET 
	plateid = convert(varchar(10),e.plateid),
	issuedate = convert(DATE,e.issuedate),
	issuingagency = convert(varchar(10),e.issuingagency),
	streetcode1 = convert(varchar(10),e.streetcode1),
	streetcode2 = convert(varchar(10),e.streetcode2),
	streetcode3 = convert(varchar(10),e.streetcode3),
	voilationlocation = convert(varchar(10),e.voilationlocation),
	violationprecint = convert(varchar(10),e.violationprecint),
	issuerID = convert(INT,ti.issuerKey),
	violationtime = convert(varchar(10),e.violationtime),
	violationfrontopposite = convert(varchar(10),e.violationfrontopposite),
	lawcodeID = convert(INT,tl.lawCodeKey),
	addressparktimeID = convert(INT,ta.addressTimingKey),
	ispaid = convert(bit,e.ispaid)
	,amount = convert(money,e.amount)
	,severity = convert(tinyint,e.severity)
	FROM NYCParking_DW.[extract].tickets e
	INNER JOIN NYCParking_DW.[load].DimTickets l ON e.summonsnumber = l.summonsnumber
	INNER JOIN NYCParking_DW.[load].DimTickets tt ON e.summonsnumber = tt.summonsnumber
	INNER JOIN NYCParking_DW.[load].DimLawCode tl ON tl.violationcode = e.violationcode AND tl.subdivision = e.subdivision
	INNER JOIN NYCParking_DW.[load].DimIssuer ti ON ti.issuerCode = e.issuerCode
	INNER JOIN NYCParking_DW.[load].DimAddressTiming ta ON ta.houseNum = e.houseNum AND ta.intersectingstreet = e.intersectingstreet AND ta.streetname = e.streetname

INSERT INTO NYCParking_DW.[load].DimTickets
	SELECT NEXT VALUE FOR ticketId AS ticketKey,
							convert(BIGINT,e.summonsnumber),
							convert(varchar(10),e.plateid),
							convert(DATE,e.issuedate),
							convert(varchar(10),e.issuingagency),
							convert(varchar(10),e.streetcode1),
							convert(varchar(10),e.streetcode2),
							convert(varchar(10),e.streetcode3),
							convert(varchar(10),e.voilationlocation),
							convert(varchar(10),e.violationprecint),
							convert(INT,ti.issuerKey),
							convert(varchar(10),e.violationtime),
							convert(varchar(10),e.violationfrontopposite),
							convert(INT,tl.lawCodeKey),
							convert(INT,ta.addressTimingKey)
							,convert(bit,e.ispaid)
							,convert(money,e.amount)
							,convert(tinyint,e.severity)
	FROM NYCParking_DW.[extract].tickets e
	INNER JOIN NYCParking_DW.[load].DimLawCode tl ON tl.violationcode = e.violationcode AND tl.subdivision = e.subdivision
	INNER JOIN NYCParking_DW.[load].DimIssuer ti ON ti.issuerCode = e.issuerCode
	INNER JOIN NYCParking_DW.[load].DimAddressTiming ta ON ta.houseNum = e.houseNum AND ta.intersectingstreet = e.intersectingstreet AND ta.streetname = e.streetname
	WHERE NOT EXISTS ( SELECT 1
	FROM NYCParking_DW.[load].DimTickets t
	WHERE e.summonsnumber = t.summonsnumber)
			
INSERT INTO NYCParking_DW.[load].FactViolationMeasures 
		SELECT 
		t.ticketKey,
		dd.DateKey,
		vp.vehiclePlateTypeKey,
		v.vehicleKey,
		t.lawcodeID,
		t.issuerID,
		t.addressparktimeID
		,t.amount AS Amount
		--,AVG(t.amount) AS AvgAmount
		,(AVG(convert(tinyint,t.ispaid))*100) AS paidpercentage
		,AVG(t.severity) AS avgseverity
		FROM NYCParking_DW.[load].DimTickets t
		JOIN NYCParking_DW.[load].DimVehicles v
		ON t.plateID = v.plateID
		JOIN NYCParking_DW.[load].DimVehiclePlateType vp
		ON v.platetype = vp.platetype
		join load.DimDate dd
		on t.issuedate=dd.DateValue
		GROUP BY t.ticketKey,
		dd.DateKey,
		vp.vehiclePlateTypeKey,
		v.vehicleKey,
		t.lawcodeID,
		t.issuerID,
		t.addressparktimeID,
		t.amount
		
commit;
end try
begin catch
	rollback transaction
	 declare @errMsg nvarchar(max),@procName varchar(100)
 select @errMsg=ERROR_MESSAGE(),@procName=OBJECT_NAME(@@PROCID)
exec nycparking.dbo.usp_logger @procName,'Stored Procedure',@errMsg;
throw 50000,@errMsg,1
end catch
end
GO