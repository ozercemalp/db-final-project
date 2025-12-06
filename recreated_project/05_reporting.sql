DECLARE
    v_user_id    NUMBER := 1; -- User ID input
    v_start_date DATE := TO_DATE('2024-01-01', 'YYYY-MM-DD'); -- Start date
    v_end_date   DATE := TO_DATE('2024-12-31', 'YYYY-MM-DD'); -- End date

    -- Temporary variables
    v_entry_title VARCHAR2(4000);
    v_comment_content VARCHAR2(4000);
BEGIN
    -- Query Entries and Comments Together
    FOR entry_comment_rec IN (
        SELECT e.TITLE AS ENTRY_TITLE, c.CONTENT AS COMMENT_CONTENT
        FROM ENTRIES e
        LEFT JOIN COMMENTS c
        ON e.ENTRY_ID = c.ENTRY_ID
        WHERE e.USER_ID = v_user_id
        AND e.CREATED_AT BETWEEN v_start_date AND v_end_date
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Entry Title: ' || entry_comment_rec.ENTRY_TITLE);
        IF entry_comment_rec.COMMENT_CONTENT IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('   Comment: ' || entry_comment_rec.COMMENT_CONTENT);
        ELSE
            DBMS_OUTPUT.PUT_LINE('   No comments for this entry.');
        END IF;
    END LOOP;
END;
/
