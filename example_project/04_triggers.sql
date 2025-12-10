CREATE OR REPLACE TRIGGER users_after_insert_trigger
AFTER INSERT ON USERS
FOR EACH ROW
BEGIN
    INSERT INTO TRANSACTIONS (
        ENTITY_NAME,
        OPERATION_TYPE,
        REFERENCE_ID,
        OPERATION_DATE
    ) VALUES (
        'USERS', -- Operated table
        'INSERT', -- operation type
        :NEW.USER_ID,
        SYSTIMESTAMP -- operation date
    );
END;
/



CREATE OR REPLACE TRIGGER entries_after_insert_trigger
AFTER INSERT ON ENTRIES
FOR EACH ROW
BEGIN
    INSERT INTO TRANSACTIONS (
        ENTITY_NAME,
        OPERATION_TYPE,
        REFERENCE_ID,
        OPERATION_DATE
    ) VALUES (
        'ENTRIES', -- Operated table
        'INSERT', -- operation type
        :NEW.ENTRY_ID,
        SYSTIMESTAMP -- operation date
    );
END;
/




CREATE OR REPLACE TRIGGER messages_after_insert_trigger
AFTER INSERT ON MESSAGES
FOR EACH ROW
BEGIN
    INSERT INTO TRANSACTIONS (
        ENTITY_NAME,
        OPERATION_TYPE,
        REFERENCE_ID,
        OPERATION_DATE
    ) VALUES (
        'MESSAGES', -- Operated table
        'INSERT', -- operation type
        :NEW.MESSAGE_ID,
        SYSTIMESTAMP -- operation date
    );
END;
/




CREATE OR REPLACE TRIGGER comments_after_insert_trigger
AFTER INSERT ON COMMENTS
FOR EACH ROW
BEGIN
    INSERT INTO TRANSACTIONS (
        ENTITY_NAME,
        OPERATION_TYPE,
        REFERENCE_ID,
        OPERATION_DATE
    ) VALUES (
        'COMMENTS', -- Operated table
        'INSERT', -- operation type
        :NEW.COMMENT_ID, -- COMMENT_ID of inserted comment
        SYSTIMESTAMP -- Operation time
    );
END;
/




CREATE OR REPLACE TRIGGER likes_after_insert_trigger
AFTER INSERT ON LIKES
FOR EACH ROW
BEGIN
    INSERT INTO TRANSACTIONS (
        ENTITY_NAME,
        OPERATION_TYPE,
        REFERENCE_ID,
        OPERATION_DATE
    ) VALUES (
        'LIKES', -- Operated table
        'INSERT', -- operation type
        :NEW.LIKE_ID,
        SYSTIMESTAMP -- operation date
    );
END;
/



CREATE OR REPLACE TRIGGER reports_after_insert_trigger
AFTER INSERT ON REPORTS
FOR EACH ROW
BEGIN
    INSERT INTO TRANSACTIONS (
        ENTITY_NAME,
        OPERATION_TYPE,
        REFERENCE_ID,
        OPERATION_DATE
    ) VALUES (
        'REPORTS', -- Operated table
        'INSERT', -- operation type
        :NEW.REPORT_ID,
        SYSTIMESTAMP -- operation date
    );
END;
/



CREATE OR REPLACE TRIGGER saved_entries_after_insert_trigger
AFTER INSERT ON SAVED_ENTRIES
FOR EACH ROW
BEGIN
    INSERT INTO TRANSACTIONS (
        ENTITY_NAME,
        OPERATION_TYPE,
        REFERENCE_ID,
        OPERATION_DATE
    ) VALUES (
        'SAVED_ENTRIES', -- Operated table
        'INSERT', -- operation type
        :NEW.SAVED_ID,
        SYSTIMESTAMP -- operation date
    );
END;
/



CREATE OR REPLACE TRIGGER channels_after_insert_trigger
AFTER INSERT ON CHANNELS
FOR EACH ROW
BEGIN
    INSERT INTO TRANSACTIONS (
        ENTITY_NAME,
        OPERATION_TYPE,
        REFERENCE_ID,
        OPERATION_DATE
    ) VALUES (
        'CHANNELS', -- Operated table
        'INSERT', -- operation type
        :NEW.CHANNEL_ID,
        SYSTIMESTAMP -- operation date
    );
END;
/
