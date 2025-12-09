-- 02_package_specs.sql
-- Package Specification for ShareIt logic
-- Contains procedures for data entry, update, deletion, and maintenance.

CREATE OR REPLACE PACKAGE shareit_pkg AS

    -- Requirement #4: Data Entry

    -- Users
    -- Adds a new user to the system.
   PROCEDURE add_user (
      p_username IN VARCHAR2,
      p_email    IN VARCHAR2,
      p_password IN VARCHAR2
   );

    -- Subforums
    -- MACHINE: Creates a new subforum using IDs.
   PROCEDURE create_subforum (
      p_name        IN VARCHAR2,
      p_description IN VARCHAR2,
      p_creator_id  IN NUMBER
   );

    -- HUMAN: Creates a new subforum using usernames.
   PROCEDURE create_subforum (
      p_name             IN VARCHAR2,
      p_description      IN VARCHAR2,
      p_creator_username IN VARCHAR2
   );

    -- Posts
    -- MACHINE: Creates a new post in a subforum using IDs.
   PROCEDURE create_post (
      p_user_id     IN NUMBER,
      p_subforum_id IN NUMBER,
      p_title       IN VARCHAR2,
      p_content     IN CLOB
   );

    -- HUMAN: Creates a new post using names.
   PROCEDURE create_post (
      p_username      IN VARCHAR2,
      p_subforum_name IN VARCHAR2,
      p_title         IN VARCHAR2,
      p_content       IN CLOB
   );

    -- Comments
    -- MACHINE: Creates a comment using IDs.
   PROCEDURE create_comment (
      p_post_id           IN NUMBER,
      p_user_id           IN NUMBER,
      p_content           IN VARCHAR2,
      p_parent_comment_id IN NUMBER DEFAULT NULL
   );

    -- HUMAN: Creates a comment looking up the post by Title + Author.
   PROCEDURE create_comment (
      p_post_title           IN VARCHAR2,
      p_post_author_username IN VARCHAR2,
      p_username             IN VARCHAR2,
      p_content              IN VARCHAR2,
      p_parent_comment_id    IN NUMBER DEFAULT NULL
   );

    -- Votes
    -- MACHINE: Casts a vote using IDs.
   PROCEDURE vote_post (
      p_user_id   IN NUMBER,
      p_post_id   IN NUMBER,
      p_vote_type IN NUMBER
   );

    -- HUMAN: Casts a vote using names/titles.
   PROCEDURE vote_post (
      p_username             IN VARCHAR2,
      p_post_title           IN VARCHAR2,
      p_post_author_username IN VARCHAR2,
      p_vote_type            IN NUMBER
   );

    -- Subscriptions
    -- MACHINE: Subscribes a user to a subforum using IDs.
   PROCEDURE subscribe_user (
      p_user_id     IN NUMBER,
      p_subforum_id IN NUMBER
   );

    -- HUMAN: Subscribes a user to a subforum using names.
   PROCEDURE subscribe_user (
      p_username      IN VARCHAR2,
      p_subforum_name IN VARCHAR2
   );

    -- Requirement #5: Data Update
    -- Updates a user's email address.
   PROCEDURE update_user_email (
      p_user_id   IN NUMBER,
      p_new_email IN VARCHAR2
   );

    -- Updates the content of a post.
   PROCEDURE update_post_content (
      p_post_id     IN NUMBER,
      p_new_content IN CLOB
   );

    -- Requirement #6: Data Deletion
    -- Deletes a post (cascades to comments/votes due to FK constraints).
   PROCEDURE delete_post (
      p_post_id IN NUMBER
   );

    -- Deletes a specific comment.
   PROCEDURE delete_comment (
      p_comment_id IN NUMBER
   );

    -- Requirement #10: Delete duplicate records
    -- Clean up duplicate subscriptions if they somehow occur.
   PROCEDURE remove_duplicate_subscriptions;

END shareit_pkg;
/
