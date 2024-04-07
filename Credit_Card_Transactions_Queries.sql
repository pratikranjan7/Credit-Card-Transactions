
-- 1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

with
	cte
	as
	
	(
		select city, sum(amount) as total
		from [credit_card_transcations]
		group by city
	),
	cte2
	as
	
	(
		select sum(amount) as spent
		from [credit_card_transcations]
	)
select top 5
	city, cast(((total*1.0)/spent)*100 as decimal(3,1)) as percentage_contribution
from cte c1
	join cte2 c2
	on 1=1
order by total desc



-- 2- write a query to print highest spend month for each year and amount spent in that month for each card type

with
	cte
	as
	
	(
		select MONTH(transaction_date) month, YEAR(transaction_date) year, card_type, sum(amount) as amount
		from [credit_card_transcations]
		group by YEAR(transaction_date),card_type,MONTH(transaction_date)
	)

select year, month, card_type, amount
from(select *, DENSE_RANK() over(partition by card_type, year order by amount desc) as rn
	from cte)x
where rn = 1
order by year desc,amount desc




-- 3- write a query to print the transaction details(all columns from the table) for each card type when
-- it reaches a cumulative of 10,00,000 total spends(We should have 4 rows in the o/p one for each card type)

with
	cte
	as
	
	(
		select *, dense_rank() over(partition by card_type order by sum) as rn
		from(select *,
				sum(amount) over(partition by card_type order by transaction_date,transaction_id) as sum
			from [credit_card_transcations])x
		where sum > = 1000000
	)

select *
from cte
where rn=1


-- 4- write a query to find city which had lowest percentage spend for gold card type
with
	cte
	as
	
	(
		select city, card_type, sum(amount) as spent_amount
		from [credit_card_transcations]
		where card_type='gold'
		group by city,card_type
	),

	cte2
	as
	
	(
		select sum(amount) as total_spent_amount
		from [credit_card_transcations]
		where card_type='gold'
	)

select city, ((total_spent_amount*1.0)/spent_amount)*100   as lowest_percentage
from cte as c1
	join cte2 as c2
	on 1=1
order by spent_amount



-- 5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

with
	cte
	as
	
	(
		select *, dense_rank() over(partition by city order by spent desc) as highest_expense_type,
			dense_rank() over(partition by city order by spent) as lowest_expense_type
		from(select city, exp_type, sum(amount) as spent
			from [credit_card_transcations]
			group by city,exp_type
)x
	)

select city, max(spent) as max_spent,
	min(case when highest_expense_type =1 then exp_type
end) as highest_expense_type,
	min(spent) as min_spent,
	min(case when lowest_expense_type =1 then exp_type
end) as lowest_expense_type
from cte
group by city



-- 6- write a query to find percentage contribution of spends by females for each expense type

with cte
as
(select exp_type, sum(amount) as overall_spending_by_female
from [credit_card_transcations]
where gender = 'F'
group by exp_type)
,

cte2 as
(select exp_type, sum(amount) as overall_spending
from [credit_card_transcations]
group by exp_type)

select c1.exp_type,
	cast(((overall_spending_by_female*1.0)/overall_spending)*100 as decimal(3,1)) as percentage_contribution_by_females
from cte c1
	join cte2 c2
	on c1.exp_type = c2.exp_type


-- 7- which card and expense type combination saw highest month over month growth in Jan-2014

select *
from credit_card_transcations



-- 8- during weekends which city has highest total spend to total no of transcations ratio 

select top 1
	city, sum(amount)/COUNT(transaction_id) as ratio
from [credit_card_transcations]
where DATEPART(weekday,transaction_date) in (1,7)
group by city
order by ratio desc


-- 9- which city took least number of days to reach its 500th transaction after the first transaction in that city

with
	cte
	as
	
	(
		select *
		from(select *,
				dense_rank() over(partition by city order by transaction_date,transaction_id) as rnk
			from [credit_card_transcations])x
		where rnk = 2 or rnk =501
	)

select top 1
	city, datediff(day,min(transaction_date),max(transaction_date)) as days
from cte
group by city
having count(city) > 1
order by days



