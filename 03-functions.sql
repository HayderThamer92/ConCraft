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
-- #region [placeholder]
-- #endregion [placeholder]
-- ============================================================