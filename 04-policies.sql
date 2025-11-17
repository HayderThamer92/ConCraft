-- ============================================================
-- #region [cash]
DROP POLICY IF EXISTS "cash_policy_select" ON cash;
-- SELECT Policy [admin,user]
CREATE POLICY "cash_policy_select" ON cash FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- #endregion [cash]
-- ============================================================
-- ============================================================
-- #region [capital]
DROP POLICY IF EXISTS "capital_policy_select" ON capital;
-- SELECT Policy [admin,user]
CREATE POLICY "capital_policy_select" ON capital FOR
SELECT
    USING (get_current_user_role () IN ('admin', 'user'));
-- #endregion [capital]
-- ============================================================
-- ============================================================
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
-- ============================================================
-- ============================================================
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
-- ============================================================
-- ============================================================
-- #region [placeholder]
-- #endregion [placeholder]
-- ============================================================