-- ============================================================
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
-- ============================================================
-- ============================================================
-- #region [placeholder]
-- #endregion [placeholder]
-- ============================================================