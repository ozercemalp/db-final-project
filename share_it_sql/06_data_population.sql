-- 06_data_population.sql
-- Populate the database with sample data
-- Uses "Human" overloaded procedures in shareit_pkg to avoid hardcoded IDs.

SET SERVEROUTPUT ON;

BEGIN
   DBMS_OUTPUT.PUT_LINE('Starting Data Population...');

    -- 1. Create Users
    -- tinman
   shareit_pkg.add_user(
      'tinman',
      'tim@example.com',
      'hashed_pass_123'
   );
    -- jdoe
   shareit_pkg.add_user(
      'jdoe',
      'john@example.com',
      'secret123'
   );
    -- alice_w
   shareit_pkg.add_user(
      'alice_w',
      'alice@wonderland.com',
      'rabbit_hole'
   );
    -- test_user
   shareit_pkg.add_user(
      'test_user',
      'test@test.com',
      '123456'
   );

    -- 2. Create Subforums
    -- DatabaseMemes created by tinman
   shareit_pkg.create_subforum(
      p_name             => 'DatabaseMemes',
      p_description      => 'Memes about databases',
      p_creator_username => 'tinman'
   );
    -- AskOracle created by tinman
   shareit_pkg.create_subforum(
      p_name             => 'AskOracle',
      p_description      => 'Questions about Oracle DB',
      p_creator_username => 'tinman'
   );
    -- ProgrammerHumor created by jdoe
   shareit_pkg.create_subforum(
      p_name             => 'ProgrammerHumor',
      p_description      => 'Funny coding stuff',
      p_creator_username => 'jdoe'
   );

    -- 3. Create Posts
    -- Post by tinman in DatabaseMemes
   shareit_pkg.create_post(
      p_username      => 'tinman',
      p_subforum_name => 'DatabaseMemes',
      p_title         => 'When you drop production table',
      p_content       => 'Validation failed successfully.'
   );

    -- Post by jdoe in AskOracle
   shareit_pkg.create_post(
      p_username      => 'jdoe',
      p_subforum_name => 'AskOracle',
      p_title         => 'How to remove duplicates?',
      p_content       => 'I need a stored procedure for this.'
   );

    -- Post by alice_w in ProgrammerHumor
   shareit_pkg.create_post(
      p_username      => 'alice_w',
      p_subforum_name => 'ProgrammerHumor',
      p_title         => 'My code works on my machine',
      p_content       => 'But not in prod.'
   );
    
    -- 4. Create Comments
    -- jdoe comments on tinman's post
   shareit_pkg.create_comment(
      p_post_title           => 'When you drop production table',
      p_post_author_username => 'tinman',
      p_username             => 'jdoe',
      p_content              => 'Been there, done that.'
   );

    -- alice_w comments on tinman's post
   shareit_pkg.create_comment(
      p_post_title           => 'When you drop production table',
      p_post_author_username => 'tinman',
      p_username             => 'alice_w',
      p_content              => 'F in the chat.'
   );

    -- 5. Votes (Testing Triggers)

    -- jdoe upvotes tinman's post
   shareit_pkg.vote_post(
      p_username             => 'jdoe',
      p_post_title           => 'When you drop production table',
      p_post_author_username => 'tinman',
      p_vote_type            => 1
   );

    -- alice_w upvotes tinman's post
   shareit_pkg.vote_post(
      p_username             => 'alice_w',
      p_post_title           => 'When you drop production table',
      p_post_author_username => 'tinman',
      p_vote_type            => 1
   );

    -- tinman upvotes jdoe's post
   shareit_pkg.vote_post(
      p_username             => 'tinman',
      p_post_title           => 'How to remove duplicates?',
      p_post_author_username => 'jdoe',
      p_vote_type            => 1
   );

    -- test_user downvotes alice_w's post
   shareit_pkg.vote_post(
      p_username             => 'test_user',
      p_post_title           => 'My code works on my machine',
      p_post_author_username => 'alice_w',
      p_vote_type            => - 1
   );

    -- 6. User Subscriptions
    -- tinman subscribes to DatabaseMemes
   shareit_pkg.subscribe_user(
      p_username      => 'tinman',
      p_subforum_name => 'DatabaseMemes'
   );

    -- tinman subscribes to AskOracle
   shareit_pkg.subscribe_user(
      p_username      => 'tinman',
      p_subforum_name => 'AskOracle'
   );

    -- jdoe subscribes to DatabaseMemes
   shareit_pkg.subscribe_user(
      p_username      => 'jdoe',
      p_subforum_name => 'DatabaseMemes'
   );
   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Data Population Completed.');
END;
/

-- Verify Reporting
BEGIN
   DBMS_OUTPUT.PUT_LINE('Running Reporting Tests...');
   -- We need to know IDs for reporting, so we look them up dynamically for the test
   -- or we assume the reporting procedure is still ID based (which it is).
   -- For this simple verify block, we can just call it with 1 as it was before,
   -- OR we can look up the ID first if we want to be pure.
   -- Since this is just a quick check at the end of the script:
   DECLARE
      v_user_id NUMBER;
   BEGIN
      SELECT user_id
        INTO v_user_id
        FROM users
       WHERE username = 'tinman';
      get_filtered_posts(
         v_user_id,
         NULL
      );
   END;

   get_user_report(0); -- 0 usually means "All Users" or similar in some reports, or might be invalid.
                       -- The original script had 0.
END;
/