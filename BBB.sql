--#region DATABASE (SSMSBoost add-in for collapsible regions)
USE master
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'BBB_silj4261') -- ((IF DB_ID('MovieDB') IS NOT NULL) error if database is created, but otherwise empty)
BEGIN
ALTER DATABASE BBB_silj4261 SET SINGLE_USER WITH ROLLBACK IMMEDIATE 
DROP DATABASE BBB_silj4261
END
GO

CREATE DATABASE BBB_silj4261
GO
USE BBB_silj4261
GO
--#endregion DATABASE

--#region CREATE TABLE
CREATE TABLE Laundromats(
Id INT IDENTITY (1, 1) PRIMARY KEY,
Laundromat NVARCHAR(50) NOT NULL,
OpenHours TIME,
ClosedHours TIME
)

CREATE TABLE Users(
Id INT IDENTITY (1, 1) PRIMARY KEY,
[Name] NVARCHAR(50) NOT NULL,
Mail NVARCHAR (50) NOT NULL UNIQUE,
[Password] NVARCHAR(50) CHECK (DATALENGTH(Password) > 5), -- DATALENGTH(bytes) VS. LEN(characters(whitespace not included))
AccountBalance DECIMAL(18,2) DEFAULT 0,
CreationDate DATETIME,
Laundromat_Id INT FOREIGN KEY REFERENCES Laundromats(Id)
)

CREATE TABLE Machines(
Id INT IDENTITY (1, 1) PRIMARY KEY,
Machine NVARCHAR(50),
WashPrice DECIMAL(18,2),
WashTime INT,
Laundromat_Id INT FOREIGN KEY REFERENCES Laundromats(Id)
)

CREATE TABLE Bookings(
Id INT IDENTITY (1, 1) PRIMARY KEY,
BookingTime DATETIME,
[User_Id] INT FOREIGN KEY REFERENCES Users(Id),
Machine_Id INT FOREIGN KEY REFERENCES Machines(Id)
)
--#endregion

--#region INSERT
INSERT INTO Laundromats (Laundromat, OpenHours, ClosedHours) VALUES ('WhiteWash Inc.', '08:00', '20:00')
INSERT INTO Laundromats (Laundromat, OpenHours, ClosedHours) VALUES ('Double Bubble', '02:00', '22:00')
INSERT INTO Laundromats (Laundromat, OpenHours, ClosedHours) VALUES ('Wash & Coffee', '12:00', '20:00')

INSERT INTO Users([Name], Mail, [Password], AccountBalance, CreationDate, Laundromat_Id) VALUES ('John', 'john_doe66@gmail.com', 'password', 100.00, 2021-02-15, 2)
INSERT INTO Users([Name], Mail, [Password], AccountBalance, CreationDate, Laundromat_Id) VALUES ('Neil Armstrong', 'firstman@nasa.gov', 'eagleLander69', 1000.00, 2021-02-10, 1)
INSERT INTO Users([Name], Mail, [Password], AccountBalance, CreationDate, Laundromat_Id) VALUES ('Batman', 'noreply@thecave.cpm', 'Rob1n', 500.00, 2020-03-10, 3)
INSERT INTO Users([Name], Mail, [Password], AccountBalance, CreationDate, Laundromat_Id) VALUES ('Goldman Sachs', 'moneylaundering@gs.com', 'NotRecognized', 100000.00, 2021-01-01, 1)
INSERT INTO Users([Name], Mail, [Password], AccountBalance, CreationDate, Laundromat_Id) VALUES ('50 Cent', '50cent@gmail.com', 'ItsMyBirthday', 0.50, 2020-07-06, 3)

INSERT INTO Machines (Machine, WashPrice, WashTime, Laundromat_Id) VALUES ('Mielle 911 Turbo', 5.00, 60, 2)
INSERT INTO Machines (Machine, WashPrice, WashTime, Laundromat_Id) VALUES ('Siemons IClean', 10000.00, 30, 1)
INSERT INTO Machines (Machine, WashPrice, WashTime, Laundromat_Id) VALUES ('Electrolax FX-2', 15.00, 45, 2)
INSERT INTO Machines (Machine, WashPrice, WashTime, Laundromat_Id) VALUES ('NASA Spacewasher 8000', 500.00, 5, 1)
INSERT INTO Machines (Machine, WashPrice, WashTime, Laundromat_Id) VALUES ('The Lost Sock', 3.50, 90, 3)
INSERT INTO Machines (Machine, WashPrice, WashTime, Laundromat_Id) VALUES ('Yo Mama', 0.50, 120, 3)

INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES ('2021-02-26 12:00:00', 1, 1)
INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES ('2021-02-26 16:00:00', 1, 3)
INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES ('2021-02-26 08:00:00', 2, 4)
INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES ('2021-02-26 15:00:00', 3, 5)
INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES ('2021-02-26 20:00:00', 4, 2)
INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES ('2021-02-26 19:00:00', 4, 2)
INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES ('2021-02-26 10:00:00', 4, 2)
INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES ('2021-02-26 16:00:00', 5, 6)
GO
--#endregion

