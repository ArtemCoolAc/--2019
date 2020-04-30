--1-я процедура

--ID_unit, quantity, passport, ID_invoice, ID_price, ID_pastry, ID_order
CREATE OR REPLACE FUNCTION form_order(int, int, VARCHAR(30), int, int, int, inout id_ord int, out comment_message varchar(30))
AS $$
DECLARE
  ID_cust int;
  ID_inv int;
  Prod_cost numeric(6,2);
  Cur_cost numeric(6,2);
  ID_new_ord int;
  --comment_message varchar(30);
  ID_cust_belong int;
  Cur_quan int;
BEGIN
  comment_message:='Успех';
  IF ((select ID_order from ordering where ID_order = id_ord) is null and id_ord is not null)
       or (select ID_production from unit where ID_production = $1) is null
       or (select ID_customer from customer where Passport_data = $3) is null
       or ((select ID_invoice from ordering where ID_invoice = $4 and ID_customer = (select ID_customer from customer where Passport_data = $3)) is null and id_ord is not null)
       --or (select ID_price from ) is null
    then
    comment_message:='Введенные данные некорректны';
  ELSEIF id_ord IS NULL then -- если такого заказа не существует
    select into ID_cust ID_customer from customer where customer.Passport_data = $3;
    --select into ID_inv ID_invoice from ordering where ordering.ID_customer = ID_cust;
    select into Prod_cost cost_value from unit where unit.ID_production = $1;
    Prod_cost:= Prod_cost * $2;
    insert into ordering(ID_invoice, ID_price, ID_customer, ID_pastry, total_cost, date_order)
    values ($4, $5, ID_cust, $6, Prod_cost, current_timestamp) returning ID_order into ID_new_ord;
    insert into string_order(ID_order, ID_production, ID_invoice, ID_price, quantity)
    values (ID_new_ord, $1, $4, $5, $2);
  ELSEIF id_ord IS NOT NULL then -- если такой заказ существует
    raise notice 'Заказ существует';
    select into ID_cust ID_customer from customer where customer.Passport_data = $3; -- ID клиента по паспорту
    select into ID_cust_belong ID_customer from ordering where ordering.ID_order = id_ord; -- ID клиента по заказу
    IF ID_cust_belong != ID_cust then
      comment_message:='Заказ не принадлежит клиенту';
    ELSEIF (select ID_production from string_order where string_order.ID_order=id_ord and string_order.ID_production=$1) is NULL then --если строки с таким продуктом нет
      raise notice 'Строки с таким продуктом нет';
      insert into string_order(ID_order, ID_production, ID_invoice, ID_price, quantity) --добавляем новый заказ
      values (id_ord, $1, $4, $5, $2);
      select into Prod_cost cost_value from unit where unit.ID_production = $1; --цена продукта
      Prod_cost:= Prod_cost * $2; --стоимость продукта
      select into Cur_cost total_cost from ordering where ID_order = id_ord; -- текущая стоимость
      Cur_cost:= Cur_cost + Prod_cost; -- увеличиваем стоимость заказа на стоимость продукта
      update ordering set total_cost = Cur_cost where ID_order = id_ord;
    ELSE -- если строка с таким продуктом есть
      raise notice 'Строка с таким продуктом есть';
      --insert into string_order(ID_order, ID_production, ID_invoice, ID_price, quantity) values (id_ord, $1, $4, $5, $2);
      select into Prod_cost cost_value from unit where unit.ID_production = $1; -- цена продукта
      raise notice 'Цена этого продукта %', Prod_cost;
      Prod_cost:= Prod_cost * $2; -- стоимость добавленного продукта
      raise notice 'Стоимость для добавления %', Prod_cost;
      select into Cur_cost total_cost from ordering where ID_order = id_ord; -- текущая стоимость
      raise notice 'Текущая цена %', Cur_cost;
      Cur_cost:= Cur_cost + Prod_cost; -- стоимость со стоимостью добавленного продукта
      raise notice 'Цена после добавления %', Cur_cost;
      update ordering set total_cost = Cur_cost where ID_order = id_ord;
      select into Cur_quan quantity from string_order where ID_order = id_ord and ID_production = $1; -- текущее количество продукта в заказе
      raise notice 'Текущее количество продуктов в строке заказа %', Cur_quan;
      Cur_quan:= Cur_quan + $2; -- увеличиваем на значение из параметров
      raise notice 'Количество продуктов после добавления %', Cur_quan;
      update string_order set quantity = Cur_quan where ID_order = id_ord and ID_production = $1;
    end if;

  end if;

END;
  $$ LANGUAGE plpgsql;

--2-я процедура

CREATE OR REPLACE FUNCTION correct_prices(varchar(20), out comment_message varchar(50))
AS $$
DECLARE
  id_need_shop int;
  id_need varchar(30);
  device_average numeric(5,2);
  production_average numeric(5,2);
  nessesary_average numeric(5,2);
  current_cost numeric(5,2);
  id_str int;
  id_dev int;
  id_prod int;
  g_cost numeric(5,2);
  my_cursor cursor for select ID_string, ID_device, ID_production, good_cost
  from shop_price_list_string
  where (ID_shop = (select ID_shop from shop where shop_name = $1))
  order by ID_string
  for update;
BEGIN
  comment_message:='Успех';
  select into id_need_shop ID_shop from shop where shop_name = $1;
  raise notice 'ID_shop = %', id_need_shop;
  id_need:= id_need_shop::varchar(30);
  IF id_need is null then
    comment_message:='Магазина с таким названием не существует';
  ELSE
    select into device_average avg(good_cost) from shop_price_list_string where ID_production is null and ID_shop = id_need_shop;
    select into production_average avg(good_cost) from shop_price_list_string where ID_device is null and ID_shop = id_need_shop;
    open my_cursor;
    loop
      fetch my_cursor into id_str, id_dev, id_prod, g_cost;
      current_cost:=g_cost;
      if not found then exit; end if;
      if id_dev is null then
        nessesary_average:=production_average;
      else nessesary_average:=device_average;
      end if;
      current_cost:= current_cost - (current_cost-nessesary_average) * 0.25;
      update shop_price_list_string set good_cost = current_cost where current of my_cursor;
    end loop;
    close my_cursor;
  end if;
END;
  $$ LANGUAGE plpgsql;