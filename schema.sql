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
-- #region [clients]
DROP TABLE IF EXISTS public.clients CASCADE;
CREATE TABLE public.clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  name TEXT NOT NULL,
  CONSTRAINT clients_name_key UNIQUE (name)
);
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
-- #endregion [clients]
-- #region [projects]
DROP TABLE IF EXISTS public.projects CASCADE;
CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  client_id UUID REFERENCES public.clients (id) ON DELETE CASCADE ON UPDATE CASCADE,
  title TEXT NOT NULL,
  CONSTRAINT projects_client_id_title_key UNIQUE (client_id, title)
);
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
CREATE INDEX projects_client_id_idx ON public.projects (client_id);
-- #endregion [projects]
-- #region [staff]
DROP TABLE IF EXISTS public.staff CASCADE;
CREATE TABLE public.staff (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  name TEXT NOT NULL,
  CONSTRAINT staff_name_key UNIQUE (name)
);
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
-- #endregion [staff]
-- #region [project_staff_financial_fees]
DROP TABLE IF EXISTS public.project_staff_financial_fees CASCADE;
CREATE TABLE public.project_staff_financial_fees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  project_id UUID NOT NULL REFERENCES public.projects (id) ON DELETE CASCADE ON UPDATE CASCADE,
  staff_id UUID NOT NULL REFERENCES public.staff (id) ON DELETE CASCADE ON UPDATE CASCADE,
  amount BIGINT NOT NULL DEFAULT 0,
  CONSTRAINT project_staff_financial_fees_project_id_staff_id_key UNIQUE (project_id, staff_id)
);
ALTER TABLE public.project_staff_financial_fees ENABLE ROW LEVEL SECURITY;
-- #endregion [project_staff_financial_fees]
-- #region [project_staff_financial_fees_fixed]
DROP TABLE IF EXISTS public.project_staff_financial_fees_fixed CASCADE;
CREATE TABLE public.project_staff_financial_fees_fixed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  project_staff_financial_fees_id UUID NOT NULL REFERENCES public.project_staff_financial_fees (id) ON DELETE CASCADE ON UPDATE CASCADE,
  title TEXT NOT NULL,
  amount BIGINT NOT NULL,
  notes TEXT,
  CONSTRAINT psfff_amount_check CHECK (amount > 0),
  CONSTRAINT psfff_project_staff_financial_fees_id_title_key UNIQUE (project_staff_financial_fees_id, title)
);
ALTER TABLE public.project_staff_financial_fees_fixed ENABLE ROW LEVEL SECURITY;
CREATE INDEX psfff_project_staff_financial_fees_id_idx ON public.project_staff_financial_fees_fixed (project_staff_financial_fees_id);
-- #endregion [project_staff_financial_fees_fixed]
-- #region [project_staff_financial_fees_items]
DROP TABLE IF EXISTS public.project_staff_financial_fees_items CASCADE;
CREATE TABLE public.project_staff_financial_fees_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  project_staff_financial_fees_id UUID NOT NULL REFERENCES public.project_staff_financial_fees (id) ON DELETE CASCADE ON UPDATE CASCADE,
  title TEXT NOT NULL,
  quantity NUMERIC NOT NULL,
  unit_price BIGINT NOT NULL,
  notes TEXT,
  CONSTRAINT psffi_project_staff_financial_fees_id_title_key UNIQUE (project_staff_financial_fees_id, title),
  CONSTRAINT psffi_quantity_check CHECK (quantity > 0),
  CONSTRAINT psffi_unit_price_check CHECK (unit_price > 0)
);
ALTER TABLE public.project_staff_financial_fees_items ENABLE ROW LEVEL SECURITY;
CREATE INDEX psffi_project_staff_financial_fees_id_idx ON public.project_staff_financial_fees_items (project_staff_financial_fees_id);
-- #endregion [project_staff_financial_fees_items]
-- #region [project_client_financial_fees]
DROP TABLE IF EXISTS public.project_client_financial_fees CASCADE;
CREATE TABLE public.project_client_financial_fees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  project_id UUID NOT NULL REFERENCES public.projects (id) ON DELETE CASCADE ON UPDATE CASCADE,
  amount BIGINT NOT NULL DEFAULT 0,
  CONSTRAINT project_client_financial_fees_project_id_key UNIQUE (project_id)
);
ALTER TABLE public.project_client_financial_fees ENABLE ROW LEVEL SECURITY;
-- #endregion [project_client_financial_fees]
-- #region [project_client_financial_fees_fixed]
DROP TABLE IF EXISTS public.project_client_financial_fees_fixed CASCADE;
CREATE TABLE public.project_client_financial_fees_fixed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  project_client_financial_fees_id UUID NOT NULL REFERENCES public.project_client_financial_fees (id) ON DELETE CASCADE ON UPDATE CASCADE,
  title TEXT NOT NULL,
  amount BIGINT NOT NULL,
  notes TEXT,
  CONSTRAINT pcfff_amount_check CHECK (amount > 0),
  CONSTRAINT pcfff_project_client_financial_fees_id_title_key UNIQUE (project_client_financial_fees_id, title)
);
ALTER TABLE public.project_client_financial_fees_fixed ENABLE ROW LEVEL SECURITY;
CREATE INDEX pcfff_project_client_financial_fees_id_idx ON public.project_client_financial_fees_fixed (project_client_financial_fees_id);
-- #endregion [project_client_financial_fees_fixed]
-- #region [project_client_financial_fees_items]
DROP TABLE IF EXISTS public.project_client_financial_fees_items CASCADE;
CREATE TABLE public.project_client_financial_fees_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  project_client_financial_fees_id UUID NOT NULL REFERENCES public.project_client_financial_fees (id) ON DELETE CASCADE ON UPDATE CASCADE,
  title TEXT NOT NULL,
  quantity NUMERIC NOT NULL,
  unit_price BIGINT NOT NULL,
  notes TEXT,
  CONSTRAINT pcffi_project_client_financial_fees_id_title_key UNIQUE (project_client_financial_fees_id, title),
  CONSTRAINT pcffi_quantity_check CHECK (quantity > 0),
  CONSTRAINT pcffi_unit_price_check CHECK (unit_price > 0)
);
ALTER TABLE public.project_client_financial_fees_items ENABLE ROW LEVEL SECURITY;
CREATE INDEX pcffi_project_client_financial_fees_id_idx ON public.project_client_financial_fees_items (project_client_financial_fees_id);
-- #endregion [project_client_financial_fees_items]
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
CREATE OR REPLACE FUNCTION public.trigger_handler_partner_capital_transactions_full()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    amount_diff BIGINT;
    current_partner_capital BIGINT;
