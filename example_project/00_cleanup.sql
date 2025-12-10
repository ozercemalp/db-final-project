-- ============================================================================
-- CLEANUP SCRIPT
-- Drops all objects created by the project scripts.
-- ============================================================================

-- Drop Packages
DROP PACKAGE insert_pkg;
DROP PACKAGE update_pkg;
DROP PACKAGE delete_pkg;
DROP PACKAGE delete_duplicates_pkg;

-- Drop Tables (with CASCADE CONSTRAINTS to handle foreign keys, and PURGE to remove from recycle bin)
-- Dropping in reverse order of dependency for clarity, though CASCADE handles it.

DROP TABLE REPORTS CASCADE CONSTRAINTS PURGE;
DROP TABLE LIKES CASCADE CONSTRAINTS PURGE;
DROP TABLE SAVED_ENTRIES CASCADE CONSTRAINTS PURGE;
DROP TABLE COMMENTS CASCADE CONSTRAINTS PURGE;
DROP TABLE MESSAGES CASCADE CONSTRAINTS PURGE;
DROP TABLE ENTRIES CASCADE CONSTRAINTS PURGE;
DROP TABLE CHANNELS CASCADE CONSTRAINTS PURGE;
DROP TABLE USERS CASCADE CONSTRAINTS PURGE;
DROP TABLE TRANSACTIONS CASCADE CONSTRAINTS PURGE;

PROMPT Cleanup complete. All project objects have been dropped.
