-- 05_reporting.sql
-- Reporting with Dynamic SQL (Requirement #8)
-- Procedures to generate reports based on dynamic criteria.

-- Report: Get posts filtered by upvotes and optionally by subforum
CREATE OR REPLACE PROCEDURE get_filtered_posts (
   p_min_upvotes   IN NUMBER DEFAULT 0,
   p_subforum_name IN VARCHAR2 DEFAULT NULL
) IS
   v_sql      VARCHAR2(2000);
   v_cursor   SYS_REFCURSOR;
   v_title    posts.title%TYPE;
   v_upvotes  posts.upvotes%TYPE;
   v_sub_name subforums.name%TYPE;
BEGIN
    -- Dynamic SQL construction
   v_sql := 'SELECT p.title, p.upvotes, s.name '
            || 'FROM POSTS p '
            || 'JOIN SUBFORUMS s ON p.subforum_id = s.subforum_id '
            || 'WHERE p.upvotes >= :1';

   -- Add optional filter
   IF p_subforum_name IS NOT NULL THEN
      v_sql := v_sql || ' AND s.name = :2';
      OPEN v_cursor FOR v_sql
         USING p_min_upvotes,p_subforum_name;
   ELSE
      OPEN v_cursor FOR v_sql
         USING p_min_upvotes;
   END IF;

   DBMS_OUTPUT.PUT_LINE('--- Post Report (Min Upvotes: '
                        || p_min_upvotes
                        || ') ---');
   LOOP
      FETCH v_cursor INTO
         v_title,
         v_upvotes,
         v_sub_name;
      EXIT WHEN v_cursor%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('Subforum: '
                           || RPAD(v_sub_name, 20)
                           || ' | Upvotes: '
                           || RPAD(TO_CHAR(v_upvotes), 5)
                           || ' | Title: ' || v_title);
   END LOOP;
   CLOSE v_cursor;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in post report: ' || SQLERRM);
      IF v_cursor%ISOPEN THEN
         CLOSE v_cursor;
      END IF;
END get_filtered_posts;
/

-- Report: User Karma Report
CREATE OR REPLACE PROCEDURE get_user_report (
   p_min_karma IN NUMBER
) IS
   v_cursor   SYS_REFCURSOR;
   v_username users.username%TYPE;
   v_karma    users.karma%TYPE;
   v_sql      VARCHAR2(1000);
BEGIN
   v_sql := 'SELECT username, karma FROM USERS WHERE karma >= :1 ORDER BY karma DESC';
   OPEN v_cursor FOR v_sql
      USING p_min_karma;

   DBMS_OUTPUT.PUT_LINE('--- User Karma Report (Min Karma: '
                        || p_min_karma
                        || ') ---');
   LOOP
      FETCH v_cursor INTO
         v_username,
         v_karma;
      EXIT WHEN v_cursor%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('User: '
                           || RPAD(v_username, 20)
                           || ' | Karma: ' || v_karma);
   END LOOP;
   CLOSE v_cursor;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in user report: ' || SQLERRM);
      IF v_cursor%ISOPEN THEN
         CLOSE v_cursor;
      END IF;
END get_user_report;
/
