-- Run after scripts 02-05 and queries.sql, connected to retail_analytics.
-- Assertions raise an error and stop execution when an expected invariant fails.
DO $$
DECLARE
    v_customers BIGINT;
    v_orders BIGINT;
    v_orphans BIGINT;
    v_preregistration BIGINT;
    v_view_orders BIGINT;
    v_view_revenue NUMERIC;
    v_view_cost NUMERIC;
    v_view_profit NUMERIC;
    v_direct_revenue NUMERIC;
    v_direct_cost NUMERIC;
    v_direct_profit NUMERIC;
    v_real_customer INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_customers FROM customers;
    SELECT COUNT(*) INTO v_orders FROM orders;
    IF v_customers <> 150 THEN RAISE EXCEPTION 'Expected 150 customers, found %', v_customers; END IF;
    IF v_orders <> 800 THEN RAISE EXCEPTION 'Expected 800 orders, found %', v_orders; END IF;

    SELECT COUNT(*) INTO v_orphans
    FROM orders AS o LEFT JOIN customers AS c USING (customer_id)
    WHERE c.customer_id IS NULL;
    IF v_orphans <> 0 THEN RAISE EXCEPTION 'Expected zero orphan orders, found %', v_orphans; END IF;

    SELECT COUNT(*) INTO v_preregistration
    FROM orders AS o JOIN customers AS c USING (customer_id)
    WHERE o.order_date < c.registration_date;
    IF v_preregistration <> 0 THEN RAISE EXCEPTION 'Expected zero pre-registration orders, found %', v_preregistration; END IF;

    SELECT COALESCE(SUM(orders), 0),
           COALESCE(SUM(revenue), 0),
           COALESCE(SUM(cost), 0),
           COALESCE(SUM(profit), 0)
    INTO v_view_orders, v_view_revenue, v_view_cost, v_view_profit
    FROM monthly_sales_summary;
    IF v_view_orders <> 800 THEN RAISE EXCEPTION 'Monthly view should count 800 all-status orders, found %', v_view_orders; END IF;

    SELECT COALESCE(SUM(quantity * unit_price * (1 - discount / 100)), 0),
           COALESCE(SUM(quantity * cost_price), 0),
           COALESCE(SUM(quantity * (unit_price * (1 - discount / 100) - cost_price)), 0)
    INTO v_direct_revenue, v_direct_cost, v_direct_profit
    FROM orders
    WHERE order_status = 'Completed';
    IF v_view_revenue <> v_direct_revenue THEN RAISE EXCEPTION 'View revenue does not reconcile'; END IF;
    IF v_view_cost <> v_direct_cost THEN RAISE EXCEPTION 'View cost does not reconcile'; END IF;
    IF v_view_profit <> v_direct_profit THEN RAISE EXCEPTION 'View gross profit does not reconcile'; END IF;

    SELECT customer_id INTO v_real_customer FROM customers ORDER BY customer_id LIMIT 1;
    IF v_real_customer IS NULL THEN RAISE EXCEPTION 'Expected a registered customer for function demo'; END IF;
    IF customer_revenue(-1) IS DISTINCT FROM 0::numeric THEN
        RAISE EXCEPTION 'Missing customer function result should be zero';
    END IF;
    IF customer_revenue(v_real_customer) IS DISTINCT FROM
       COALESCE((SELECT SUM(quantity * unit_price * (1 - discount / 100))
                 FROM orders WHERE customer_id = v_real_customer AND order_status = 'Completed'), 0) THEN
        RAISE EXCEPTION 'Customer revenue function does not match direct completed revenue';
    END IF;
END;
$$;

-- Check that representative CHECK constraints reject invalid values. Each
-- exception block is a subtransaction, so a rejected row leaves no data behind.
DO $$
DECLARE
    v_customer_id INTEGER;
BEGIN
    SELECT customer_id INTO v_customer_id FROM customers ORDER BY customer_id LIMIT 1;
    IF v_customer_id IS NULL THEN RAISE EXCEPTION 'Need a customer for constraint checks'; END IF;

    BEGIN
        INSERT INTO orders (order_id, customer_id, order_date, quantity, unit_price, cost_price,
                            discount, payment_method, order_status)
        VALUES (-990001, v_customer_id, CURRENT_DATE, 0, 1, 1, 0, 'Cash', 'Completed');
        RAISE EXCEPTION 'quantity CHECK allowed zero';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO orders (order_id, customer_id, order_date, quantity, unit_price, cost_price,
                            discount, payment_method, order_status)
        VALUES (-990002, v_customer_id, CURRENT_DATE, 1, 1, 1, 101, 'Cash', 'Completed');
        RAISE EXCEPTION 'discount CHECK allowed 101';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO orders (order_id, customer_id, order_date, quantity, unit_price, cost_price,
                            discount, payment_method, order_status)
        VALUES (-990003, v_customer_id, CURRENT_DATE, 1, 1, 1, 0, 'Cheque', 'Completed');
        RAISE EXCEPTION 'payment_method CHECK allowed an unsupported method';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
END;
$$;

SELECT 'All validation assertions passed' AS validation_result;
