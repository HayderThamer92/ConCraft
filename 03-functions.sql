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
-- #region [trigger_handler_partner_capital_transactions_full]
CREATE OR REPLACE FUNCTION trigger_handler_partner_capital_transactions_full()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    amount_diff NUMERIC;
    current_partner_capital NUMERIC;
BEGIN
    -- Get current capital of the partner
    SELECT capital INTO current_partner_capital FROM partners WHERE id = COALESCE(NEW.partner_id, OLD.partner_id);

    -- Prevent withdraw exceeding partner's capital
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        IF (NEW.transaction_type = 'withdraw' AND NEW.amount > current_partner_capital) THEN
            RAISE EXCEPTION 'withdraw amount exceeds partner''s available capital';
        END IF;
    END IF;

    -- Handle INSERT
    IF TG_OP = 'INSERT' THEN
        -- Update partner capital
        IF NEW.transaction_type = 'deposit' THEN
            UPDATE partners SET capital = capital + NEW.amount WHERE id = NEW.partner_id;
            UPDATE capital SET amount = amount + NEW.amount;
            UPDATE cash SET amount = amount + NEW.amount;
        ELSE
            -- withdraw (checked above)
            UPDATE partners SET capital = capital - NEW.amount WHERE id = NEW.partner_id;
            UPDATE capital SET amount = amount - NEW.amount;
            UPDATE cash SET amount = amount - NEW.amount;
        END IF;

    -- Handle DELETE
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.transaction_type = 'deposit' THEN
            UPDATE partners SET capital = capital - OLD.amount WHERE id = OLD.partner_id;
            UPDATE capital SET amount = amount - OLD.amount;
            UPDATE cash SET amount = amount - OLD.amount;
        ELSE
            UPDATE partners SET capital = capital + OLD.amount WHERE id = OLD.partner_id;
            UPDATE capital SET amount = amount + OLD.amount;
            UPDATE cash SET amount = amount + OLD.amount;
        END IF;

    -- Handle UPDATE
    ELSIF TG_OP = 'UPDATE' THEN
        amount_diff := NEW.amount - OLD.amount;

        -- If transaction type didn't change
        IF NEW.transaction_type = OLD.transaction_type THEN
            IF NEW.transaction_type = 'deposit' THEN
                UPDATE partners SET capital = capital + amount_diff WHERE id = NEW.partner_id;
                UPDATE capital SET amount = amount + amount_diff;
                UPDATE cash SET amount = amount + amount_diff;
            ELSE
                -- withdraw
                UPDATE partners SET capital = capital - amount_diff WHERE id = NEW.partner_id;
                UPDATE capital SET amount = amount - amount_diff;
                UPDATE cash SET amount = amount - amount_diff;
            END IF;
        ELSE
            -- transaction type changed
            -- revert old
            IF OLD.transaction_type = 'deposit' THEN
                UPDATE partners SET capital = capital - OLD.amount WHERE id = OLD.partner_id;
                UPDATE capital SET amount = amount - OLD.amount;
                UPDATE cash SET amount = amount - OLD.amount;
            ELSE
                UPDATE partners SET capital = capital + OLD.amount WHERE id = OLD.partner_id;
                UPDATE capital SET amount = amount + OLD.amount;
                UPDATE cash SET amount = amount + OLD.amount;
            END IF;

            -- apply new
            IF NEW.transaction_type = 'deposit' THEN
                UPDATE partners SET capital = capital + NEW.amount WHERE id = NEW.partner_id;
                UPDATE capital SET amount = amount + NEW.amount;
                UPDATE cash SET amount = amount + NEW.amount;
            ELSE
                -- withdraw
                UPDATE partners SET capital = capital - NEW.amount WHERE id = NEW.partner_id;
                UPDATE capital SET amount = amount - NEW.amount;
                UPDATE cash SET amount = amount - NEW.amount;
            END IF;
        END IF;
    END IF;

    RETURN NULL;
END;
$$;
-- #endregion [trigger_handler_partner_capital_transactions_full]
-- ============================================================
-- ============================================================
-- #region [placeholder]
-- #endregion [placeholder]
-- ============================================================