BEGIN
    -- Get current capital of the partner
    SELECT capital::BIGINT INTO current_partner_capital
      FROM partners
      WHERE id = COALESCE(NEW.partner_id, OLD.partner_id);

    -- Prevent withdraw exceeding partner's capital BEFORE operation
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF NEW.transaction_type = 'withdraw' AND NEW.amount > current_partner_capital THEN
            RAISE EXCEPTION 'Withdraw amount exceeds partner''s available capital';
        END IF;
    END IF;

    -- Handle INSERT
    IF TG_OP = 'INSERT' THEN
        IF NEW.transaction_type = 'deposit' THEN
            UPDATE partners SET capital = capital + NEW.amount WHERE id = NEW.partner_id;
            UPDATE capital SET amount = amount + NEW.amount;
            UPDATE cash SET amount = amount + NEW.amount;
        ELSE
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

        IF NEW.transaction_type = OLD.transaction_type THEN
            -- Same type (deposit/deposit or withdraw/withdraw)
            IF NEW.transaction_type = 'deposit' THEN
                UPDATE partners SET capital = capital + amount_diff WHERE id = NEW.partner_id;
                UPDATE capital SET amount = amount + amount_diff;
                UPDATE cash SET amount = amount + amount_diff;
            ELSE
                UPDATE partners SET capital = capital - amount_diff WHERE id = NEW.partner_id;
                UPDATE capital SET amount = amount - amount_diff;
                UPDATE cash SET amount = amount - amount_diff;
            END IF;
        ELSE
            -- Type changed: revert old transaction, then apply new
            IF OLD.transaction_type = 'deposit' THEN
                UPDATE partners SET capital = capital - OLD.amount WHERE id = OLD.partner_id;
                UPDATE capital SET amount = amount - OLD.amount;
                UPDATE cash SET amount = amount - OLD.amount;
            ELSE
                UPDATE partners SET capital = capital + OLD.amount WHERE id = OLD.partner_id;
                UPDATE capital SET amount = amount + OLD.amount;
                UPDATE cash SET amount = amount + OLD.amount;
            END IF;

            -- Apply new transaction
            IF NEW.transaction_type = 'deposit' THEN
                UPDATE partners SET capital = capital + NEW.amount WHERE id = NEW.partner_id;
                UPDATE capital SET amount = amount + NEW.amount;
                UPDATE cash SET amount = amount + NEW.amount;
            ELSE
                UPDATE partners SET capital = capital - NEW.amount WHERE id = NEW.partner_id;
                UPDATE capital SET amount = amount - NEW.amount;
                UPDATE cash SET amount = amount - NEW.amount;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;
