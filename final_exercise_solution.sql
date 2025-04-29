Use glovo_data;
CREATE TABLE user_orders AS
SELECT
      u.id AS user_id,
      datediff(CURDATE(),u.signed_up_time) AS days_since_signup,
      COUNT(o.id) AS total_orders,
      AVG(o.total_price) AS average_order_value,
      (
        SELECT s.name
        FROM orders AS inner_o
        LEFT JOIN stores AS s ON inner_o.store_id=s.id
        WHERE inner_o.user_id=u.id
        GROUP BY inner_o.store_id
        ORDER BY COUNT(*) DESC, MAX(inner_o.creation_time) DESC
        LIMIT 1
	  ) AS favorite_store,
      (
        SUM(CASE WHEN o.final_status='DeliveredStatus' THEN 1 ELSE 0 END) / COUNT(o.id)*100
	  ) AS delivered_orders_percentage,
      MAX(o.creation_time) AS last_order_time,
      (
        SELECT datediff(MAX(inner_o.creation_time), MAX(second_inner_o.creation_time))
        FROM orders AS inner_o
        JOIN orders AS second_inner_o ON inner_o.user_id=second_inner_o.user_id AND inner_o.creation_time>second_inner_o.creation_time
        WHERE inner_o.user_id=u.id
	  ) AS days_since_last_second_order
FROM 
      users AS u
JOIN
      orders AS o ON u.id=o.user_id
GROUP BY
      u.id
HAVING
      COUNT(o.id)>=5;









