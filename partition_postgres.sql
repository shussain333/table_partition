drop table if exists orders ;

create table orders (
	id uuid,
	product_id uuid,
	order_total float,
	order_date timestamp,
	placed_by varchar,
	placed_by_device varchar check (placed_by_device in('iPhone', 'Browser', 'android'))
) partition by range(order_date);


create table orders_y2025m10
partition of orders
for values from ('2024-01-01') to ('2025-01-01');

alter table orders_y2025m10 rename to orders_y2024;

create table orders_y2025m11
partition of orders
for values from ('2025-01-01') to ('2026-01-01');

alter table orders_y2025m11 rename to orders_y2025;


CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

insert into orders
values (uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone');

create table orders_y2026 (
	id uuid,
	product_id uuid,
	order_total float,
	order_date timestamp,
	placed_by varchar,
	placed_by_device varchar check (placed_by_device in('iPhone', 'Browser', 'android'))
);

alter table orders_y2026
  drop constraint orders_y2026_placed_by_device_check;

alter table orders_y2026
  add constraint orders_placed_by_device_check
  check (placed_by_device in ('iPhone', 'Browser', 'android'));

alter table orders_y2026
  add constraint orders_y2026_order_date_check
  check (order_date >= '2026-01-01' and order_date < '2027-01-01');

alter table orders
  attach partition orders_y2026
  for values from ('2026-01-01') to ('2027-01-01');


create table orders_2027
partition of orders
for values from ('2027-01-01') to ('2028-01-01');

insert into orders
values (uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP + interval '1 year', 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 22.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 232.45, CURRENT_TIMESTAMP + interval '2 year', 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 231.45, CURRENT_TIMESTAMP + interval '1 year', 'shussain', 'iPhone');


create table orders_default
partition of orders
default;

insert into orders
values (uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP + interval '6 year', 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 22.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 232.45, CURRENT_TIMESTAMP + interval '4 year', 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 231.45, CURRENT_TIMESTAMP + interval '3 year', 'shussain', 'iPhone');


alter table orders
add constraint orders_pk primary key (id, order_date);





