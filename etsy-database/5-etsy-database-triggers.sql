-- TRIGGERS:
-- 1. Trigger to prevent negative prices when inserting or updating products:
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


-- 2. Trigger to prevent duplicate category names when inserting or updating categories:
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