-- #endregion [trigger_handler_partner_capital_transactions_full]
-- #region [trigger_handler_project_staff_financial_fees_full]
CREATE OR REPLACE FUNCTION public.trigger_handler_project_staff_financial_fees_full()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    v_fees_id UUID := COALESCE(NEW.project_staff_financial_fees_id, OLD.project_staff_financial_fees_id);
    v_sum_fixed BIGINT;
    v_sum_items BIGINT;
BEGIN
    -- Sum from fixed fees
    SELECT COALESCE(SUM(amount),0)
    INTO v_sum_fixed
    FROM public.project_staff_financial_fees_fixed
    WHERE project_staff_financial_fees_id = v_fees_id;

    -- Sum from items
    SELECT COALESCE(SUM(quantity * unit_price),0)
    INTO v_sum_items
    FROM public.project_staff_financial_fees_items
    WHERE project_staff_financial_fees_id = v_fees_id;

    -- Update main table
    UPDATE public.project_staff_financial_fees
    SET amount = v_sum_fixed + v_sum_items
    WHERE id = v_fees_id;

    RETURN NULL;
END;
$$;
-- #endregion [trigger_handler_project_staff_financial_fees_full]
-- #region [trigger_handler_project_client_financial_fees_full]
CREATE OR REPLACE FUNCTION public.trigger_handler_project_client_financial_fees_full()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    v_fees_id UUID := COALESCE(NEW.project_client_financial_fees_id, OLD.project_client_financial_fees_id);
    v_sum_fixed BIGINT;
    v_sum_items BIGINT;
BEGIN
    -- Sum from fixed fees
    SELECT COALESCE(SUM(amount),0)
    INTO v_sum_fixed
    FROM public.project_client_financial_fees_fixed
    WHERE project_client_financial_fees_id = v_fees_id;

    -- Sum from items
    SELECT COALESCE(SUM(quantity * unit_price),0)
    INTO v_sum_items
    FROM public.project_client_financial_fees_items
    WHERE project_client_financial_fees_id = v_fees_id;

    -- Update main table
    UPDATE public.project_client_financial_fees
    SET amount = v_sum_fixed + v_sum_items
    WHERE id = v_fees_id;

    RETURN NULL;
END;
$$;
-- #endregion [trigger_handler_project_client_financial_fees_full]
-- #endregion [Functions]
-- ############################################################

