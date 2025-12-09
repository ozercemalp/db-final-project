-- run_all.sql
-- Master script to build and populate the ShareIt database project.

PROMPT Running 00_cleanup.sql...
@@00_cleanup.sql

PROMPT Running 01_ddl.sql...
@@01_ddl.sql

PROMPT Running 02_package_specs.sql...
@@02_package_specs.sql

PROMPT Running 03_package_bodies.sql...
@@03_package_bodies.sql

PROMPT Running 04_triggers.sql...
@@04_triggers.sql

PROMPT Running 05_reporting.sql...
@@05_reporting.sql

PROMPT Running 06_data_population.sql...
@@06_data_population.sql

PROMPT Project Setup Complete.
