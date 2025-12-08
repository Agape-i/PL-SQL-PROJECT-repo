
-- Phase V - Business Logic Implementation


CREATE OR REPLACE TRIGGER trg_calculate_payment
BEFORE INSERT ON payments
FOR EACH ROW
DECLARE
    v_weight  NUMBER;
    v_price   NUMBER;
BEGIN
    -- Get delivery weight and quality price
    SELECT d.weight_kg, cq.price_per_kg
    INTO v_weight, v_price
    FROM deliveries d
    JOIN coffee_quality cq ON d.quality_id = cq.quality_id
    WHERE d.delivery_id = :NEW.delivery_id;

    -- Auto-calculate payment amount
    :NEW.amount_paid := v_weight * v_price;
    
    -- Debug output (optional)
    DBMS_OUTPUT.PUT_LINE('Payment calculated: ' || v_weight || 'kg * ' || v_price || ' = ' || (v_weight * v_price));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Delivery not found or missing quality data.');
END;
/