-- ############################################################
-- #region [Policies]
-- #region [cash]
DROP POLICY IF EXISTS "cash_policy_select" ON public.cash;
-- SELECT Policy [admin,user]
CREATE POLICY "cash_policy_select" ON public.cash FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- #endregion [cash]
-- #region [capital]
DROP POLICY IF EXISTS "capital_policy_select" ON public.capital;
-- SELECT Policy [admin,user]
CREATE POLICY "capital_policy_select" ON public.capital FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- #endregion [capital]
-- #region [partners]
DROP POLICY IF EXISTS "partners_policy_select" ON public.partners;
DROP POLICY IF EXISTS "partners_policy_update" ON public.partners;
DROP POLICY IF EXISTS "partners_policy_insert" ON public.partners;
DROP POLICY IF EXISTS "partners_policy_delete" ON public.partners;
-- SELECT Policy [admin,user]
CREATE POLICY "partners_policy_select" ON public.partners FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "partners_policy_update" ON public.partners FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "partners_policy_insert" ON public.partners FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "partners_policy_delete" ON public.partners FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [partners]
-- #region [partner_capital_transactions]
DROP POLICY IF EXISTS "partner_capital_transactions_policy_select" ON public.partner_capital_transactions;
DROP POLICY IF EXISTS "partner_capital_transactions_policy_update" ON public.partner_capital_transactions;
DROP POLICY IF EXISTS "partner_capital_transactions_policy_insert" ON public.partner_capital_transactions;
DROP POLICY IF EXISTS "partner_capital_transactions_policy_delete" ON public.partner_capital_transactions;
-- SELECT Policy [admin,user]
CREATE POLICY "partner_capital_transactions_policy_select" ON public.partner_capital_transactions FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "partner_capital_transactions_policy_update" ON public.partner_capital_transactions FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "partner_capital_transactions_policy_insert" ON public.partner_capital_transactions FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "partner_capital_transactions_policy_delete" ON public.partner_capital_transactions FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [partner_capital_transactions]
-- #region [clients]
DROP POLICY IF EXISTS "clients_policy_select" ON public.clients;
DROP POLICY IF EXISTS "clients_policy_update" ON public.clients;
DROP POLICY IF EXISTS "clients_policy_insert" ON public.clients;
DROP POLICY IF EXISTS "clients_policy_delete" ON public.clients;
-- SELECT Policy [admin,user]
CREATE POLICY "clients_policy_select" ON public.clients FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "clients_policy_update" ON public.clients FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "clients_policy_insert" ON public.clients FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "clients_policy_delete" ON public.clients FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [clients]
-- #region [projects]
DROP POLICY IF EXISTS "projects_policy_select" ON public.projects;
DROP POLICY IF EXISTS "projects_policy_update" ON public.projects;
DROP POLICY IF EXISTS "projects_policy_insert" ON public.projects;
DROP POLICY IF EXISTS "projects_policy_delete" ON public.projects;
-- SELECT Policy [admin,user]
CREATE POLICY "projects_policy_select" ON public.projects FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "projects_policy_update" ON public.projects FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "projects_policy_insert" ON public.projects FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "projects_policy_delete" ON public.projects FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [projects]
-- #region [staff]
DROP POLICY IF EXISTS "staff_policy_select" ON public.staff;
DROP POLICY IF EXISTS "staff_policy_update" ON public.staff;
DROP POLICY IF EXISTS "staff_policy_insert" ON public.staff;
DROP POLICY IF EXISTS "staff_policy_delete" ON public.staff;
-- SELECT Policy [admin,user]
CREATE POLICY "staff_policy_select" ON public.staff FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "staff_policy_update" ON public.staff FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "staff_policy_insert" ON public.staff FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "staff_policy_delete" ON public.staff FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [staff]
-- #region [project_staff_financial_fees]
DROP POLICY IF EXISTS "project_staff_financial_fees_policy_select" ON public.project_staff_financial_fees;
DROP POLICY IF EXISTS "project_staff_financial_fees_policy_update" ON public.project_staff_financial_fees;
DROP POLICY IF EXISTS "project_staff_financial_fees_policy_insert" ON public.project_staff_financial_fees;
DROP POLICY IF EXISTS "project_staff_financial_fees_policy_delete" ON public.project_staff_financial_fees;
-- SELECT Policy [admin,user]
CREATE POLICY "project_staff_financial_fees_policy_select" ON public.project_staff_financial_fees FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "project_staff_financial_fees_policy_update" ON public.project_staff_financial_fees FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "project_staff_financial_fees_policy_insert" ON public.project_staff_financial_fees FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "project_staff_financial_fees_policy_delete" ON public.project_staff_financial_fees FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [project_staff_financial_fees]
-- #region [project_staff_financial_fees_fixed]
DROP POLICY IF EXISTS "project_staff_financial_fees_fixed_policy_select" ON public.project_staff_financial_fees_fixed;
DROP POLICY IF EXISTS "project_staff_financial_fees_fixed_policy_update" ON public.project_staff_financial_fees_fixed;
DROP POLICY IF EXISTS "project_staff_financial_fees_fixed_policy_insert" ON public.project_staff_financial_fees_fixed;
DROP POLICY IF EXISTS "project_staff_financial_fees_fixed_policy_delete" ON public.project_staff_financial_fees_fixed;
-- SELECT Policy [admin,user]
CREATE POLICY "project_staff_financial_fees_fixed_policy_select" ON public.project_staff_financial_fees_fixed FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "project_staff_financial_fees_fixed_policy_update" ON public.project_staff_financial_fees_fixed FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "project_staff_financial_fees_fixed_policy_insert" ON public.project_staff_financial_fees_fixed FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "project_staff_financial_fees_fixed_policy_delete" ON public.project_staff_financial_fees_fixed FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [project_staff_financial_fees_fixed]
-- #region [project_staff_financial_fees_items]
DROP POLICY IF EXISTS "project_staff_financial_fees_items_policy_select" ON public.project_staff_financial_fees_items;
DROP POLICY IF EXISTS "project_staff_financial_fees_items_policy_update" ON public.project_staff_financial_fees_items;
DROP POLICY IF EXISTS "project_staff_financial_fees_items_policy_insert" ON public.project_staff_financial_fees_items;
DROP POLICY IF EXISTS "project_staff_financial_fees_items_policy_delete" ON public.project_staff_financial_fees_items;
-- SELECT Policy [admin,user]
CREATE POLICY "project_staff_financial_fees_items_policy_select" ON public.project_staff_financial_fees_items FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "project_staff_financial_fees_items_policy_update" ON public.project_staff_financial_fees_items FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "project_staff_financial_fees_items_policy_insert" ON public.project_staff_financial_fees_items FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "project_staff_financial_fees_items_policy_delete" ON public.project_staff_financial_fees_items FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [project_staff_financial_fees_items]
-- #region [project_client_financial_fees]
DROP POLICY IF EXISTS "project_client_financial_fees_policy_select" ON public.project_client_financial_fees;
DROP POLICY IF EXISTS "project_client_financial_fees_policy_update" ON public.project_client_financial_fees;
DROP POLICY IF EXISTS "project_client_financial_fees_policy_insert" ON public.project_client_financial_fees;
DROP POLICY IF EXISTS "project_client_financial_fees_policy_delete" ON public.project_client_financial_fees;
-- SELECT Policy [admin,user]
CREATE POLICY "project_client_financial_fees_policy_select" ON public.project_client_financial_fees FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "project_client_financial_fees_policy_update" ON public.project_client_financial_fees FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "project_client_financial_fees_policy_insert" ON public.project_client_financial_fees FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "project_client_financial_fees_policy_delete" ON public.project_client_financial_fees FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [project_client_financial_fees]
-- #region [project_client_financial_fees_fixed]
DROP POLICY IF EXISTS "project_client_financial_fees_fixed_policy_select" ON public.project_client_financial_fees_fixed;
DROP POLICY IF EXISTS "project_client_financial_fees_fixed_policy_update" ON public.project_client_financial_fees_fixed;
DROP POLICY IF EXISTS "project_client_financial_fees_fixed_policy_insert" ON public.project_client_financial_fees_fixed;
DROP POLICY IF EXISTS "project_client_financial_fees_fixed_policy_delete" ON public.project_client_financial_fees_fixed;
-- SELECT Policy [admin,user]
CREATE POLICY "project_client_financial_fees_fixed_policy_select" ON public.project_client_financial_fees_fixed FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "project_client_financial_fees_fixed_policy_update" ON public.project_client_financial_fees_fixed FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "project_client_financial_fees_fixed_policy_insert" ON public.project_client_financial_fees_fixed FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "project_client_financial_fees_fixed_policy_delete" ON public.project_client_financial_fees_fixed FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [project_client_financial_fees_fixed]
-- #region [project_client_financial_fees_items]
DROP POLICY IF EXISTS "project_client_financial_fees_items_policy_select" ON public.project_client_financial_fees_items;
DROP POLICY IF EXISTS "project_client_financial_fees_items_policy_update" ON public.project_client_financial_fees_items;
DROP POLICY IF EXISTS "project_client_financial_fees_items_policy_insert" ON public.project_client_financial_fees_items;
DROP POLICY IF EXISTS "project_client_financial_fees_items_policy_delete" ON public.project_client_financial_fees_items;
-- SELECT Policy [admin,user]
CREATE POLICY "project_client_financial_fees_items_policy_select" ON public.project_client_financial_fees_items FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- UPDATE Policy [admin]
CREATE POLICY "project_client_financial_fees_items_policy_update" ON public.project_client_financial_fees_items FOR
UPDATE USING (get_current_user_role () = 'admin')
WITH
    CHECK (get_current_user_role () = 'admin');
