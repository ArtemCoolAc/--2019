--1-ый триггер

CREATE FUNCTION check_order() RETURNS trigger AS $$
DECLARE
  ID_price1 integer;
  ID_production1 integer;
BEGIN
  IF (TG_OP = 'INSERT') THEN
    ID_price1 = NEW . ID_price;
    ID_production1 = NEW . ID_production;
    IF (SELECT ID_production FROM unit_in_concrete_price_list WHERE unit_in_concrete_price_list.ID_price = ID_price1 AND unit_in_concrete_price_list.ID_production = ID_production1) IS NULL THEN
      ROLLBACK;
    ELSE
      --INSERT INTO string_order(ID_order, ID_production, ID_invoice, ID_price, quantity) values (new.ID_order, new.ID_production, new.ID_invoice, new.ID_price, new.quantity);
    end if;
  end if;

RETURN new;
END;
$$ language plpgsql;

CREATE TRIGGER trigger1
AFTER INSERT OR UPDATE ON string_order
  FOR EACH ROW EXECUTE PROCEDURE check_order();


--2-ой триггер

CREATE FUNCTION check_quan() RETURNS trigger AS $$
DECLARE
  quantity1 integer;
  ID_prod integer;
  set_quan integer;
  prev_quan integer;
BEGIN
  quantity1 = NEW . quantity;
  ID_prod = NEW . ID_production;
  prev_quan = OLD. quantity;
  --
  if prev_quan is not null then
    quantity1:= abs(quantity1 - prev_quan);
end if;
  select into set_quan availability from unit WHERE unit.ID_production = ID_prod;
  set_quan = set_quan - quantity1;-- - quantity1;
  --raise notice 'Value set_quan: %', set_quan;
  IF (set_quan < 0) THEN
    ROLLBACK ;
  ELSE
    UPDATE unit SET availability = set_quan WHERE unit.ID_production = ID_prod;
    --UPDATE unit SET (select availability from unit WHERE unit.ID_production = ID_prod)=availability- quantity1;
  end if;
  RETURN new;
END;
$$ language plpgsql;

CREATE TRIGGER trigger2
AFTER INSERT OR UPDATE ON string_order
  FOR EACH ROW EXECUTE PROCEDURE check_quan();