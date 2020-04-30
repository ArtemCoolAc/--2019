--1-ый запрос

with T1(ID_pastry, income, rent_price) as (
  select pastry.ID_pastry, coalesce(sum(total_cost),0), Rent_price
   from pastry left join ordering on pastry.ID_pastry = ordering.ID_pastry
  group by pastry.ID_pastry
) select T1.*, emp_qty from T1 join (
  select pastry.ID_pastry, count(*) as emp_qty
  from pastry left join employee e on pastry.ID_pastry = e.ID_pastry
  group by pastry.ID_pastry
  ) as tab on T1.ID_pastry = tab.ID_pastry;

--2-ой запрос 1-я часть

with T1(production_name, ID_ingr, pieces_quantity, mass_quantity) as (
  select Production_name, ID_type, pieces_quantity, mass_quantity
  from recipe_string
         join production on recipe_string.ID_production = production.ID_production
  order by Production_name, ID_string
)
select T1.production_name, production.Production_name as ingr_name, T1.mass_quantity, T1.pieces_quantity
from T1 join production on T1.ID_ingr = production.ID_production;

--2-ой запрос 2-я часть

with recursive Recurs(ID_type, prod_name, ID_base_type, level) as (
select ID_type, Production_name, ID_base_type, 0 as level
  from ingredient join production p on ingredient.ID_type = p.ID_production
  where ID_base_type is null
  union all
  select t1.ID_type, p.Production_name, t1.ID_base_type, t2.level+1
  from ingredient t1 join production p on t1.ID_type = p.ID_production
  join Recurs t2 on t1.ID_base_type = t2.ID_type
)
select ID_type, ID_base_type, level, prod_name, Production_name as base_production from Recurs left join production on Recurs.ID_base_type = production.ID_production order by level


--3-ий запрос

with T4(Id_customer, income, order_quantity, exceptions_quantity) as (
with T3(Id_customer, income, order_quantity) as (
with T2(Id_customer, income, order_quantity) as (
  with T1(Id_customer, income) as (
    select c.ID_customer, coalesce(sum(total_cost), 0)
    from ordering
           right join customer c on ordering.ID_customer = c.ID_customer
    group by c.ID_customer
    order by c.ID_customer
  )
  select T1.*, count(*)
  from ordering join T1 on ordering.ID_customer = T1.Id_customer
  group by T1.ID_customer, T1.income
)
select customer.ID_customer, coalesce(income,0), coalesce(order_quantity,0)
from T2 right join customer on T2.Id_customer = customer.ID_customer)
select tab.*, T3.income, T3.order_quantity
from (
     with T11(Id_customer, exceptions_quantity) as (
       select ID_customer, count(*)
        from ordering join order_exceptions oe on ordering.ID_order = oe.ID_order join string_order_exception soe on oe.ID_exception = soe.ID_exception
        group by ID_customer)
     select customer.ID_customer, coalesce(exceptions_quantity, 0) from T11 right join customer on T11.Id_customer = customer.ID_customer
      ) as tab
  join T3 on tab.ID_customer = T3.Id_customer
  )
select customer.FIO_customer, customer.Passport_data, T4.income as order_quantity, T4.order_quantity as income, T4.exceptions_quantity, tab228.return_money from T4 join (
  select customer.ID_customer, coalesce(return_money,0) as return_money from
(with T22(ID_invoice,Id_customer, return_money) as (
  select distinct tab.ID_invoice, ID_customer, return_money
  from (select ID_invoice, sum(total_cost) as return_money
    from ordering
    group by ID_invoice) as tab
  join ordering on tab.ID_invoice = ordering.ID_invoice
)
select T22.Id_customer, T22.return_money from T22 right join invoice on T22.ID_invoice = invoice.ID_invoice
where return_mark is not null) as tab2
right join customer on tab2.Id_customer =  customer.ID_customer
  ) as tab228 on T4.ID_customer = tab228.ID_customer join customer on T4.ID_customer = customer.ID_customer;


--4-ый запрос

with T2(ID_type, ingr_name) as (
  with T1(ID_type, quantity) as (
    select ID_type, count(*)
    from recipe_string
    group by ID_type
  )
  select ID_type, Production_name
  from T1 join production on T1.ID_type = production.ID_production
  where quantity = (select max(quantity) from T1)
) select T2.*, count(*) as shop_quan, sum(good_availability) as ingr_quan, prod_quan
from T2 join shop_price_list_string on T2.ID_type = shop_price_list_string.ID_type
join (select ID_type, count(*) as prod_quan
from recipe_string
group by ID_type) as tab on T2.ID_type = tab.ID_type
group by T2.ID_type, T2.ingr_name, prod_quan ;


--5-ый запрос

with T2 as (
  with T1(ID_invoice, ID_employee, order_quan) as (
    select invoice.ID_invoice, ID_employee, count(*) as order_quan
    from invoice
           left join order_exceptions oe on invoice.ID_invoice = oe.ID_invoice
           join ordering o on invoice.ID_invoice = o.ID_invoice
    group by invoice.ID_invoice)
  select T1.ID_employee, count(*) as invoice_quan, sum(T1.order_quan) as order_quan
  from T1
  group by ID_employee
) select T2.ID_employee, employee.FIO, employee.Passport_data, employee.month_salary, T2.invoice_quan, T2.order_quan, tt.employee_order_qty, income, coalesce(inv_exc,0) as exception_qty, coalesce(invoice_exception,0) as loss from T2 join
  (select tab.ID_employee, sum(inv_unit_qty) as employee_order_qty
from (select string_order.ID_invoice, ID_employee, sum(quantity) as inv_unit_qty
from string_order join invoice i on string_order.ID_invoice = i.ID_invoice
group by string_order.ID_invoice, ID_employee) as tab
group by ID_employee) as tt on T2.ID_employee = tt.ID_employee join
  (select ID_employee, sum(cost_value * quantity) as income
from invoice join string_order so on invoice.ID_invoice = so.ID_invoice join unit u on so.ID_production = u.ID_production
group by ID_employee) as ttt on T2.ID_employee = ttt.ID_employee left join (
  select ID_employee, tb.*
from
  (select soe.ID_invoice,count(*) as inv_exc, sum(cost_value * quantity) as invoice_exception
from order_exceptions join string_order_exception soe on order_exceptions.ID_exception = soe.ID_exception join unit on soe.ID_production = unit.ID_production
group by soe.ID_invoice) as tb join invoice on tb.ID_invoice = invoice.ID_invoice
  ) as tbbb on T2.ID_employee = tbbb.ID_employee join employee on T2.ID_employee = employee.ID_number
where T2.invoice_quan = (select max(T2.invoice_quan) from T2);