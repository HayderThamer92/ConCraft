-- ############################################################
-- #region [Enums]
-- #region [role_enum]
DROP TYPE IF EXISTS public.role_enum CASCADE;
CREATE TYPE public.role_enum AS ENUM ('admin', 'user');
-- #endregion [role_enum]
-- #region [transaction_type_enum]
DROP TYPE IF EXISTS public.transaction_type_enum CASCADE;
CREATE TYPE public.transaction_type_enum AS ENUM ('deposit', 'withdraw');
-- #endregion [transaction_type_enum]
-- #endregion [Enums]
-- ############################################################

-- ############################################################
-- #region [Tables]
-- #region [cash]
DROP TABLE IF EXISTS public.cash CASCADE;
CREATE TABLE
    public.cash (
        id INT PRIMARY KEY DEFAULT 1,
        amount BIGINT NOT NULL DEFAULT 0,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT (now () AT TIME ZONE 'Asia/Baghdad'),
        CONSTRAINT cash_id_check CHECK (id = 1)
    );
ALTER TABLE public.cash ENABLE ROW LEVEL SECURITY;
INSERT INTO
    public.cash (id, amount)
VALUES
    (1, 0);
-- #endregion [cash]
-- #region [capital]
DROP TABLE IF EXISTS public.capital CASCADE;
CREATE TABLE
    public.capital (
        id INT PRIMARY KEY DEFAULT 1,
        amount BIGINT NOT NULL DEFAULT 0,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT (now () AT TIME ZONE 'Asia/Baghdad'),
        CONSTRAINT capital_id_check CHECK (id = 1)
    );
ALTER TABLE public.capital ENABLE ROW LEVEL SECURITY;
INSERT INTO
    public.capital (id, amount)
VALUES
    (1, 0);
-- #endregion [capital]
-- #region [partners]
DROP TABLE IF EXISTS public.partners CASCADE;
CREATE TABLE
    public.partners (
        id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE ON UPDATE CASCADE,
        name TEXT NOT NULL,
        role role_enum NOT NULL DEFAULT 'user',
        capital BIGINT NOT NULL DEFAULT 0,
        CONSTRAINT partners_name_key UNIQUE (name)
    );
ALTER TABLE public.partners ENABLE ROW LEVEL SECURITY;
-- #endregion [partners]
-- #region [partner_capital_transactions]
DROP TABLE IF EXISTS public.partner_capital_transactions CASCADE;
CREATE TABLE
    public.partner_capital_transactions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        partner_id UUID NOT NULL REFERENCES public.partners (id) ON DELETE CASCADE ON UPDATE CASCADE,
        transaction_type transaction_type_enum NOT NULL,
        amount BIGINT NOT NULL,
        transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
        notes TEXT,
        CONSTRAINT cash_amount_check CHECK (amount > 0)
    );
ALTER TABLE public.partner_capital_transactions ENABLE ROW LEVEL SECURITY;
CREATE INDEX partner_capital_transactions_partner_id_idx ON public.partner_capital_transactions (partner_id);
-- #endregion [partner_capital_transactions]
-- #endregion [Tables]
-- ############################################################

-- ############################################################
-- #region [Functions]
-- #region [get_current_user_role]
CREATE OR REPLACE FUNCTION get_current_user_role()
RETURNS TEXT
SECURITY DEFINER
SET search_path = public, pg_catalog, pg_temp
AS $$
DECLARE
    current_uid UUID := auth.uid();  -- store auth.uid() once
    r TEXT;
BEGIN
    SELECT role
    INTO r
    FROM public.partners
    WHERE id = current_uid
    LIMIT 1;

    RETURN r;
END;
$$ LANGUAGE plpgsql STABLE;
-- #endregion [get_current_user_role]
-- #region [trigger_handler_partner_capital_transactions_full]
CREATE OR REPLACE FUNCTION trigger_handler_partner_capital_transactions_full()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public, pg_catalog, pg_temp
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
-- #endregion [Functions]
-- ############################################################

-- ############################################################
-- #region [Policies]
-- #region [cash]
DROP POLICY IF EXISTS "cash_policy_select" ON cash;
-- SELECT Policy [admin,user]
CREATE POLICY "cash_policy_select" ON cash FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- #endregion [cash]
-- #region [capital]
DROP POLICY IF EXISTS "capital_policy_select" ON capital;
-- SELECT Policy [admin,user]
CREATE POLICY "capital_policy_select" ON capital FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- #endregion [capital]
-- #region [partners]
DROP POLICY IF EXISTS "partners_policy_select" ON partners;
DROP POLICY IF EXISTS "partners_policy_update" ON partners;
DROP POLICY IF EXISTS "partners_policy_insert" ON partners;
DROP POLICY IF EXISTS "partners_policy_delete" ON partners;
-- SELECT Policy [admin,user]
CREATE POLICY "partners_policy_select" ON partners FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "partners_policy_update" ON partners FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "partners_policy_insert" ON partners FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "partners_policy_delete" ON partners FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [partners]
-- #region [partner_capital_transactions]
DROP POLICY IF EXISTS "partner_capital_transactions_policy_select" ON partner_capital_transactions;
DROP POLICY IF EXISTS "partner_capital_transactions_policy_update" ON partner_capital_transactions;
DROP POLICY IF EXISTS "partner_capital_transactions_policy_insert" ON partner_capital_transactions;
DROP POLICY IF EXISTS "partner_capital_transactions_policy_delete" ON partner_capital_transactions;
-- SELECT Policy [admin,user]
CREATE POLICY "partner_capital_transactions_policy_select" ON partner_capital_transactions FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "partner_capital_transactions_policy_update" ON partner_capital_transactions FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "partner_capital_transactions_policy_insert" ON partner_capital_transactions FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "partner_capital_transactions_policy_delete" ON partner_capital_transactions FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [partner_capital_transactions]
-- #endregion [Policies]
-- ############################################################

-- ############################################################
-- #region [Triggers]
-- #region [trigger_partner_capital_transactions_full]
CREATE TRIGGER trigger_partner_capital_transactions_full
AFTER INSERT OR UPDATE OR DELETE ON partner_capital_transactions
FOR EACH ROW
EXECUTE FUNCTION trigger_handler_partner_capital_transactions_full();
-- #endregion [trigger_partner_capital_transactions_full]
-- #endregion [Triggers]
-- ############################################################

-- ############################################################
-- #region [Data]
-- #region [partners]
TRUNCATE TABLE public.partners RESTART IDENTITY CASCADE;
INSERT INTO public.partners (id, name, role)
SELECT id,
    CASE
        email
        WHEN 'hayder.thamer@concraft.com' THEN 'حيدر ثامر'
        WHEN 'ahmed.thamer@concraft.com' THEN 'احمد ثامر'
        WHEN 'ahmed.ismail@concraft.com' THEN 'احمد اسماعيل'
    END AS name,
    (
        CASE
            email
            WHEN 'hayder.thamer@concraft.com' THEN 'admin'
            ELSE 'user'
        END
    )::role_enum AS role
FROM auth.users
WHERE email IN (
        'hayder.thamer@concraft.com',
        'ahmed.thamer@concraft.com',
        'ahmed.ismail@concraft.com'
    );
-- #endregion [partners]
-- #endregion [Data]
-- ############################################################