-- INSERT Policy [admin]
CREATE POLICY "project_client_financial_fees_items_policy_insert" ON public.project_client_financial_fees_items FOR INSERT
WITH
    CHECK (get_current_user_role () = 'admin');
-- DELETE Policy [admin]
CREATE POLICY "project_client_financial_fees_items_policy_delete" ON public.project_client_financial_fees_items FOR DELETE USING (get_current_user_role () = 'admin');
-- #endregion [project_client_financial_fees_items]
-- #endregion [Policies]
-- ############################################################

-- ############################################################
-- #region [Triggers]
-- #region [trigger_partner_capital_transactions_full]
DROP TRIGGER IF EXISTS trigger_partner_capital_transactions_full
ON partner_capital_transactions;

CREATE TRIGGER trigger_partner_capital_transactions_full
BEFORE INSERT OR UPDATE OR DELETE
ON partner_capital_transactions
FOR EACH ROW
EXECUTE FUNCTION public.trigger_handler_partner_capital_transactions_full();
-- #endregion [trigger_partner_capital_transactions_full]
-- #region [trigger_project_staff_financial_fees_fixed_full]
DROP TRIGGER IF EXISTS trigger_project_staff_financial_fees_fixed_full
ON public.project_staff_financial_fees_fixed;

CREATE TRIGGER trigger_project_staff_financial_fees_fixed_full
AFTER INSERT OR UPDATE OR DELETE
ON public.project_staff_financial_fees_fixed
FOR EACH ROW
EXECUTE FUNCTION public.trigger_handler_project_staff_financial_fees_full();
-- #endregion [trigger_project_staff_financial_fees_fixed_full]
-- #region [trigger_project_staff_financial_fees_items_full]
DROP TRIGGER IF EXISTS trigger_project_staff_financial_fees_items_full
ON public.project_staff_financial_fees_items;

