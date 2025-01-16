-- Самый прибыльный продукт

SELECT 
	p.product_name,
    SUM(od.product_price * od.quantity) AS total_product_price
FROM shop_oltp.Order_Details od
JOIN shop_oltp.Products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_product_price DESC
LIMIT 1;

-- Самый прибыльный штат

SELECT 
    c.subregion,
    SUM(o.total_price) AS total_revenue
FROM shop_oltp.Orders o
JOIN shop_oltp.Customers cust ON o.customer_id = cust.customer_id
JOIN shop_oltp.Address addr ON cust.address_id = addr.address_id
JOIN shop_oltp.City c ON addr.city_id = c.city_id
GROUP BY c.subregion
ORDER BY total_revenue DESC
LIMIT 1;

--Доход с каждого продукта

SELECT 
    p.product_name,
    SUM(od.product_price * od.quantity) AS total_revenue
FROM shop_oltp.Order_Details od
JOIN shop_oltp.Products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;