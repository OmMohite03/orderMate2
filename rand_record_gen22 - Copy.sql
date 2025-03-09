-- truncate queries
 TRUNCATE TABLE orders_order, orders_dispatch, orders_received CASCADE;
 
select * from orders_order;
select * from orders_dispatch;
select * from orders_received;

truncate table users_user CASCADE ;
select * from users_user;

-- Insert random users 
WITH unique_users AS (
    SELECT DISTINCT ON (phone_number) 
        'user' || floor(random() * 100000)::INT AS username,  
        'user' || floor(random() * 100000)::INT || '@example.com' AS email_address,
        '987' || LPAD(floor(random() * 100000)::TEXT, 5, '0') AS phone_number,
        'address ' || floor(random() * 10000)::INT AS address
    FROM generate_series(1, 10000) AS g(num)
)
INSERT INTO users_user (username, email_address, phone_number, address)
SELECT username, email_address, phone_number, address 
FROM unique_users
ON CONFLICT (phone_number) DO NOTHING;
SELECT * FROM users_user


-- Insert random orders 
INSERT INTO orders_order (user_id, order_date_time, model_no, qty)
SELECT 
    (SELECT id FROM users_user ORDER BY RANDOM() LIMIT 1),  
    NOW() - (random() * interval '3 years'),
    'Model-' || floor(random() * 100)::TEXT,
    floor(random() * 10 + 1)  
FROM generate_series(1, 20);
select * from orders_order


INSERT INTO orders_dispatch (order_id, dispatch_person, dispatch_date_time)
SELECT o.order_id,
    'Dispatcher ' || floor(random() * 10),
    o.order_date_time + (random() * interval '30 days')
FROM orders_order o
WHERE o.qty > COALESCE(
    (SELECT COUNT(*) FROM orders_dispatch WHERE orders_dispatch.order_id = o.order_id), 
    0
)  
AND NOT EXISTS (
    SELECT 1 FROM orders_dispatch d WHERE d.order_id = o.order_id
)  
ORDER BY RANDOM()
LIMIT 15;
SELECT * FROM orders_dispatch;




-- Insert random received orders 
INSERT INTO orders_received (order_id, received_person, received_date_time)
SELECT d.order_id,
    'Receiver ' || floor(random() * 10),
    d.dispatch_date_time + (random() * interval '7 days')
FROM orders_dispatch d
WHERE (
    SELECT COUNT(*) FROM orders_received WHERE orders_received.order_id = d.order_id
) < (
    SELECT COUNT(*) FROM orders_dispatch WHERE orders_dispatch.order_id = d.order_id
) 
ORDER BY RANDOM()
LIMIT (SELECT COUNT(*) FROM orders_dispatch);

SELECT * FROM orders_received;
