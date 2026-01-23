DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.schemata WHERE schema_name = 'dams'
    ) THEN
        EXECUTE 'CREATE SCHEMA dams';
    END IF;

    EXECUTE 'ALTER SCHEMA dams OWNER TO "dams-writer@YOURTENANT.onmicrosoft.com"';
END
$$;