CREATE TRIGGER trigger_project_staff_financial_fees_items_full
AFTER INSERT OR UPDATE OR DELETE
ON public.project_staff_financial_fees_items
FOR EACH ROW
EXECUTE FUNCTION public.trigger_handler_project_staff_financial_fees_full();
-- #endregion [trigger_project_staff_financial_fees_items_full]
-- #region [trigger_project_client_financial_fees_fixed_full]
DROP TRIGGER IF EXISTS trigger_project_client_financial_fees_fixed_full
ON public.project_client_financial_fees_fixed;

CREATE TRIGGER trigger_project_client_financial_fees_fixed_full
AFTER INSERT OR UPDATE OR DELETE
ON public.project_client_financial_fees_fixed
FOR EACH ROW
EXECUTE FUNCTION public.trigger_handler_project_client_financial_fees_full();
-- #endregion [trigger_project_client_financial_fees_fixed_full]
-- #region [trigger_project_client_financial_fees_items_full]
DROP TRIGGER IF EXISTS trigger_project_client_financial_fees_items_full
ON public.project_client_financial_fees_items;

CREATE TRIGGER trigger_project_client_financial_fees_items_full
AFTER INSERT OR UPDATE OR DELETE
ON public.project_client_financial_fees_items
FOR EACH ROW
EXECUTE FUNCTION public.trigger_handler_project_client_financial_fees_full();
-- #endregion [trigger_project_client_financial_fees_items_full]
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
-- #region [partner_capital_transactions]
TRUNCATE TABLE public.partner_capital_transactions RESTART IDENTITY CASCADE;
INSERT INTO public.partner_capital_transactions (partner_id, transaction_type, amount, transaction_date, notes)
VALUES
    --احمد ثامر 
    ('72d903ae-6e99-4c8b-af4a-67e38b5cefea', 'deposit', 10000000, '2025-09-28', 'احتاجينه فلوس لفقار التميمي لجامعة الكوفة'),
    --احمد اسماعيل 
    ('21b53991-6bfd-49b8-b56e-da7b808e146b', 'deposit', 5500000, '2025-10-21', 'قام باعطائي مبلغ الأرباح الموزع بعد إضافة 15 الف على المبلغ'),
    ('21b53991-6bfd-49b8-b56e-da7b808e146b', 'deposit', 4500000, '2025-10-22', 'اكمال المبلغ ليصبح المجموع 10 مليون');
