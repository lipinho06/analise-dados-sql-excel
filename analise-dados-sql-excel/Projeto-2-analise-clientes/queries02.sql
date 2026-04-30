-- (Query 1) Gênero dos leads
-- Colunas: gênero, leads(#)
select
	case
		when gen.gender = 'female' then 'mulheres'
		when gen.gender = 'male' then 'homens'
		end as genero,
	count(*) as "leads (#)"

from sales.customers as cus
left join temp_tables.ibge_genders as gen
	on lower(cus.first_name) = lower(gen.first_name)

group by genero
order by "leads (#)" desc


-- (Query 2) Status profissional dos leads
-- Colunas: status profissional, leads (%)
select 
	case 
		when professional_status = 'freelancer' then 'freelancer'
		when professional_status = 'retired' then 'aposentado(a)'
		when professional_status = 'clt' then 'clt'
		when professional_status = 'self_employed' then 'autônomo(a)'
		when professional_status = 'other' then 'outro'
		when professional_status = 'businessman' then 'empresário(a)'
		when professional_status = 'civil_servant' then 'funcionário(a) público(a)'
		when professional_status = 'student' then 'estudante'
		end as "status profissional",
		(count(*)::float)/(select count(*) from sales.customers) as "leads (%)"
from sales.customers
group by "status profissional"
order by "leads (%)"
-- (Query 3) Faixa etária dos leads
-- Colunas: faixa etária, leads (%)
select
	case
		when datediff('years', birth_date, current_date) < 20 then '0-20'
		when datediff('years', birth_date, current_date) < 40 then '20-40'
		when datediff('years', birth_date, current_date) < 60 then '40-60'
		when datediff('years', birth_date, current_date) < 80 then '60-80'
		else '80+' end "faixa etária",
		count(*)::float/(select count(*) from sales.customers) as "leads (%)"

from sales.customers
group by "faixa etária"
order by "faixa etária" desc
-- (Query 4) Faixa salarial dos leads
-- Colunas: faixa salarial, leads (%), ordem
select 
	case
		when income <= 5000 then '0-5000'
		when income between 5000 and 10000 then '5000-10000'
		when income between 10000 and 15000 then '10000-15000'
		when income between 15000 and 20000 then '15000-20000'
		else '20000+' end "faixa salarial",
		count(*)::float/(select count(*) from sales.customers) as "leads (%)",
	case
		when income <= 5000 then 1
		when income between 5000 and 10000 then 2
		when income between 10000 and 15000 then 3
		when income between 15000 and 20000 then 4
		else 5 end as "ordem"
from sales.customers
group by "faixa salarial", "ordem"
order by "ordem" desc
-- (Query 5) Classificação dos veículos visitados
-- Colunas: classificação do veículo, veículos visitados (#)
-- Regra de negócio: Veículos novos tem até 2 anos e seminovos acima de 2 anos
with
	classificacao_veiculos as (
	
		select
			fun.visit_page_date,
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'novo'
				else 'seminovo'
				end as "classificação do veículo"
		
		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id	
	)

select
	"classificação do veículo",
	count(*) as "veículos visitados (#)"
from classificacao_veiculos
group by "classificação do veículo"
-- (Query 6) Idade dos veículos visitados
-- Colunas: Idade do veículo, veículos visitados (%), ordem
with
	 idade_do_veículo as (
	
		select
			fun.visit_page_date,
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year as idade_veiculo,
			case
				when (extract('year' from visit_page_date) - pro.model_year)<=2 then 'Até 2 anos'
				when (extract('year' from visit_page_date) - pro.model_year) between 2 and 4 then '2 á 4 anos'
				when (extract('year' from visit_page_date) - pro.model_year) between 4 and 6 then '4 á 6 anos'
				when (extract('year' from visit_page_date) - pro.model_year) between 6 and 8 then '6 á 8 anos'
				when (extract('year' from visit_page_date) - pro.model_year) between 8 and 10 then '8 á 10 anos'
				else 'acima de 10 anos'
				end as "idade do veículo",
			case
				when (extract('year' from visit_page_date) - pro.model_year)<=2 then 1
				when (extract('year' from visit_page_date) - pro.model_year) between 2 and 4 then 2
				when (extract('year' from visit_page_date) - pro.model_year) between 4 and 6 then 3
				when (extract('year' from visit_page_date) - pro.model_year) between 6 and 8 then 4
				when (extract('year' from visit_page_date) - pro.model_year) between 8 and 10 then 5
				else 6
				end as "ordem"
		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id	
	)

select
	"idade do veículo", 
	(count(*)::float /(select count(*) from idade_do_veículo)) as "veículos visitados (#)",
	"ordem"
from idade_do_veículo
group by "idade do veículo", "ordem" 
order by "ordem" 

-- (Query 7) Veículos mais visitados por marca
-- Colunas: brand, model, visitas (#)
select
	pro.brand,
	pro.model,
	count(*) as "visitas (#)"


from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id

group by pro.brand, pro.model
order by pro.brand, pro.model, "visitas (#)"


