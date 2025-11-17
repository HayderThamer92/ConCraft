-- ============================================================
-- #region [get_current_user_role]
CREATE OR REPLACE FUNCTION get_current_user_role()
RETURNS TEXT
SECURITY DEFINER
SET
    search_path = PUBLIC,
    pg_catalog,
    pg_temp
AS $$
DECLARE
    current_uid UUID := auth.uid();  -- store auth.uid() once
    r TEXT;
BEGIN
    SELECT role
    INTO r
    FROM PUBLIC.partners
    WHERE id = current_uid
    LIMIT 1;

    RETURN r;
END;
$$ LANGUAGE plpgsql STABLE;
-- #endregion [get_current_user_role]
-- ============================================================
-- ============================================================
-- #region [trigger_handler_cash_partner_capital_transactions]
CREATE OR REPLACE FUNCTION trigger_handler_cash_partner_capital_transactions(p_amount NUMERIC, p_type TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_type = 'deposit' THEN
        UPDATE cash SET amount = amount + p_amount;
    ELSIF p_type = 'withdrawal' THEN
        UPDATE cash SET amount = amount - p_amount;
    END IF;
END;
$$;
-- #endregion [trigger_handler_cash_partner_capital_transactions]
-- ============================================================
-- ============================================================
-- #region [trigger_handler_capital_partner_capital_transactions]
CREATE OR REPLACE FUNCTION trigger_handler_capital_partner_capital_transactions(p_amount NUMERIC, p_type TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_type = 'deposit' THEN
        UPDATE capital SET amount = amount + p_amount;
    ELSIF p_type = 'withdrawal' THEN
        UPDATE capital SET amount = amount - p_amount;
    END IF;
END;
$$;
-- #endregion [trigger_handler_capital_partner_capital_transactions]
-- ============================================================
-- ============================================================
-- #region [trigger_handler_partner_capital_transactions]
CREATE OR REPLACE FUNCTION trigger_handler_partner_capital_transactions()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    amount_diff NUMERIC;
BEGIN
    -- Handle INSERT operation
    IF TG_OP = 'INSERT' THEN
        PERFORM trigger_handler_cash_partner_capital_transactions(NEW.amount, NEW.transaction_type);
        PERFORM trigger_handler_capital_partner_capital_transactions(NEW.amount, NEW.transaction_type);

    -- Handle DELETE operation
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM trigger_handler_cash_partner_capital_transactions(OLD.amount, CASE WHEN OLD.transaction_type='deposit' THEN 'withdrawal' ELSE 'deposit' END);
        PERFORM trigger_handler_capital_partner_capital_transactions(OLD.amount, CASE WHEN OLD.transaction_type='deposit' THEN 'withdrawal' ELSE 'deposit' END);

    -- Handle UPDATE operation
    ELSIF TG_OP = 'UPDATE' THEN
        amount_diff := NEW.amount - OLD.amount;

        IF NEW.transaction_type = OLD.transaction_type THEN
            PERFORM trigger_handler_cash_partner_capital_transactions(amount_diff, NEW.transaction_type);
            PERFORM trigger_handler_capital_partner_capital_transactions(amount_diff, NEW.transaction_type);
        ELSE
            -- revert old transaction
            PERFORM trigger_handler_cash_partner_capital_transactions(OLD.amount, CASE WHEN OLD.transaction_type='deposit' THEN 'withdrawal' ELSE 'deposit' END);
            PERFORM trigger_handler_capital_partner_capital_transactions(OLD.amount, CASE WHEN OLD.transaction_type='deposit' THEN 'withdrawal' ELSE 'deposit' END);

            -- apply new transaction
            PERFORM trigger_handler_cash_partner_capital_transactions(NEW.amount, NEW.transaction_type);
            PERFORM trigger_handler_capital_partner_capital_transactions(NEW.amount, NEW.transaction_type);
        END IF;
    END IF;

    RETURN NULL;
END;
$$;

-- #endregion [trigger_handler_partner_capital_transactions]
-- ============================================================
-- ============================================================
-- #region [trigger_handler_partner_capital_transactions]
CREATE OR REPLACE FUNCTION trigger_handler_partner_capital_transactions()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    amount_diff NUMERIC;
BEGIN
    -- Handle INSERT operation
    IF TG_OP = 'INSERT' THEN
        PERFORM trigger_handler_cash_partner_capital_transactions(NEW.amount, NEW.transaction_type);
        PERFORM trigger_handler_capital_partner_capital_transactions(NEW.amount, NEW.transaction_type);

    -- Handle DELETE operation
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM trigger_handler_cash_partner_capital_transactions(OLD.amount, CASE WHEN OLD.transaction_type='deposit' THEN 'withdrawal' ELSE 'deposit' END);
        PERFORM trigger_handler_capital_partner_capital_transactions(OLD.amount, CASE WHEN OLD.transaction_type='deposit' THEN 'withdrawal' ELSE 'deposit' END);

    -- Handle UPDATE operation
    ELSIF TG_OP = 'UPDATE' THEN
        amount_diff := NEW.amount - OLD.amount;

        IF NEW.transaction_type = OLD.transaction_type THEN
            PERFORM trigger_handler_cash_partner_capital_transactions(amount_diff, NEW.transaction_type);
            PERFORM trigger_handler_capital_partner_capital_transactions(amount_diff, NEW.transaction_type);
        ELSE
            -- revert old transaction
            PERFORM trigger_handler_cash_partner_capital_transactions(OLD.amount, CASE WHEN OLD.transaction_type='deposit' THEN 'withdrawal' ELSE 'deposit' END);
            PERFORM trigger_handler_capital_partner_capital_transactions(OLD.amount, CASE WHEN OLD.transaction_type='deposit' THEN 'withdrawal' ELSE 'deposit' END);

            -- apply new transaction
            PERFORM trigger_handler_cash_partner_capital_transactions(NEW.amount, NEW.transaction_type);
            PERFORM trigger_handler_capital_partner_capital_transactions(NEW.amount, NEW.transaction_type);
        END IF;
    END IF;

    RETURN NULL;
END;
$$;

-- #endregion [trigger_handler_partner_capital_transactions]
-- ============================================================
-- ============================================================
-- #region [placeholder]
-- #endregion [placeholder]
-- ============================================================