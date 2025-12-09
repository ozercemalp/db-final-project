-- 04_triggers.sql
-- PL/SQL Triggers
-- Contains triggers for auditing, karma calculation, and vote count synchronization.

-- Requirement #7: Data entry to transaction table via trigger

-- Trigger for POSTS table (Audit)
CREATE OR REPLACE TRIGGER trg_posts_log AFTER
   INSERT OR UPDATE OR DELETE ON posts
   FOR EACH ROW
DECLARE
   v_type    VARCHAR2(10);
   v_details VARCHAR2(4000);
BEGIN
   IF INSERTING THEN
      v_type := 'INSERT';
      v_details := 'New post created by User ID: ' || :new.user_id;
   ELSIF UPDATING THEN
      v_type := 'UPDATE';
      v_details := 'Post ID: '
                   || :old.post_id
                   || ' updated.';
   ELSIF DELETING THEN
      v_type := 'DELETE';
      v_details := 'Post ID: '
                   || :old.post_id
                   || ' deleted.';
   END IF;

   INSERT INTO transaction_logs (
      log_id,
      table_name,
      transaction_type,
      details
   ) VALUES ( seq_logs_id.NEXTVAL,
              'POSTS',
              v_type,
              v_details );
END;
/

-- Trigger for USERS table (Audit)
CREATE OR REPLACE TRIGGER trg_users_log AFTER
   INSERT OR UPDATE OR DELETE ON users
   FOR EACH ROW
DECLARE
   v_type    VARCHAR2(10);
   v_details VARCHAR2(4000);
BEGIN
   IF INSERTING THEN
      v_type := 'INSERT';
      v_details := 'New user registered: ' || :new.username;
   ELSIF UPDATING THEN
      v_type := 'UPDATE';
      v_details := 'User ID: '
                   || :old.user_id
                   || ' updated.';
   ELSIF DELETING THEN
      v_type := 'DELETE';
      v_details := 'User ID: '
                   || :old.user_id
                   || ' deleted.';
   END IF;

   INSERT INTO transaction_logs (
      log_id,
      table_name,
      transaction_type,
      details
   ) VALUES ( seq_logs_id.NEXTVAL,
              'USERS',
              v_type,
              v_details );
END;
/

-- Trigger for POST_VOTES (Update Post Upvotes Count)
-- Keeps the denormalized upvotes column in POSTS table in sync.
CREATE OR REPLACE TRIGGER trg_post_votes_count AFTER
   INSERT OR UPDATE OR DELETE ON post_votes
   FOR EACH ROW
BEGIN
   IF INSERTING THEN
        -- New vote: Add vote_type (1 or -1) to total
      UPDATE posts
         SET
         upvotes = upvotes + :new.vote_type
       WHERE post_id = :new.post_id;
   ELSIF DELETING THEN
        -- Removed vote: Subtract vote_type (1 becomes -1, -1 becomes +1)
      UPDATE posts
         SET
         upvotes = upvotes - :old.vote_type
       WHERE post_id = :old.post_id;
   ELSIF UPDATING THEN
        -- Changed vote: Subtract old, add new
      UPDATE posts
         SET
         upvotes = upvotes - :old.vote_type + :new.vote_type
       WHERE post_id = :new.post_id;
   END IF;
END;
/

-- Trigger for POST_VOTES (Update User Karma)
-- Updates the karma of the *author* of the post.
CREATE OR REPLACE TRIGGER trg_post_votes_karma AFTER
   INSERT OR UPDATE OR DELETE ON post_votes
   FOR EACH ROW
DECLARE
   v_author_id NUMBER;
BEGIN
   IF INSERTING THEN
      SELECT user_id
        INTO v_author_id
        FROM posts
       WHERE post_id = :new.post_id;
      UPDATE users
         SET
         karma = karma + :new.vote_type
       WHERE user_id = v_author_id;
   ELSIF DELETING THEN
      SELECT user_id
        INTO v_author_id
        FROM posts
       WHERE post_id = :old.post_id;
      UPDATE users
         SET
         karma = karma - :old.vote_type
       WHERE user_id = v_author_id;
   ELSIF UPDATING THEN
      SELECT user_id
        INTO v_author_id
        FROM posts
       WHERE post_id = :new.post_id;
      UPDATE users
         SET
         karma = karma - :old.vote_type + :new.vote_type
       WHERE user_id = v_author_id;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        -- Post might have been deleted, ignore
      NULL;
END;
/

-- Trigger for COMMENT_VOTES (Update User Karma)
-- Updates the karma of the *author* of the comment.
CREATE OR REPLACE TRIGGER trg_comment_votes_karma AFTER
   INSERT OR UPDATE OR DELETE ON comment_votes
   FOR EACH ROW
DECLARE
   v_author_id NUMBER;
BEGIN
   IF INSERTING THEN
      SELECT user_id
        INTO v_author_id
        FROM comments
       WHERE comment_id = :new.comment_id;
      UPDATE users
         SET
         karma = karma + :new.vote_type
       WHERE user_id = v_author_id;
   ELSIF DELETING THEN
      SELECT user_id
        INTO v_author_id
        FROM comments
       WHERE comment_id = :old.comment_id;
      UPDATE users
         SET
         karma = karma - :old.vote_type
       WHERE user_id = v_author_id;
   ELSIF UPDATING THEN
      SELECT user_id
        INTO v_author_id
        FROM comments
       WHERE comment_id = :new.comment_id;
      UPDATE users
         SET
         karma = karma - :old.vote_type + :new.vote_type
       WHERE user_id = v_author_id;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        -- Comment might have been deleted, ignore
      NULL;
END;
/