--#region TRANSACTION
BEGIN TRANSACTION BookingGS

DECLARE @date DATETIME, @time DATETIME -- A (to me) more readable version of the outcommented code on line 92. Easier to set an "uneven" time
SET @date = CAST(GETDATE() AS DATE)
SET @time = '11:59' -- 11:59 instead of 12:00, so it's not deleted at line 116
SET @date += @time

INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES (@date, 4, 2)
COMMIT TRANSACTION BookingGS
GO
--INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES (DATEADD(hour, 12, DATEDIFF(day, 0, GETDATE())), 4, 2)

--#endregion

--#region VIEW
CREATE VIEW BookingView AS
SELECT FORMAT(BookingTime, 'dd-MM-yyyy HH:mm') AS 'Booked times', Users.[Name], Machines.Machine, FORMAT(Machines.WashPrice, 'c', 'DA-dk') AS 'Price' FROM Bookings
JOIN Users ON Users.Id = Bookings.[User_Id]
JOIN Machines ON Machines.Id = Bookings.Machine_Id
GO

-- SELECT * FROM BookingView
--#endregion

--#region SELECT, DELETE, UPDATE
SELECT [Name], Mail FROM Users WHERE Mail like '%@gmail.com'

SELECT Machine, Laundromat, CONCAT(FORMAT(OpenHours, 'hh\:mm'), ' - ', FORMAT(ClosedHours, 'hh\:mm')) AS 'Business hours' FROM Machines
JOIN Laundromats ON Laundromats.Id = Laundromat_Id

SELECT Machine, COUNT(BookingTime) AS 'Bookings', STRING_AGG(FORMAT(BookingTime, 'dd-MM-yyyy hh:mm'), ', ') AS 'Already booked' FROM Bookings
JOIN Machines ON Machines.Id = Bookings.Machine_Id
GROUP BY Machines.Machine

DELETE FROM Bookings WHERE CAST(BookingTime AS TIME) BETWEEN '12:00' AND '13:00'

UPDATE Users SET [Password] = 'SelinaKyle' WHERE [Name] = 'Batman'
GO
--#endregion

--#region CREATE PROCEDURE
CREATE PROCEDURE NewBooking @Date DATETIME, @User INT, @Machine INT -- So.. I wanted to create a procedure, so I could separate it from the main query.
AS								    -- Would have been a great idea, if I didn't have to turn it in to another person (on another computer)

DECLARE @AccountBalance DECIMAL = (SELECT AccountBalance FROM Users WHERE Users.Id = @User) -- The amount of money on account
DECLARE @WashPrice DECIMAL(18,2) = (SELECT WashPrice FROM Machines WHERE Machines.Id = @Machine) -- The price of a single wash on chosen machine

DECLARE @LaundromatMachine INT = (SELECT Laundromat_Id FROM Machines WHERE Machines.Id = @Machine) -- Bridge table for line 131 and 132

DECLARE @OpenHours TIME = (SELECT OpenHours FROM Laundromats WHERE Laundromats.Id = (@LaundromatMachine)) -- Open hours at laundromat where machine is installed
DECLARE @ClosedHours TIME = (SELECT ClosedHours FROM Laundromats WHERE Laundromats.Id = (@LaundromatMachine)) -- Closed -||-

IF NOT EXISTS(SELECT * FROM Bookings WHERE BookingTime like @Date) -- Continues if booking time isn't already taken
BEGIN
	IF ((@WashPrice) <= (@AccountBalance))-- Checks if the blance of the account can cover the cost of a wash
	BEGIN
		IF (CAST(@Date AS TIME) BETWEEN (@OpenHours) AND (@ClosedHours)) -- Checks if the laundromat is even open at requested time
		BEGIN
			INSERT INTO Bookings (BookingTime, [User_Id], Machine_Id) VALUES (@Date, @User, @Machine) -- Inserts the local variables into a new booking
			UPDATE Users SET AccountBalance -= @WashPrice WHERE Users.Id = @User -- Removes the cost of a wash from the users account after succesful booking
		END
	END			
END
GO
--#endregion

--#region USE PROCEDURE
DECLARE @Date DATETIME = '2017-02-26 14:00:00' -- For "easier" input of data
DECLARE @User INT = 3
DECLARE @Machine INT = 5 

SELECT AccountBalance FROM Users WHERE Users.Id = @User -- Account balance BEFORE booking

EXEC NewBooking @Date, @User, @Machine

SELECT * FROM BookingView
SELECT AccountBalance FROM Users WHERE Users.Id = @User -- Account balance AFTER booking
--#endregion
