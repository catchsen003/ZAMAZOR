/*
Output Data 1:
Create a resultant CSV/Excel file with the following columns:
1. Order ID
2. AWB Number
3. Total weight as per ZAMAZOR (KG)
4. Weight slab as per ZAMAZOR (KG)
5. Total weight as per Courier Company (KG)
6. Weight slab charged by Courier Company (KG)
7. Delivery Zone as per ZAMAZOR
8. Delivery Zone charged by Courier Company
9. Expected Charge as per ZAMAZOR (Rs.)
10. Charges Billed by Courier Company (Rs.) 
11. Difference Between Expected Charges and Billed Charges (Rs.)
*/

/* CTE for getting column 3: Total weight as per ZAMAZOR (KG) */
with cte_col_3 as 
(
select A.ExternOrderNo,
cast(cast(sum(A.[Order Qty]*C.[Weight (g)]) as decimal(10,2))/1000 as decimal(10,2))
as [Total weight as per ZAMAZOR (KG)]
from [ZAMAZOR].[dbo].[Order Report] as A
join [ZAMAZOR].[dbo].[SKU Master] as C
on A.SKU=C.SKU
group by A.ExternOrderNo
),
/* CTE for getting column 4: Weight slab as per ZAMAZOR (KG) */
cte_col_4 as 
(
select *,
case 
when [Total weight as per ZAMAZOR (KG)] between 0 and 0.50 then 0.5
when [Total weight as per ZAMAZOR (KG)] between 0.51 and 1.00 then 1
when [Total weight as per ZAMAZOR (KG)] between 1.01 and 1.50 then 1.5
when [Total weight as per ZAMAZOR (KG)] between 1.51 and 2.00 then 2
when [Total weight as per ZAMAZOR (KG)] between 2.01 and 2.50 then 2.5
when [Total weight as per ZAMAZOR (KG)] between 2.51 and 3.00 then 3
when [Total weight as per ZAMAZOR (KG)] between 3.01 and 3.50 then 3.5
when [Total weight as per ZAMAZOR (KG)] between 3.51 and 4.00 then 4
end 
as [Weight slab as per ZAMAZOR (KG)]
from cte_col_3
),
/* CTE for getting column 6: Weight slab charged by Courier Company (KG) */
cte_col_6 as 
(
select [Order ID],[Charged Weight], 
case 
when [Charged Weight] between 0 and 0.50 then 0.5
when [Charged Weight] between 0.51 and 1.00 then 1
when [Charged Weight] between 1.01 and 1.50 then 1.5
when [Charged Weight] between 1.51 and 2.00 then 2
when [Charged Weight] between 2.01 and 2.50 then 2.5
when [Charged Weight] between 2.51 and 3.00 then 3
when [Charged Weight] between 3.01 and 3.50 then 3.5
when [Charged Weight] between 3.51 and 4.00 then 4
when [Charged Weight] between 4.01 and 4.50 then 4.5
when [Charged Weight] between 4.51 and 5.00 then 5
end 
as [Weight slab charged by Courier Company (KG)]
from [ZAMAZOR].[dbo].[Invoice]
),
/* CTE for getting column 7: Delivery Zone as per ZAMAZOR */
cte_col_7 as
(
select 
D.[Warehouse Pincode],D.[Customer Pincode],
B.[Zone] as [Delivery Zone as per ZAMAZOR]
from [ZAMAZOR].[dbo].[Invoice] as D
join [ZAMAZOR].[dbo].[Pincode Zones] as B
on D.[Warehouse Pincode]=B.[Warehouse Pincode] and 
D.[Customer Pincode]=B.[Customer Pincode]
),
/* CTE for calculating the lot sizes (multiples) of Weight Slabs and 
combining those values with the previously computed CTE's */
cte_temp_table_01 as 
(
select 
distinct(D.[Order ID]) as [Order ID],
D.[AWB Code] as [AWB Number],
cte_col_3.[Total weight as per ZAMAZOR (KG)],
cte_col_4.[Weight slab as per ZAMAZOR (KG)],
D.[Charged Weight] as [Total weight as per Courier Company (KG)],
cte_col_6.[Weight slab charged by Courier Company (KG)],
cte_col_7.[Delivery Zone as per ZAMAZOR],
D.[Zone] as [Delivery Zone charged by Courier Company],
D.[Type of Shipment],
cast([Weight slab as per ZAMAZOR (KG)]/0.5 as int) as [Total_no.of times],
(cast([Weight slab as per ZAMAZOR (KG)]/0.5 as int) - (cast([Weight slab as per ZAMAZOR (KG)]/0.5 as int)-1)) as [Fixed_no.of times],
(cast([Weight slab as per ZAMAZOR (KG)]/0.5 as int)-1) as [Additional_no.of times],
D.[Billing Amount (Rs.)] as [Charges Billed by Courier Company (Rs.)]
from [ZAMAZOR].[dbo].[Invoice] as D
join [ZAMAZOR].[dbo].[Order Report] as A
on D.[Order ID]=A.ExternOrderNo
join [ZAMAZOR].[dbo].[SKU Master] as C
on A.SKU=C.SKU
join cte_col_3 
on cte_col_3.ExternOrderNo=A.ExternOrderNo
join cte_col_4
on cte_col_4.ExternOrderNo=A.ExternOrderNo
join cte_col_6
on cte_col_6.[Order ID]=A.ExternOrderNo
join cte_col_7
on cte_col_7.[Warehouse Pincode]=D.[Warehouse Pincode] and cte_col_7.[Customer Pincode]=D.[Customer Pincode]
),
/* CTE for calculating the Rates per Order ID: [Expected Charge as per ZAMAZOR (Rs.)] and 
combining those values with the previously computed CTE's */
cte_temp_table_02 as 
(
select *,
case 
/* case 1: Delivery Zone - 'a' and Type of Shipment - 'Forward charges' */
when [Delivery Zone as per ZAMAZOR]='a' and [Type of Shipment]='Forward charges' 
then 
(((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_a_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_a_additional')*[Additional_no.of times]))
/* case 2: Delivery Zone - 'b' and Type of Shipment - 'Forward charges' */
when [Delivery Zone as per ZAMAZOR]='b' and [Type of Shipment]='Forward charges' 
then 
(((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_b_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_b_additional')*[Additional_no.of times]))
/* case 3: Delivery Zone - 'c' and Type of Shipment - 'Forward charges' */
when [Delivery Zone as per ZAMAZOR]='c' and [Type of Shipment]='Forward charges' 
then 
(((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_c_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_c_additional')*[Additional_no.of times]))
/* case 4: Delivery Zone - 'd' and Type of Shipment - 'Forward charges' */
when [Delivery Zone as per ZAMAZOR]='d' and [Type of Shipment]='Forward charges' 
then 
(((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_d_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_d_additional')*[Additional_no.of times]))
/* case 5: Delivery Zone - 'e' and Type of Shipment - 'Forward charges' */
when [Delivery Zone as per ZAMAZOR]='e' and [Type of Shipment]='Forward charges' 
then 
(((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_e_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_e_additional')*[Additional_no.of times]))
/* case 6: Delivery Zone - 'a' and Type of Shipment - 'Forward and RTO charges' */
when [Delivery Zone as per ZAMAZOR]='a' and [Type of Shipment]='Forward and RTO charges' 
then 
(((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_a_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_a_additional')*[Additional_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'rto_a_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'rto_a_additional')*[Additional_no.of times]))
/* case 7: Delivery Zone - 'b' and Type of Shipment - 'Forward and RTO charges' */
when [Delivery Zone as per ZAMAZOR]='b' and [Type of Shipment]='Forward and RTO charges' 
then 
(((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_b_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_b_additional')*[Additional_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'rto_b_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'rto_b_additional')*[Additional_no.of times]))
/* case 8: Delivery Zone - 'c' and Type of Shipment - 'Forward and RTO charges' */
when [Delivery Zone as per ZAMAZOR]='c' and [Type of Shipment]='Forward and RTO charges' 
then 
(((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_c_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_c_additional')*[Additional_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'rto_c_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'rto_c_additional')*[Additional_no.of times]))
/* case 9: Delivery Zone - 'd' and Type of Shipment - 'Forward and RTO charges' */
when [Delivery Zone as per ZAMAZOR]='d' and [Type of Shipment]='Forward and RTO charges' 
then 
(((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_d_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_d_additional')*[Additional_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'rto_d_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'rto_d_additional')*[Additional_no.of times]))
/* case 10: Delivery Zone - 'e' and Type of Shipment - 'Forward and RTO charges' */
when [Delivery Zone as per ZAMAZOR]='e' and [Type of Shipment]='Forward and RTO charges' 
then 
(((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_e_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'fwd_e_additional')*[Additional_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'rto_e_fixed')*[Fixed_no.of times])+
((select [Shipment Cost] from [ZAMAZOR].[dbo].[Rates] where [Shipment Code] = 'rto_e_additional')*[Additional_no.of times]))
end as [Expected Charge as per ZAMAZOR (Rs.)]
from cte_temp_table_01
)

/* Final query to calculate the column 11: [Difference Between Expected Charges and Billed Charges (Rs.)] and
get the output is desired format*/

select [Order ID],[AWB Number],[Total weight as per ZAMAZOR (KG)],
[Weight slab as per ZAMAZOR (KG)],[Total weight as per Courier Company (KG)],
[Weight slab charged by Courier Company (KG)],[Delivery Zone as per ZAMAZOR],
[Delivery Zone charged by Courier Company],[Expected Charge as per ZAMAZOR (Rs.)],
[Charges Billed by Courier Company (Rs.)],
cast([Expected Charge as per ZAMAZOR (Rs.)]-[Charges Billed by Courier Company (Rs.)] as decimal(5,1))
as [Difference Between Expected Charges and Billed Charges (Rs.)]
from cte_temp_table_02;
