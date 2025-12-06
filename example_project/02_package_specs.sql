CREATE OR REPLACE PACKAGE insert_pkg AS
    -- USERS
    PROCEDURE insert_into_users(
        p_user_id IN NUMBER,
        p_username IN VARCHAR2,
        p_email IN VARCHAR2,
        p_password_hash IN VARCHAR2,
        p_profile_picture IN VARCHAR2,
        p_is_admin IN NUMBER
    );

    -- CHANNELS
    PROCEDURE insert_into_channels(
        p_channel_id IN NUMBER,
        p_channel_name IN VARCHAR2,
        p_description IN CLOB
    );

    -- ENTRIES
    PROCEDURE insert_into_entries(
        p_entry_id IN NUMBER,
        p_title IN VARCHAR2,
        p_content IN CLOB,
        p_user_id IN NUMBER,
        p_channel_id IN NUMBER
    );

    -- MESSAGES
    PROCEDURE insert_into_messages(
        p_message_id IN NUMBER,
        p_sender_id IN NUMBER,
        p_receiver_id IN NUMBER,
        p_content IN CLOB,
        p_is_read IN NUMBER
    );

    -- COMMENTS
    PROCEDURE insert_into_comments(
        p_comment_id IN NUMBER,
        p_entry_id IN NUMBER,
        p_user_id IN NUMBER,
        p_content IN CLOB
    );

    -- LIKES
    PROCEDURE insert_into_likes(
        p_like_id IN NUMBER,
        p_entry_id IN NUMBER,
        p_comment_id IN NUMBER,
        p_user_id IN NUMBER
    );

    -- REPORTS
    PROCEDURE insert_into_reports(
        p_report_id IN NUMBER,
        p_user_id IN NUMBER,
        p_entry_id IN NUMBER,
        p_comment_id IN NUMBER,
        p_reason IN CLOB,
        p_status IN VARCHAR2
    );

    -- SAVED_ENTRIES
    PROCEDURE insert_into_saved_entries(
        p_saved_id IN NUMBER,
        p_user_id IN NUMBER,
        p_entry_id IN NUMBER
    );
END insert_pkg;
/

CREATE OR REPLACE PACKAGE update_pkg AS
    PROCEDURE update_users(
        p_user_id IN NUMBER,
        p_username IN VARCHAR2,
        p_email IN VARCHAR2,
        p_password_hash IN VARCHAR2,
        p_profile_picture IN VARCHAR2,
        p_is_admin IN NUMBER
    );

    PROCEDURE update_channels(
        p_channel_id IN NUMBER,
        p_channel_name IN VARCHAR2,
        p_description IN CLOB
    );

    PROCEDURE update_entries(
        p_entry_id IN NUMBER,
        p_title IN VARCHAR2,
        p_content IN CLOB
    );

    PROCEDURE update_likes(
    p_like_id IN NUMBER,
    p_entry_id IN NUMBER,
    p_comment_id IN NUMBER,
    p_user_id IN NUMBER
    );


    PROCEDURE update_messages(
        p_message_id IN NUMBER,
        p_content IN CLOB,
        p_is_read IN NUMBER
    );

    PROCEDURE update_comments(
        p_comment_id IN NUMBER,
        p_content IN CLOB
    );

    PROCEDURE update_reports(
        p_report_id IN NUMBER,
        p_status IN VARCHAR2
    );

    PROCEDURE update_saved_entries(
        p_saved_id IN NUMBER,
        p_entry_id IN NUMBER
    );
END update_pkg;
/

CREATE OR REPLACE PACKAGE delete_pkg AS
    PROCEDURE delete_from_users(p_user_id IN NUMBER);

    PROCEDURE delete_from_channels(p_channel_id IN NUMBER);

    PROCEDURE delete_from_entries(p_entry_id IN NUMBER);

    PROCEDURE delete_from_messages(p_message_id IN NUMBER);

    PROCEDURE delete_from_comments(p_comment_id IN NUMBER);

    PROCEDURE delete_from_reports(p_report_id IN NUMBER);

    PROCEDURE delete_from_saved_entries(p_saved_id IN NUMBER);

    PROCEDURE delete_from_likes(p_like_id IN NUMBER);

END delete_pkg;
/

CREATE OR REPLACE PACKAGE delete_duplicates_pkg AS
    -- Procedure Definitions
    PROCEDURE delete_duplicates_from_users;
    PROCEDURE delete_duplicates_from_entries;
    PROCEDURE delete_duplicates_from_channels;
    PROCEDURE delete_duplicates_from_messages;
    PROCEDURE delete_duplicates_from_comments;
    PROCEDURE delete_duplicates_from_reports;
    PROCEDURE delete_duplicates_from_saved_entries;
    PROCEDURE delete_duplicates_from_likes;
END delete_duplicates_pkg;
/
