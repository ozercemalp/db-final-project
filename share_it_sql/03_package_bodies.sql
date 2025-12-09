-- 03_package_bodies.sql
-- Package Body for ShareIt logic

CREATE OR REPLACE PACKAGE BODY shareit_pkg AS

   -- =========================================================================
   --  UTILITY: ID Lookups
   -- =========================================================================

   FUNCTION get_user_id (
      p_username IN VARCHAR2
   ) RETURN NUMBER IS
      v_id NUMBER;
   BEGIN
      SELECT user_id
        INTO v_id
        FROM users
       WHERE username = p_username;
      RETURN v_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         raise_application_error(
            -20001,
            'User not found: ' || p_username
         );
   END get_user_id;

   FUNCTION get_subforum_id (
      p_name IN VARCHAR2
   ) RETURN NUMBER IS
      v_id NUMBER;
   BEGIN
      SELECT subforum_id
        INTO v_id
        FROM subforums
       WHERE name = p_name;
      RETURN v_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         raise_application_error(
            -20002,
            'Subforum not found: ' || p_name
         );
   END get_subforum_id;

   FUNCTION get_post_id (
      p_title           IN VARCHAR2,
      p_author_username IN VARCHAR2
   ) RETURN NUMBER IS
      v_id        NUMBER;
      v_author_id NUMBER;
   BEGIN
      -- First find the author ID to ensure accuracy
      v_author_id := get_user_id(p_author_username);
      SELECT post_id
        INTO v_id
        FROM posts
       WHERE title = p_title
         AND user_id = v_author_id;
      RETURN v_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         raise_application_error(
            -20003,
            'Post not found: "'
            || p_title
            || '" by '
            || p_author_username
         );
   END get_post_id;


   -- =========================================================================
   --  PROCEDURES: USERS
   -- =========================================================================

   PROCEDURE add_user (
      p_username IN VARCHAR2,
      p_email    IN VARCHAR2,
      p_password IN VARCHAR2
   ) IS
   BEGIN
      INSERT INTO users (
         user_id,
         username,
         email,
         password_hash
      ) VALUES ( seq_users_id.nextval,
                 p_username,
                 p_email,
                 p_password );
      COMMIT;
      dbms_output.put_line('User added: ' || p_username);
   EXCEPTION
      WHEN dup_val_on_index THEN
         dbms_output.put_line('Error: Username or Email already exists for ' || p_username);
      WHEN OTHERS THEN
         dbms_output.put_line('Error adding user: ' || sqlerrm);
         ROLLBACK;
   END add_user;

   PROCEDURE update_user_email (
      p_user_id   IN NUMBER,
      p_new_email IN VARCHAR2
   ) IS
   BEGIN
      UPDATE users
         SET
         email = p_new_email
       WHERE user_id = p_user_id;

      IF SQL%ROWCOUNT = 0 THEN
         dbms_output.put_line('User not found with ID: ' || p_user_id);
      ELSE
         COMMIT;
         dbms_output.put_line('User email updated successfully.');
      END IF;
   EXCEPTION
      WHEN dup_val_on_index THEN
         dbms_output.put_line('Error: Email already in use.');
         ROLLBACK;
      WHEN OTHERS THEN
         dbms_output.put_line('Error updating email: ' || sqlerrm);
         ROLLBACK;
   END update_user_email;

   -- =========================================================================
   --  PROCEDURES: SUBFORUMS
   -- =========================================================================

   -- MACHINE
   PROCEDURE create_subforum (
      p_name        IN VARCHAR2,
      p_description IN VARCHAR2,
      p_creator_id  IN NUMBER
   ) IS
   BEGIN
      INSERT INTO subforums (
         subforum_id,
         name,
         description,
         creator_id
      ) VALUES ( seq_subforums_id.nextval,
                 p_name,
                 p_description,
                 p_creator_id );
      COMMIT;
      dbms_output.put_line('Subforum created: ' || p_name);
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error creating subforum: ' || sqlerrm);
         ROLLBACK;
   END create_subforum;

   -- HUMAN
   PROCEDURE create_subforum (
      p_name             IN VARCHAR2,
      p_description      IN VARCHAR2,
      p_creator_username IN VARCHAR2
   ) IS
      v_creator_id NUMBER;
   BEGIN
      v_creator_id := get_user_id(p_creator_username);
      create_subforum(
         p_name,
         p_description,
         v_creator_id
      );
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error (Human) creating subforum: ' || sqlerrm);
   END create_subforum;


   -- =========================================================================
   --  PROCEDURES: POSTS
   -- =========================================================================

   -- MACHINE
   PROCEDURE create_post (
      p_user_id     IN NUMBER,
      p_subforum_id IN NUMBER,
      p_title       IN VARCHAR2,
      p_content     IN CLOB
   ) IS
   BEGIN
      INSERT INTO posts (
         post_id,
         user_id,
         subforum_id,
         title,
         content_text
      ) VALUES ( seq_posts_id.nextval,
                 p_user_id,
                 p_subforum_id,
                 p_title,
                 p_content );
      COMMIT;
      dbms_output.put_line('Post created: "'
                           || p_title || '"');
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error creating post: ' || sqlerrm);
         ROLLBACK;
   END create_post;

   -- HUMAN
   PROCEDURE create_post (
      p_username      IN VARCHAR2,
      p_subforum_name IN VARCHAR2,
      p_title         IN VARCHAR2,
      p_content       IN CLOB
   ) IS
      v_user_id     NUMBER;
      v_subforum_id NUMBER;
   BEGIN
      v_user_id := get_user_id(p_username);
      v_subforum_id := get_subforum_id(p_subforum_name);
      create_post(
         v_user_id,
         v_subforum_id,
         p_title,
         p_content
      );
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error (Human) creating post: ' || sqlerrm);
   END create_post;

   PROCEDURE update_post_content (
      p_post_id     IN NUMBER,
      p_new_content IN CLOB
   ) IS
   BEGIN
      UPDATE posts
         SET
         content_text = p_new_content
       WHERE post_id = p_post_id;

      IF SQL%ROWCOUNT = 0 THEN
         dbms_output.put_line('Post not found with ID: ' || p_post_id);
      ELSE
         COMMIT;
         dbms_output.put_line('Post content updated successfully.');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error updating post: ' || sqlerrm);
         ROLLBACK;
   END update_post_content;

   PROCEDURE delete_post (
      p_post_id IN NUMBER
   ) IS
   BEGIN
      DELETE FROM posts
       WHERE post_id = p_post_id;

      IF SQL%ROWCOUNT = 0 THEN
         dbms_output.put_line('Post not found with ID: ' || p_post_id);
      ELSE
         COMMIT;
         dbms_output.put_line('Post deleted successfully.');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error deleting post: ' || sqlerrm);
         ROLLBACK;
   END delete_post;

   -- =========================================================================
   --  PROCEDURES: COMMENTS
   -- =========================================================================

   -- MACHINE
   PROCEDURE create_comment (
      p_post_id           IN NUMBER,
      p_user_id           IN NUMBER,
      p_content           IN VARCHAR2,
      p_parent_comment_id IN NUMBER DEFAULT NULL
   ) IS
   BEGIN
      INSERT INTO comments (
         comment_id,
         post_id,
         user_id,
         parent_comment_id,
         content
      ) VALUES ( seq_comments_id.nextval,
                 p_post_id,
                 p_user_id,
                 p_parent_comment_id,
                 p_content );
      COMMIT;
      dbms_output.put_line('Comment added to post ' || p_post_id);
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error creating comment: ' || sqlerrm);
         ROLLBACK;
   END create_comment;

   -- HUMAN
   PROCEDURE create_comment (
      p_post_title           IN VARCHAR2,
      p_post_author_username IN VARCHAR2,
      p_username             IN VARCHAR2,
      p_content              IN VARCHAR2,
      p_parent_comment_id    IN NUMBER DEFAULT NULL
   ) IS
      v_post_id NUMBER;
      v_user_id NUMBER;
   BEGIN
      v_post_id := get_post_id(
         p_post_title,
         p_post_author_username
      );
      v_user_id := get_user_id(p_username);
      create_comment(
         v_post_id,
         v_user_id,
         p_content,
         p_parent_comment_id
      );
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error (Human) creating comment: ' || sqlerrm);
   END create_comment;

   PROCEDURE delete_comment (
      p_comment_id IN NUMBER
   ) IS
   BEGIN
      DELETE FROM comments
       WHERE comment_id = p_comment_id;

      IF SQL%ROWCOUNT = 0 THEN
         dbms_output.put_line('Comment not found with ID: ' || p_comment_id);
      ELSE
         COMMIT;
         dbms_output.put_line('Comment deleted successfully.');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error deleting comment: ' || sqlerrm);
         ROLLBACK;
   END delete_comment;

   -- =========================================================================
   --  PROCEDURES: VOTES
   -- =========================================================================

   -- MACHINE
   PROCEDURE vote_post (
      p_user_id   IN NUMBER,
      p_post_id   IN NUMBER,
      p_vote_type IN NUMBER
   ) IS
   BEGIN
      IF p_vote_type = 0 THEN
         -- Remove vote
         DELETE FROM post_votes
          WHERE user_id = p_user_id
            AND post_id = p_post_id;

         dbms_output.put_line('Vote removed from post ' || p_post_id);
      ELSE
         -- Try update first
         UPDATE post_votes
            SET
            vote_type = p_vote_type
          WHERE user_id = p_user_id
            AND post_id = p_post_id;
            
         -- If no row updated, insert new
         IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO post_votes (
               user_id,
               post_id,
               vote_type
            ) VALUES ( p_user_id,
                       p_post_id,
                       p_vote_type );
            dbms_output.put_line('Vote cast (new) on post ' || p_post_id);
         ELSE
            dbms_output.put_line('Vote updated on post ' || p_post_id);
         END IF;
      END IF;

      COMMIT;
   END vote_post;

   -- HUMAN
   PROCEDURE vote_post (
      p_username             IN VARCHAR2,
      p_post_title           IN VARCHAR2,
      p_post_author_username IN VARCHAR2,
      p_vote_type            IN NUMBER
   ) IS
      v_user_id NUMBER;
      v_post_id NUMBER;
   BEGIN
      v_user_id := get_user_id(p_username);
      v_post_id := get_post_id(
         p_post_title,
         p_post_author_username
      );
      vote_post(
         v_user_id,
         v_post_id,
         p_vote_type
      );
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error (Human) casting vote: ' || sqlerrm);
   END vote_post;


   -- =========================================================================
   --  PROCEDURES: SUBSCRIPTIONS
   -- =========================================================================

   -- MACHINE
   PROCEDURE subscribe_user (
      p_user_id     IN NUMBER,
      p_subforum_id IN NUMBER
   ) IS
   BEGIN
      INSERT INTO user_subscriptions (
         user_id,
         subforum_id
      ) VALUES ( p_user_id,
                 p_subforum_id );
      COMMIT;
      dbms_output.put_line('User '
                           || p_user_id
                           || ' subscribed to subforum ' || p_subforum_id);
   EXCEPTION
      WHEN dup_val_on_index THEN
         dbms_output.put_line('Subscription already exists.');
      WHEN OTHERS THEN
         dbms_output.put_line('Error subscribing: ' || sqlerrm);
         ROLLBACK;
   END subscribe_user;

   -- HUMAN
   PROCEDURE subscribe_user (
      p_username      IN VARCHAR2,
      p_subforum_name IN VARCHAR2
   ) IS
      v_user_id     NUMBER;
      v_subforum_id NUMBER;
   BEGIN
      v_user_id := get_user_id(p_username);
      v_subforum_id := get_subforum_id(p_subforum_name);
      subscribe_user(
         v_user_id,
         v_subforum_id
      );
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error (Human) subscribing: ' || sqlerrm);
   END subscribe_user;


   -- =========================================================================
   --  MAINTENANCE
   -- =========================================================================

   PROCEDURE remove_duplicate_subscriptions IS
   BEGIN
      DELETE FROM user_subscriptions a
       WHERE rowid > (
         SELECT MIN(rowid)
           FROM user_subscriptions b
          WHERE a.user_id = b.user_id
            AND a.subforum_id = b.subforum_id
      );

      dbms_output.put_line('Deleted '
                           || SQL%ROWCOUNT || ' duplicate subscriptions.');
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error removing duplicates: ' || sqlerrm);
         ROLLBACK;
   END remove_duplicate_subscriptions;

END shareit_pkg;
/