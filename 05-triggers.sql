-- ============================================================
-- #region [trigger_partner_capital_transactions_full]
CREATE TRIGGER trigger_partner_capital_transactions_full
AFTER INSERT OR UPDATE OR DELETE ON partner_capital_transactions
FOR EACH ROW
EXECUTE FUNCTION trigger_handler_partner_capital_transactions_full();
-- #endregion [trigger_partner_capital_transactions_full]
-- ============================================================
-- ============================================================
-- #region [placeholder]
-- #endregion [placeholder]
-- ============================================================