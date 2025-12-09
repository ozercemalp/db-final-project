-- 00_cleanup.sql
-- Cleans up the database by dropping existing tables and sequences/objects if they exist.
-- Order matters to avoid foreign key constraint errors.

BEGIN
   FOR c IN (
      SELECT table_name
        FROM USER_TABLES
       WHERE table_name IN ( 'USER_AWARDS',
                             'AWARDS',
                             'MODERATORS',
                             'REPORTS',
                             'MESSAGES',
                             'SAVED_ITEMS',
                             'COMMENT_VOTES',
                             'POST_VOTES',
                             'COMMENTS',
                             'POSTS',
                             'USER_SUBSCRIPTIONS',
                             'SUBFORUM_RULES',
                             'SUBFORUMS',
                             'USERS',
                             'TRANSACTION_LOGS',
                             'SUBREDDIT_RULES',
                             'SUBREDDITS' -- in case old ones exist
                              )
   ) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE '
                        || c.table_name
                        || ' CASCADE CONSTRAINTS';
   END LOOP;

   FOR c IN (
      SELECT sequence_name
        FROM USER_SEQUENCES
       WHERE sequence_name LIKE 'SEQ_%'
   ) LOOP
      EXECUTE IMMEDIATE 'DROP SEQUENCE ' || c.sequence_name;
   END LOOP;
    
    -- Drop packages if they exist
   BEGIN
      EXECUTE IMMEDIATE 'DROP PACKAGE ShareIt_Pkg';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;
END;
/