-- #endregion [partner_capital_transactions]
-- #region [clients]
TRUNCATE TABLE public.clients RESTART IDENTITY CASCADE;
INSERT INTO public.clients (name)
VALUES
    ('ابو حوراء'),
    ('الشكرجي'),
    ('ابو نصير'),
    ('مالك ابو كرار'),
    ('شركة قصور المستقبل'),
    ('فقار التميمي'),
    ('مهندس امجد'),
    ('شركة الغدير للاستثمارات العقارية'),
    ('محمد عزيز'),
    ('مهندس مسلم');
-- #endregion [clients]
-- #region [projects]
TRUNCATE TABLE public.projects RESTART IDENTITY CASCADE;
INSERT INTO public.projects (client_id, title)
VALUES
    ((SELECT id FROM public.clients WHERE name = 'ابو حوراء'),'البحر - المرحلة الثانية'),
    ((SELECT id FROM public.clients WHERE name = 'الشكرجي'),'منزله - شارع المطار'),
    ((SELECT id FROM public.clients WHERE name = 'ابو نصير'),'المحكمة'),
    ((SELECT id FROM public.clients WHERE name = 'مالك ابو كرار'),'منزله - المكرمة'),
    ((SELECT id FROM public.clients WHERE name = 'شركة قصور المستقبل'),'جامعة الكوفة - دور الاساتذة'),
    ((SELECT id FROM public.clients WHERE name = 'فقار التميمي'),'جامعة الكوفة - كلية القانون'),
    ((SELECT id FROM public.clients WHERE name = 'مهندس امجد'),'فندق ريبال - الروان'),
    ((SELECT id FROM public.clients WHERE name = 'شركة الغدير للاستثمارات العقارية'),'مجمع البدور'),
    ((SELECT id FROM public.clients WHERE name = 'محمد عزيز'),'منزله - مجمع المختار'),
    ((SELECT id FROM public.clients WHERE name = 'مهندس مسلم'),'بناية الغدير');
-- #endregion [projects]
-- #region [staff]
TRUNCATE TABLE public.staff RESTART IDENTITY CASCADE;
INSERT INTO public.staff (name)
VALUES
    ('عباس التميمي'),
    ('سعد جريو'),
    ('ابو كوثر'),
    ('فقار التميمي'),
    ('علي طماطه'),
    ('كرار واجهات'),
    ('ابو ادريس'),
    ('ابو علي ايران'),
    ('احمد وفلاح'),
    ('تحسين'),
    ('زيد'),
    ('ابو دموع');
-- #endregion [staff]
-- #region [project_staff_financial_fees]
TRUNCATE TABLE public.project_staff_financial_fees RESTART IDENTITY CASCADE;
INSERT INTO public.project_staff_financial_fees (project_id, staff_id)
VALUES (
  (SELECT id FROM public.projects WHERE title = 'البحر - المرحلة الثانية' LIMIT 1),
  (SELECT id FROM public.staff WHERE name = 'عباس التميمي' LIMIT 1)
);
-- #endregion [project_staff_financial_fees]
-- #region [project_staff_financial_fees_items]
-- Use sql editor to insert because uuid is not known and without truncate
-- TRUNCATE TABLE public.project_staff_financial_fees_items RESTART IDENTITY CASCADE;
-- INSERT INTO public.project_staff_financial_fees_items
--     (project_staff_financial_fees_id, title, quantity, unit_price, notes)
-- VALUES
--     ('UUID', 'لبخ اسمنت', 750, 6000, 'تم حساب الكمية من قبل احمد ثامر واحمد اسماعيل');

-- #endregion [project_staff_financial_fees_items]
-- #region [project_client_financial_fees]
TRUNCATE TABLE public.project_client_financial_fees RESTART IDENTITY CASCADE;
INSERT INTO public.project_client_financial_fees (project_id)
VALUES ((SELECT id FROM public.projects WHERE title = 'البحر - المرحلة الثانية' LIMIT 1));
-- #endregion [project_staff_financial_fees]
-- #region [project_client_financial_fees_items]
-- Use sql editor to insert because uuid is not known and without truncate
-- TRUNCATE TABLE public.project_client_financial_fees_items RESTART IDENTITY CASCADE;
-- INSERT INTO public.project_client_financial_fees_items
--     (project_client_financial_fees_id, title, quantity, unit_price, notes)
-- VALUES
--     ('UUID', 'لبخ اسمنت', 750, 7500, 'تم حساب الكمية من قبل احمد ثامر واحمد اسماعيل');
-- #endregion [project_client_financial_fees_items]
-- #endregion [Data]
-- ############################################################