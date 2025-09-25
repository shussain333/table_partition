# Create a table partition on Postgres DB
Partition helps, to improve the performance, manageability or scalability of large datasets.
**You can find below queries at one place [partition.sql](partition_postgres.sql)**

## Drop table if already exists
```drop table if exists orders;```

## Create parent table with Range partition
You can create a partition table by specifying a partition column.

**Note-** Partition table cannot have constraint(primary key, unique key) alone, but null check or other check it can hold. 
If this table is having a primary constraint then that should be included with the combination of partition key. 
Means it can have composite key. 

**Table without constraint but with a single check**
```
create table orders (
id uuid,
product_id uuid,
order_total float,
order_date timestamp,
placed_by varchar,
placed_by_device varchar check (placed_by_device in('iPhone', 'Browser', 'android'))
) partition by range(order_date);
```

## Create child table with range limit
Child partition table should have `limit` based on `from` and `to`.

**Note** You cannot have multiple child partition tables under the same range or overlapping range.
```
create table orders_y2025m10
partition of orders
for values from ('2024-01-01') to ('2025-01-01');
```

## Rename child partition
Similar to normal table `rename`, you can also `rename` partition.
```
alter table orders_y2025m10 rename to orders_y2024;
```

## You can create `N` number of partition
As you have seen above, we have created `orders_y2025m10` for `orders` table, and still we are creating one more.
```
create table orders_y2025m11
partition of orders
for values from ('2025-01-01') to ('2026-01-01');
```

## Rename another child partition
Similar to normal table `rename`, you can also `rename` partition.
```
alter table orders_y2025m11 rename to orders_y2025;
```

## Enable extension, so that we can generate random UUID
**On a lighter note** Extension is a package of sql objects (function, data types, operators, index types etc..) that adds extra 
functionality to your database.
```
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## Insert the data into Parent table
We will always insert the data into `parent` table and then it is a **duty** of `parent table` to distribute the data to the partitioned `child` table.

```
insert into orders
values (uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone');
```

## Create another table
#### Let's create another table, which will be added to `orders` partition table in the later steps.
~~~
create table orders_y2026 (
id uuid,
product_id uuid,
order_total float,
order_date timestamp,
placed_by varchar,
placed_by_device varchar check (placed_by_device in('iPhone', 'Browser', 'android'))
);
~~~

## Prerequisite to make `orders_y2026` table compatible, so that, later this table can be added as child partition table
Here are few steps which we will have to follow -
1. Alter table to drop the constraint, because, when later we will make `orders_y2026` table child partition, then it will get all the property of its parent by default.
    ~~~
    alter table orders_y2026
    drop constraint orders_y2026_placed_by_device_check;
   ~~~

2. Add the constraint with the same name as parent table.
   ~~~
    alter table orders_y2026
    add constraint orders_placed_by_device_check
    check (placed_by_device in ('iPhone', 'Browser', 'android'));
   ~~~

3. Add the partition range on this table, which will be acting as check, but later (After `orders_y2026` table gets attached with `order` table) you can drop it also.
   ~~~
    alter table orders_y2026
    add constraint orders_y2026_order_date_check
    check (order_date >= '2026-01-01' and order_date < '2027-01-01');
   ~~~
   
4. Now it's time to attach `orders_y2026` new table into parent `orders` table, since it is completely ready for becoming part of partition.
   ~~~
    alter table orders
    attach partition orders_y2026
    for values from ('2026-01-01') to ('2027-01-01');
   ~~~

## Let's create another partition to check if it still allows partition creation
~~~
create table orders_2027
partition of orders
for values from ('2027-01-01') to ('2028-01-01');
~~~

## Try inserting multiple values together - SQL statement
~~~
insert into orders
values (uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP + interval '1 year', 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 22.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 232.45, CURRENT_TIMESTAMP + interval '2 year', 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 231.45, CURRENT_TIMESTAMP + interval '1 year', 'shussain', 'iPhone');
~~~

## Create default partition in postgres for parent table
In PostgreSQL you can create a default partition, but it’s not without a range, instead, it’s a special partition that 
catches all rows that don’t fit into any defined range/list.
~~~
create table orders_default
partition of orders
default;
~~~

## We will try to insert mix of records which will fall under range partition or default range partition
~~~
insert into orders
values (uuid_generate_v4(), uuid_generate_v4(), 23.45, CURRENT_TIMESTAMP + interval '6 year', 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 22.45, CURRENT_TIMESTAMP, 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 232.45, CURRENT_TIMESTAMP + interval '4 year', 'shussain', 'iPhone'),
(uuid_generate_v4(), uuid_generate_v4(), 231.45, CURRENT_TIMESTAMP + interval '3 year', 'shussain', 'iPhone');
~~~

## Add primary key to the Partition table
As I have mentioned above, you can have primary key, but if table is a partition table on column, then that column should also be part of primary key
~~~
alter table orders
add constraint orders_pk primary key (id, order_date);
~~~




