DO $$
DECLARE
    user_exists BOOLEAN;
BEGIN
    RAISE NOTICE 'Ensuring AAD user exists: %', '$username';

    SELECT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = '$username'
    ) INTO user_exists;

    IF user_exists THEN
        RAISE NOTICE 'User % already exists', '$username';
    ELSE
        RAISE NOTICE 'Creating AAD user %', '$username';
        PERFORM pg_catalog.pgaadauth_create_principal('$username', false, false);
        RAISE NOTICE 'User % created', '$username';
    END IF;
END
$$;
