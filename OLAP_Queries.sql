-- Самый прибыльный продукт

SELECT
    p.product_name,
    SUM(fo.product_price * fo.quantity) AS total_product_price
FROM dwh.FactOrders fo
JOIN dwh.DimProduct p ON fo.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_product_price DESC
LIMIT 1;

-- Самый прибыльный штат

SELECT 
    c.subregion,
    SUM(DISTINCT fo.total_price) AS total_revenue
FROM dwh.FactOrders fo
JOIN dwh.DimCustomer cust ON fo.customer_id = cust.customer_id
JOIN dwh.DimAddress addr ON cust.address_id = addr.address_id
JOIN dwh.DimCity c ON addr.city_id = c.city_id
GROUP BY c.subregion
ORDER BY total_revenue DESC
LIMIT 1;

--Доход с каждого продукта

SELECT 
    p.product_name,
    SUM(fo.product_price * fo.quantity) AS total_revenue
FROM dwh.FactOrders fo
JOIN dwh.DimProduct p ON fo.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;