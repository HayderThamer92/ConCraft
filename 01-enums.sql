-- ============================================================
-- #region [role_enum]
DROP TYPE IF EXISTS public.role_enum CASCADE;
CREATE TYPE public.role_enum AS ENUM ('admin', 'user');
-- #endregion [role_enum]
-- ============================================================
-- ============================================================
-- #region [transaction_type_enum]
DROP TYPE IF EXISTS public.transaction_type_enum CASCADE;
CREATE TYPE public.transaction_type_enum AS ENUM ('deposit', 'withdraw');
-- #endregion [transaction_type_enum]
-- ============================================================
-- ============================================================
-- #region [placeholder]
-- #endregion [placeholder]
-- ============================================================