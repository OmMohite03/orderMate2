-- truncate queries
 TRUNCATE TABLE orders_order, orders_dispatch, orders_received CASCADE;
 
select * from orders_order;
select * from orders_dispatch;
select * from orders_received;

truncate table users_user CASCADE;
select * from users_user;


-- 2nd March 2025 code, 
-- desired randomness in records is achieved

-- issues:
-- dispatch & received exceed actual orders for 2 specific dates, 
	--	2023-07 (0-1-1) 
	-- 	2024-01 (1-0-1)
	-- 	2024-02 (0-1-1) 
-- only 2,1,0 counts are being added?
	
-- blank data is being stored -- (which "blank" data?? where?)

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
ORDER BY username DESC


-- Insert random orders (ensuring proper linking with users) 
INSERT INTO orders_order (user_id, order_date_time, model_no, qty)
SELECT 
    (SELECT id FROM users_user ORDER BY RANDOM() LIMIT 1),  
    NOW() - (random() * interval '3 years'),
    'Model-' || floor(random() * 100)::TEXT,
    floor(random() * 10 + 1)  -- Ensures at least 1 item per order
FROM generate_series(1, 20);
select * from orders_order


-- none of the field in orders model contain "unique", hence i will never get conflict here onwards. 
-- conflicts = None. maybe randomness be affected
-- Insert random dispatches (ensuring no duplicate dispatch per order and within qty limits)
INSERT INTO orders_dispatch (order_id, dispatch_person, dispatch_date_time)
SELECT o.order_id,
    'Dispatcher ' || floor(random() * 10),
    o.order_date_time + (random() * interval '30 days')
FROM orders_order o
WHERE o.qty > COALESCE(
    (SELECT COUNT(*) FROM orders_dispatch WHERE orders_dispatch.order_id = o.order_id), 
    0
)  -- Ensures dispatches never exceed order quantity
AND NOT EXISTS (
    SELECT 1 FROM orders_dispatch d WHERE d.order_id = o.order_id
)  -- Ensures no duplicate dispatches
ORDER BY RANDOM()
LIMIT 15;
SELECT * FROM orders_dispatch;




-- Insert random received orders (ensuring no excess received than dispatches)
INSERT INTO orders_received (order_id, received_person, received_date_time)
SELECT d.order_id,
    'Receiver ' || floor(random() * 10),
    d.dispatch_date_time + (random() * interval '7 days')
FROM orders_dispatch d
WHERE (
    SELECT COUNT(*) FROM orders_received WHERE orders_received.order_id = d.order_id
) < (
    SELECT COUNT(*) FROM orders_dispatch WHERE orders_dispatch.order_id = d.order_id
) -- Ensures received orders never exceed dispatched orders
ORDER BY RANDOM()
LIMIT (SELECT COUNT(*) FROM orders_dispatch);

SELECT * FROM orders_received;








--14th feb 2025 query 
-- Insert random users-- randomness is acceptable, but dispatch/received exceeds orders
-- INSERT INTO users_user (username, email_address, phone_number, address)
-- SELECT 
--     'user' || floor(random() * 10000)::TEXT,  
--     'user' || floor(random() * 10000)::TEXT || '@example.com',
--     '9876543' || LPAD(floor(random() * 1000)::TEXT, 3, '0'),
--     'address ' || floor(random() * 10000)::TEXT
-- FROM generate_series(1, 10);
-- select * from users_user

-- -- Insert random orders
-- INSERT INTO orders_order (user_id, order_date_time, model_no, qty)
-- SELECT 
--     (SELECT id FROM users_user ORDER BY RANDOM() LIMIT 1),  
--     NOW() - (random() * interval '3 years'),
--     'Model-' || floor(random() * 100)::TEXT,
--     floor(random() * 10 + 1)  -- Ensures at least 1 item per order
-- FROM generate_series(1, 20);
-- select * from orders_order

-- -- Insert random dispatches (linked to existing orders)
-- INSERT INTO orders_dispatch (order_id, dispatch_person, dispatch_date_time)
-- SELECT 
--     o.order_id,
--     'Dispatcher ' || floor(random() * 10),
--     o.order_date_time + (random() * interval '30 days')
--     -- floor(random() * o.qty * 0.7) + 1  -- Ensures dispatch is <= order qty (up to 70%)
-- FROM orders_order o
-- LEFT JOIN orders_dispatch d ON o.order_id = d.order_id
-- WHERE d.order_id IS NULL  
-- ORDER BY RANDOM()
-- LIMIT 15;
-- select * from orders_dispatch

-- -- Insert random received orders (linked to existing dispatched orders)
-- INSERT INTO orders_received (order_id, received_person, received_date_time)
-- SELECT 
--     d.order_id,
--     'Receiver ' || floor(random() * 10),
--     d.dispatch_date_time + (random() * interval '7 days')
--     -- floor(random() * d.dispatch_qty * 0.8) + 1  -- Ensures received qty is <= dispatch qty (up to 80%)
-- FROM orders_dispatch d
-- LEFT JOIN orders_received r ON d.order_id = r.order_id
-- WHERE r.order_id IS NULL  
-- ORDER BY RANDOM()
-- LIMIT 10;
-- select * from orders_received
