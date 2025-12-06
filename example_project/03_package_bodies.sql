CREATE OR REPLACE PACKAGE BODY insert_pkg AS

    -- USERS
    PROCEDURE insert_into_users(
        p_user_id IN NUMBER,
        p_username IN VARCHAR2,
        p_email IN VARCHAR2,
        p_password_hash IN VARCHAR2,
        p_profile_picture IN VARCHAR2,
        p_is_admin IN NUMBER
    ) IS
    BEGIN
        INSERT INTO USERS (
            USER_ID, USERNAME, EMAIL, PASSWORD_HASH, PROFILE_PICTURE, CREATED_AT, IS_ADMIN
        ) VALUES (
            p_user_id,
            p_username,
            p_email,
            p_password_hash,
            p_profile_picture,
            SYSTIMESTAMP,
            p_is_admin
        );
        DBMS_OUTPUT.PUT_LINE('User inserted successfully: ' || p_username);
    END insert_into_users;

    -- CHANNELS
    PROCEDURE insert_into_channels(
        p_channel_id IN NUMBER,
        p_channel_name IN VARCHAR2,
        p_description IN CLOB
    ) IS
    BEGIN
        INSERT INTO CHANNELS (
            CHANNEL_ID, CHANNEL_NAME, DESCRIPTION
        ) VALUES (
            p_channel_id,
            p_channel_name,
            p_description
        );
        DBMS_OUTPUT.PUT_LINE('Channel inserted successfully: ' || p_channel_name);
    END insert_into_channels;

    -- ENTRIES
    PROCEDURE insert_into_entries(
        p_entry_id IN NUMBER,
        p_title IN VARCHAR2,
        p_content IN CLOB,
        p_user_id IN NUMBER,
        p_channel_id IN NUMBER
    ) IS
    BEGIN
        INSERT INTO ENTRIES (
            ENTRY_ID, TITLE, CONTENT, USER_ID, CHANNEL_ID, CREATED_AT, UPDATED_AT
        ) VALUES (
            p_entry_id,
            p_title,
            p_content,
            p_user_id,
            p_channel_id,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
        DBMS_OUTPUT.PUT_LINE('Entry inserted successfully: ' || p_title);
    END insert_into_entries;

    -- MESSAGES
    PROCEDURE insert_into_messages(
        p_message_id IN NUMBER,
        p_sender_id IN NUMBER,
        p_receiver_id IN NUMBER,
        p_content IN CLOB,
        p_is_read IN NUMBER
    ) IS
    BEGIN
        INSERT INTO MESSAGES (
            MESSAGE_ID, SENDER_ID, RECEIVER_ID, CONTENT, SENT_AT, IS_READ
        ) VALUES (
            p_message_id,
            p_sender_id,
            p_receiver_id,
            p_content,
            SYSTIMESTAMP,
            p_is_read
        );
        DBMS_OUTPUT.PUT_LINE('Message inserted successfully: ' || p_message_id);
    END insert_into_messages;

    -- COMMENTS
    PROCEDURE insert_into_comments(
        p_comment_id IN NUMBER,
        p_entry_id IN NUMBER,
        p_user_id IN NUMBER,
        p_content IN CLOB
    ) IS
    BEGIN
        INSERT INTO COMMENTS (
            COMMENT_ID, ENTRY_ID, USER_ID, CONTENT, CREATED_AT
        ) VALUES (
            p_comment_id,
            p_entry_id,
            p_user_id,
            p_content,
            SYSTIMESTAMP
        );
        DBMS_OUTPUT.PUT_LINE('Comment inserted successfully: ' || p_comment_id);
    END insert_into_comments;

    -- LIKES
    PROCEDURE insert_into_likes(
        p_like_id IN NUMBER,
        p_entry_id IN NUMBER,
        p_comment_id IN NUMBER,
        p_user_id IN NUMBER
    ) IS
    BEGIN
        INSERT INTO LIKES (
            LIKE_ID, ENTRY_ID, COMMENT_ID, USER_ID, CREATED_AT
        ) VALUES (
            p_like_id,
            p_entry_id,
            p_comment_id,
            p_user_id,
            SYSTIMESTAMP
        );
        DBMS_OUTPUT.PUT_LINE('Like inserted successfully: ' || p_like_id);
    END insert_into_likes;

    -- REPORTS
    PROCEDURE insert_into_reports(
        p_report_id IN NUMBER,
        p_user_id IN NUMBER,
        p_entry_id IN NUMBER,
        p_comment_id IN NUMBER,
        p_reason IN CLOB,
        p_status IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO REPORTS (
            REPORT_ID, USER_ID, ENTRY_ID, COMMENT_ID, REASON, CREATED_AT, STATUS
        ) VALUES (
            p_report_id,
            p_user_id,
            p_entry_id,
            p_comment_id,
            p_reason,
            SYSTIMESTAMP,
            p_status
        );
        DBMS_OUTPUT.PUT_LINE('Report inserted successfully: ' || p_report_id);
    END insert_into_reports;

    -- SAVED_ENTRIES
    PROCEDURE insert_into_saved_entries(
        p_saved_id IN NUMBER,
        p_user_id IN NUMBER,
        p_entry_id IN NUMBER
    ) IS
    BEGIN
        INSERT INTO SAVED_ENTRIES (
            SAVED_ID, USER_ID, ENTRY_ID, SAVED_AT
        ) VALUES (
            p_saved_id,
            p_user_id,
            p_entry_id,
            SYSTIMESTAMP
        );
        DBMS_OUTPUT.PUT_LINE('Saved Entry inserted successfully: ' || p_saved_id);
    END insert_into_saved_entries;

END insert_pkg;
/

CREATE OR REPLACE PACKAGE BODY update_pkg AS

    -- USERS Table
    PROCEDURE update_users(
        p_user_id IN NUMBER,
        p_username IN VARCHAR2,
        p_email IN VARCHAR2,
        p_password_hash IN VARCHAR2,
        p_profile_picture IN VARCHAR2,
        p_is_admin IN NUMBER
    ) IS
    BEGIN
        UPDATE USERS
        SET USERNAME = p_username,
            EMAIL = p_email,
            PASSWORD_HASH = p_password_hash,
            PROFILE_PICTURE = p_profile_picture,
            IS_ADMIN = p_is_admin
        WHERE USER_ID = p_user_id;

        DBMS_OUTPUT.PUT_LINE('User updated successfully: ' || p_user_id);
    END update_users;

    -- CHANNELS Table
    PROCEDURE update_channels(
        p_channel_id IN NUMBER,
        p_channel_name IN VARCHAR2,
        p_description IN CLOB
    ) IS
    BEGIN
        UPDATE CHANNELS
        SET CHANNEL_NAME = p_channel_name,
            DESCRIPTION = p_description
        WHERE CHANNEL_ID = p_channel_id;

        DBMS_OUTPUT.PUT_LINE('Channel updated successfully: ' || p_channel_id);
    END update_channels;

    -- ENTRIES Table
    PROCEDURE update_entries(
        p_entry_id IN NUMBER,
        p_title IN VARCHAR2,
        p_content IN CLOB
    ) IS
    BEGIN
        UPDATE ENTRIES
        SET TITLE = p_title,
            CONTENT = p_content,
            UPDATED_AT = SYSTIMESTAMP
        WHERE ENTRY_ID = p_entry_id;

        DBMS_OUTPUT.PUT_LINE('Entry updated successfully: ' || p_entry_id);
    END update_entries;

    -- likes table
    PROCEDURE update_likes(
        p_like_id IN NUMBER,
        p_entry_id IN NUMBER,
        p_comment_id IN NUMBER,
        p_user_id IN NUMBER
    ) IS
    BEGIN
        UPDATE LIKES
        SET ENTRY_ID = p_entry_id,
            COMMENT_ID = p_comment_id,
            USER_ID = p_user_id,
            CREATED_AT = SYSTIMESTAMP -- Tarihi güncelliyoruz
        WHERE LIKE_ID = p_like_id;

            IF SQL%ROWCOUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Like updated successfully: ' || p_like_id);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Like not found: ' || p_like_id);
    END IF;
    END update_likes;


    -- MESSAGES Table
    PROCEDURE update_messages(
        p_message_id IN NUMBER,
        p_content IN CLOB,
        p_is_read IN NUMBER
    ) IS
    BEGIN
        UPDATE MESSAGES
        SET CONTENT = p_content,
            IS_READ = p_is_read
        WHERE MESSAGE_ID = p_message_id;

        DBMS_OUTPUT.PUT_LINE('Message updated successfully: ' || p_message_id);
    END update_messages;

    -- COMMENTS Table
    PROCEDURE update_comments(
        p_comment_id IN NUMBER,
        p_content IN CLOB
    ) IS
    BEGIN
        UPDATE COMMENTS
        SET CONTENT = p_content
        WHERE COMMENT_ID = p_comment_id;

        DBMS_OUTPUT.PUT_LINE('Comment updated successfully: ' || p_comment_id);
    END update_comments;

    -- REPORTS Table
    PROCEDURE update_reports(
        p_report_id IN NUMBER,
        p_status IN VARCHAR2
    ) IS
    BEGIN
        UPDATE REPORTS
        SET STATUS = p_status
        WHERE REPORT_ID = p_report_id;

        DBMS_OUTPUT.PUT_LINE('Report updated successfully: ' || p_report_id);
    END update_reports;

    -- SAVED_ENTRIES Table
    PROCEDURE update_saved_entries(
        p_saved_id IN NUMBER,
        p_entry_id IN NUMBER
    ) IS
    BEGIN
        UPDATE SAVED_ENTRIES
        SET ENTRY_ID = p_entry_id
        WHERE SAVED_ID = p_saved_id;

        DBMS_OUTPUT.PUT_LINE('Saved Entry updated successfully: ' || p_saved_id);
    END update_saved_entries;

END update_pkg;
/

CREATE OR REPLACE PACKAGE BODY delete_pkg AS

    -- USERS -
    PROCEDURE delete_from_users(p_user_id IN NUMBER) IS
    BEGIN
        DELETE FROM USERS WHERE USER_ID = p_user_id;
        DBMS_OUTPUT.PUT_LINE('User deleted successfully: ' || p_user_id);
    END delete_from_users;

    -- CHANNELS -
    PROCEDURE delete_from_channels(p_channel_id IN NUMBER) IS
    BEGIN
        DELETE FROM CHANNELS WHERE CHANNEL_ID = p_channel_id;
        DBMS_OUTPUT.PUT_LINE('Channel deleted successfully: ' || p_channel_id);
    END delete_from_channels;

    -- ENTRIES -
    PROCEDURE delete_from_entries(p_entry_id IN NUMBER) IS
    BEGIN
        DELETE FROM ENTRIES WHERE ENTRY_ID = p_entry_id;
        DBMS_OUTPUT.PUT_LINE('Entry deleted successfully: ' || p_entry_id);
    END delete_from_entries;


    --LIKES TABLE
    PROCEDURE delete_from_likes(
    p_like_id IN NUMBER
    ) IS
    BEGIN
    DELETE FROM LIKES
    WHERE LIKE_ID = p_like_id;

    IF SQL%ROWCOUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Like deleted successfully: ' || p_like_id);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Like not found: ' || p_like_id);
    END IF;
    END delete_from_likes;


    -- MESSAGES -
    PROCEDURE delete_from_messages(p_message_id IN NUMBER) IS
    BEGIN
        DELETE FROM MESSAGES WHERE MESSAGE_ID = p_message_id;
        DBMS_OUTPUT.PUT_LINE('Message deleted successfully: ' || p_message_id);
    END delete_from_messages;

    -- COMMENTS -
    PROCEDURE delete_from_comments(p_comment_id IN NUMBER) IS
    BEGIN
        DELETE FROM COMMENTS WHERE COMMENT_ID = p_comment_id;
        DBMS_OUTPUT.PUT_LINE('Comment deleted successfully: ' || p_comment_id);
    END delete_from_comments;

    -- REPORTS -
    PROCEDURE delete_from_reports(p_report_id IN NUMBER) IS
    BEGIN
        DELETE FROM REPORTS WHERE REPORT_ID = p_report_id;
        DBMS_OUTPUT.PUT_LINE('Report deleted successfully: ' || p_report_id);
    END delete_from_reports;

    -- SAVED_ENTRIES -
    PROCEDURE delete_from_saved_entries(p_saved_id IN NUMBER) IS
    BEGIN
        DELETE FROM SAVED_ENTRIES WHERE SAVED_ID = p_saved_id;
        DBMS_OUTPUT.PUT_LINE('Saved Entry deleted successfully: ' || p_saved_id);
    END delete_from_saved_entries;

