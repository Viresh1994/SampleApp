-- Lock down public
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- Allow usage
GRANT USAGE ON SCHEMA dams TO "dams-reader@YOURTENANT.onmicrosoft.com";
GRANT USAGE ON SCHEMA dams TO "dams-writer@YOURTENANT.onmicrosoft.com";

-- Existing tables
GRANT SELECT ON ALL TABLES IN SCHEMA dams TO "dams-reader@YOURTENANT.onmicrosoft.com";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA dams TO "dams-writer@YOURTENANT.onmicrosoft.com";

-- Future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA dams
GRANT SELECT ON TABLES TO "dams-reader@YOURTENANT.onmicrosoft.com";

ALTER DEFAULT PRIVILEGES IN SCHEMA dams
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "dams-writer@YOURTENANT.onmicrosoft.com";
