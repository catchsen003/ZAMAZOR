/*
Output Data 2:
Create a summary table
Row 1: Total orders where ZAMAZOR has been correctly charged, <count>, <total invoice amount>
Row 2: Total Orders where ZAMAZOR has been overcharged, <count>, <total overcharging amount>
Row 3: Total Orders where ZAMAZOR has been undercharged, <count>, <total undercharging amount>
*/

/* CTEs for Row 1*/
with cte_count_correctly_charged as 
(
select count([Order ID]) as [Count]
from [ZAMAZOR].[dbo].[Output Data 1]
where [Expected Charge as per ZAMAZOR (Rs.)]=[Charges Billed by Courier Company (Rs.)]
),
cte_sum_correctly_charged as 
(
select sum([Expected Charge as per ZAMAZOR (Rs.)]) as [Sum]
from [ZAMAZOR].[dbo].[Output Data 1]
where [Expected Charge as per ZAMAZOR (Rs.)]=[Charges Billed by Courier Company (Rs.)]
)
/* Query for Row 1*/
select 'Total orders where ZAMAZOR has been correctly charged' as [Summary Title],[Count],[Sum]
from cte_count_correctly_charged,cte_sum_correctly_charged;

/* CTE for Row 2*/
with cte_count_overcharged as 
(
select count([Order ID]) as [Count]
from [ZAMAZOR].[dbo].[Output Data 1]
where [Expected Charge as per ZAMAZOR (Rs.)]<[Charges Billed by Courier Company (Rs.)]
),
cte_sum_overcharged as 
(
select (cast(sum([Difference Between Expected Charges and Billed Charges (Rs.)]) as decimal(5,1))*(-1)) as [Sum]
from [ZAMAZOR].[dbo].[Output Data 1]
where [Expected Charge as per ZAMAZOR (Rs.)]<[Charges Billed by Courier Company (Rs.)]
)
/* Query for Row 2*/
select 'Total Orders where ZAMAZOR has been overcharged' as [Summary Title],[Count],[Sum]
from cte_count_overcharged,cte_sum_overcharged;

/* CTE for Row 3*/
with cte_count_undercharged as 
(
select count([Order ID]) as [Count]
from [ZAMAZOR].[dbo].[Output Data 1]
where [Expected Charge as per ZAMAZOR (Rs.)]>[Charges Billed by Courier Company (Rs.)]
),
cte_sum_undercharged as 
(
select cast(sum([Difference Between Expected Charges and Billed Charges (Rs.)]) as decimal(5,1)) as [Sum]
from [ZAMAZOR].[dbo].[Output Data 1]
where [Expected Charge as per ZAMAZOR (Rs.)]>[Charges Billed by Courier Company (Rs.)]
)
/* Query for Row 3*/
select 'Total Orders where ZAMAZOR has been undercharged' as [Summary Title],[Count],[Sum]
from cte_count_undercharged,cte_sum_undercharged;