END delete_pkg;
/

CREATE OR REPLACE PACKAGE BODY delete_duplicates_pkg AS

    -- Delete USERS Duplicates
    PROCEDURE delete_duplicates_from_users IS
    BEGIN
        DELETE FROM USERS
        WHERE user_id IN (
            SELECT user_id
            FROM (
                SELECT user_id, ROW_NUMBER() OVER (PARTITION BY username, email ORDER BY user_id) AS row_num
                FROM USERS
            )
            WHERE row_num > 1
        );
        DBMS_OUTPUT.PUT_LINE('Duplicate users deleted successfully.');
    END delete_duplicates_from_users;

    PROCEDURE delete_duplicates_from_entries IS
    BEGIN
        DELETE FROM ENTRIES
        WHERE entry_id IN (
            SELECT entry_id
            FROM (
                SELECT entry_id, ROW_NUMBER() OVER (PARTITION BY title, content ORDER BY entry_id) AS row_num
                FROM ENTRIES
            )
            WHERE row_num > 1
        );
        DBMS_OUTPUT.PUT_LINE('Duplicate entries deleted successfully.');
    END delete_duplicates_from_entries;

    PROCEDURE delete_duplicates_from_channels IS
    BEGIN
        DELETE FROM CHANNELS
        WHERE channel_id IN (
            SELECT channel_id
            FROM (
                SELECT channel_id, ROW_NUMBER() OVER (PARTITION BY channel_name ORDER BY channel_id) AS row_num
                FROM CHANNELS
            )
            WHERE row_num > 1
        );
        DBMS_OUTPUT.PUT_LINE('Duplicate channels deleted successfully.');
    END delete_duplicates_from_channels;

    PROCEDURE delete_duplicates_from_messages IS
    BEGIN
        DELETE FROM MESSAGES
        WHERE message_id IN (
            SELECT message_id
            FROM (
                SELECT message_id, ROW_NUMBER() OVER (PARTITION BY sender_id, receiver_id, content ORDER BY message_id) AS row_num
                FROM MESSAGES
            )
            WHERE row_num > 1
        );
        DBMS_OUTPUT.PUT_LINE('Duplicate messages deleted successfully.');
    END delete_duplicates_from_messages;

    PROCEDURE delete_duplicates_from_comments IS
    BEGIN
        DELETE FROM COMMENTS
        WHERE comment_id IN (
            SELECT comment_id
            FROM (
                SELECT comment_id, ROW_NUMBER() OVER (PARTITION BY entry_id, user_id, content ORDER BY comment_id) AS row_num
                FROM COMMENTS
            )
            WHERE row_num > 1
        );
        DBMS_OUTPUT.PUT_LINE('Duplicate comments deleted successfully.');
    END delete_duplicates_from_comments;

    PROCEDURE delete_duplicates_from_reports IS
    BEGIN
        DELETE FROM REPORTS
        WHERE report_id IN (
            SELECT report_id
            FROM (
                SELECT report_id, ROW_NUMBER() OVER (PARTITION BY user_id, entry_id, comment_id ORDER BY report_id) AS row_num
                FROM REPORTS
            )
            WHERE row_num > 1
        );
        DBMS_OUTPUT.PUT_LINE('Duplicate reports deleted successfully.');
    END delete_duplicates_from_reports;

    PROCEDURE delete_duplicates_from_saved_entries IS
    BEGIN
        DELETE FROM SAVED_ENTRIES
        WHERE saved_id IN (
            SELECT saved_id
            FROM (
                SELECT saved_id, ROW_NUMBER() OVER (PARTITION BY user_id, entry_id ORDER BY saved_id) AS row_num
                FROM SAVED_ENTRIES
            )
            WHERE row_num > 1
        );
        DBMS_OUTPUT.PUT_LINE('Duplicate saved entries deleted successfully.');
    END delete_duplicates_from_saved_entries;

    PROCEDURE delete_duplicates_from_likes IS
    BEGIN
        DELETE FROM LIKES
        WHERE like_id IN (
            SELECT like_id
            FROM (
                SELECT like_id, ROW_NUMBER() OVER (PARTITION BY entry_id, comment_id, user_id ORDER BY like_id) AS row_num
                FROM LIKES
            )
            WHERE row_num > 1
        );
        DBMS_OUTPUT.PUT_LINE('Duplicate likes deleted successfully.');
    END delete_duplicates_from_likes;

END delete_duplicates_pkg;
/
