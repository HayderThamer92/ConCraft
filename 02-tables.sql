-- ============================================================
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
-- ============================================================
-- ============================================================
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
-- ============================================================
-- ============================================================
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
-- ============================================================
-- ============================================================
-- #region [partner_capital_transactions]
DROP TABLE IF EXISTS public.partner_capital_transactions CASCADE;
CREATE TABLE
    public.partner_capital_transactions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        partner_id UUID NOT NULL REFERENCES PUBLIC.partners (id) ON DELETE CASCADE ON UPDATE CASCADE,
        transaction_type transaction_type_enum NOT NULL,
        amount BIGINT NOT NULL,
        transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
        notes TEXT,
        CONSTRAINT cash_amount_check CHECK (amount > 0)
    );
ALTER TABLE PUBLIC.partner_capital_transactions ENABLE ROW LEVEL SECURITY;
CREATE INDEX partner_capital_transactions_partner_id_idx ON PUBLIC.partner_capital_transactions (partner_id);
-- #endregion [partner_capital_transactions]
-- ============================================================
-- ============================================================
-- #region [placeholder]
-- #endregion [placeholder]
-- ============================================================