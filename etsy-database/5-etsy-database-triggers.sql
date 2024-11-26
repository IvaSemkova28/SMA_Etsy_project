-- TRIGGERS:
-- 1. Тригер за предотвратяване на отрицателни цени при вмъкване или актуализиране на продукти:
CREATE TRIGGER TRG_PREVENT_NEGATIVE_PRICE
ON PRODUCTS
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT * FROM inserted WHERE PRICE < 0)
	BEGIN
		ROLLBACK TRANSACTION
		PRINT 'Erorr: Product price cannot be negative!'
	END
END;

--test:
INSERT INTO PRODUCTS (PRODUCT_ID, PRODUCT_NAME, DESCRIPTION, PRICE, CATEGORY_ID, SELLER_ID) VALUES
(100, 'Bag', 'Leather bag.', -10.00, 2, 2);


-- 2. Тригер за предотвратяване на дублирани имена на категории при вмъкване или актуализиране:
CREATE TRIGGER TRG_PREVENT_DUPLICATE_CATEGORIES
ON CATEGORIES
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT CATEGORY_NAME
		FROM CATEGORIES
		GROUP BY CATEGORY_NAME
		HAVING COUNT(CATEGORY_NAME) > 1
	)
	BEGIN
		ROLLBACK TRANSACTION
		PRINT 'Error: Duplicate category names are not allowed.'
	END
END;

--test
INSERT INTO CATEGORIES (CATEGORY_ID, CATEGORY_NAME, DESCRIPTION) VALUES
(100, 'Electronics', 'Devices.');



-- 3. Тригер за предотвратяване на изтриване на поръчки със статус 'shipped' или 'delivered':
CREATE TRIGGER TRG_PREVENT_ORDER_DELETION
ON ORDERS
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT ORDER_ID
        FROM DELETED
        WHERE STATUS IN ('shipped', 'delivered')
    )
    BEGIN
        PRINT 'Error: Cannot delete shipped or delivered orders.'
    END
    ELSE
    BEGIN
        DELETE FROM ORDERS
        WHERE ORDER_ID IN (SELECT ORDER_ID FROM DELETED);
    END
END;

--test:
DELETE FROM ORDERS WHERE ORDER_ID = 9;