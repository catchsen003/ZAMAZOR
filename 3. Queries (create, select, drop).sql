/* To view entire table */
select * from [ZAMAZOR].[dbo].[Order Report];
select * from [ZAMAZOR].[dbo].[Pincode Zones];
select * from [ZAMAZOR].[dbo].[SKU Master];
select * from [ZAMAZOR].[dbo].[Invoice];
select * from [ZAMAZOR].[dbo].[Rates];
select * from [ZAMAZOR].[dbo].[Output Data 1];

/* To view first row from all tables */
select top 1 * from [ZAMAZOR].[dbo].[Order Report];
select top 1 * from [ZAMAZOR].[dbo].[Pincode Zones];
select top 1 * from [ZAMAZOR].[dbo].[SKU Master];
select top 1 * from [ZAMAZOR].[dbo].[Invoice];
select top 1 * from [ZAMAZOR].[dbo].[Rates];
select top 1 * from [ZAMAZOR].[dbo].[Output Data 1];

/* Query to create table: [Order Report] */
create table [ZAMAZOR].[dbo].[Order Report]
(
[ExternOrderNo] bigint NOT NULL,
[SKU] nvarchar(13) NULL,
[Order Qty] int NULL
);

/* Query to create table: [Pincode Zones] */
create table [ZAMAZOR].[dbo].[Pincode Zones]
(
[Warehouse Pincode]	int NOT NULL,
[Customer Pincode]	int NOT NULL,
[Zone] char(1)
);

/* Query to create table: [SKU Master] */
create table [ZAMAZOR].[dbo].[SKU Master]
(
[SKU] nvarchar(13) NOT NULL,
[Weight (g)] int NULL
);

/* Query to create table: [Invoice] */
create table [ZAMAZOR].[dbo].[Invoice]
(
[AWB Code] bigint NOT NULL,
[Order ID]	int NOT NULL,
[Charged Weight] float NULL,
[Warehouse Pincode]	int NULL,
[Customer Pincode]	int NULL,
[Zone] char(1) NULL,
[Type of Shipment] nvarchar(23) NULL,
[Billing Amount (Rs.)] float NULL
);

/* Query to create table: [Rates] */
create table [ZAMAZOR].[dbo].[Rates]
(
[Shipment Code]	nvarchar(16) NOT NULL,
[Shipment Cost] float NULL
);

/* Query to create table: [Output Data 1] */
create table [ZAMAZOR].[dbo].[Output Data 1]
(
[Order ID] int NOT NULL,
[AWB Number] bigint NULL,
[Total weight as per ZAMAZOR (KG)] float NULL,
[Weight slab as per ZAMAZOR (KG)] float NULL,
[Total weight as per Courier Company (KG)] float NULL,
[Weight slab charged by Courier Company (KG)] float NULL,
[Delivery Zone as per ZAMAZOR] char(1) NULL,
[Delivery Zone charged by Courier Company] char(1) NULL,
[Expected Charge as per ZAMAZOR (Rs.)] float NULL,
[Charges Billed by Courier Company (Rs.)] float NULL,
[Difference Between Expected Charges and Billed Charges (Rs.)] float NULL
);

/* Query to drop all tables */
drop table [ZAMAZOR].[dbo].[Order Report];
drop table [ZAMAZOR].[dbo].[Pincode Zones];
drop table [ZAMAZOR].[dbo].[SKU Master];
drop table [ZAMAZOR].[dbo].[Invoice];
drop table [ZAMAZOR].[dbo].[Rates];
drop table [ZAMAZOR].[dbo].[Output Data 1];