-- ============================================================
-- #region [trigger_partner_capital_transactions]
CREATE TRIGGER trigger_partner_capital_transactions
AFTER INSERT OR UPDATE OR DELETE ON partner_capital_transactions
FOR EACH ROW
EXECUTE FUNCTION trigger_handler_partner_capital_transactions();
-- #endregion [trigger_partner_capital_transactions]
-- ============================================================
-- ============================================================
-- #region [placeholder]
-- #endregion [placeholder]
-- ============================================================