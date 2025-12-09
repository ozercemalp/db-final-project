-- 01_ddl.sql
-- creation of tables, constraints, and indexes

-- 1. USERS Table
-- Stores user account information.
-- Karma is a derived value updated via triggers for performance.
CREATE TABLE users (
   user_id       NUMBER,
   username      VARCHAR2(50) NOT NULL,
   email         VARCHAR2(100) NOT NULL,
   password_hash VARCHAR2(255) NOT NULL,
   karma         NUMBER DEFAULT 0,
   created_at    DATE DEFAULT SYSDATE,
   CONSTRAINT pk_users PRIMARY KEY ( user_id ),
   CONSTRAINT uq_users_username UNIQUE ( username ),
   CONSTRAINT uq_users_email UNIQUE ( email )
);

CREATE SEQUENCE seq_users_id START WITH 1 INCREMENT BY 1;

-- 2. SUBFORUMS Table (Previously Subreddits)
-- Communities within the platform.
CREATE TABLE subforums (
   subforum_id NUMBER,
   name        VARCHAR2(50) NOT NULL,
   description VARCHAR2(500),
   created_at  DATE DEFAULT SYSDATE,
   creator_id  NUMBER,
   CONSTRAINT pk_subforums PRIMARY KEY ( subforum_id ),
   CONSTRAINT uq_subforums_name UNIQUE ( name ),
   CONSTRAINT fk_subforums_creator FOREIGN KEY ( creator_id )
      REFERENCES users ( user_id )
         ON DELETE SET NULL
);

CREATE SEQUENCE seq_subforums_id START WITH 1 INCREMENT BY 1;

-- 3. SUBFORUM_RULES Table
-- Rules specific to a subforum.
CREATE TABLE subforum_rules (
   rule_id     NUMBER,
   subforum_id NUMBER NOT NULL,
   rule_text   VARCHAR2(500) NOT NULL,
   CONSTRAINT pk_subforum_rules PRIMARY KEY ( rule_id ),
   CONSTRAINT fk_rules_subforum FOREIGN KEY ( subforum_id )
      REFERENCES subforums ( subforum_id )
         ON DELETE CASCADE
);

CREATE SEQUENCE seq_rules_id START WITH 1 INCREMENT BY 1;

-- 4. USER_SUBSCRIPTIONS Table (Junction Table)
-- Tracks which users have joined which subforums.
CREATE TABLE user_subscriptions (
   user_id     NUMBER NOT NULL,
   subforum_id NUMBER NOT NULL,
   joined_at   DATE DEFAULT SYSDATE,
   CONSTRAINT pk_user_subscriptions PRIMARY KEY ( user_id,
                                                  subforum_id ),
   CONSTRAINT fk_subs_user FOREIGN KEY ( user_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_subs_subforum FOREIGN KEY ( subforum_id )
      REFERENCES subforums ( subforum_id )
         ON DELETE CASCADE
);

-- 5. POSTS Table
-- User submitted content within a subforum.
-- Upvotes is a derived value updated via triggers.
CREATE TABLE posts (
   post_id      NUMBER,
   user_id      NUMBER NOT NULL,
   subforum_id  NUMBER NOT NULL,
   title        VARCHAR2(300) NOT NULL,
   content_text CLOB,
   upvotes      NUMBER DEFAULT 0,
   created_at   DATE DEFAULT SYSDATE,
   CONSTRAINT pk_posts PRIMARY KEY ( post_id ),
   CONSTRAINT fk_posts_user FOREIGN KEY ( user_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_posts_subforum FOREIGN KEY ( subforum_id )
      REFERENCES subforums ( subforum_id )
         ON DELETE CASCADE
);

CREATE SEQUENCE seq_posts_id START WITH 1 INCREMENT BY 1;

-- 6. COMMENTS Table (Self-Referencing)
-- Comments on posts, can reply to other comments.
CREATE TABLE comments (
   comment_id        NUMBER,
   post_id           NUMBER NOT NULL,
   user_id           NUMBER NOT NULL,
   parent_comment_id NUMBER, -- Recursive relationship (Reply to comment)
   content           VARCHAR2(2000) NOT NULL,
   created_at        DATE DEFAULT SYSDATE,
   CONSTRAINT pk_comments PRIMARY KEY ( comment_id ),
   CONSTRAINT fk_comments_post FOREIGN KEY ( post_id )
      REFERENCES posts ( post_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_comments_user FOREIGN KEY ( user_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_comments_parent FOREIGN KEY ( parent_comment_id )
      REFERENCES comments ( comment_id )
         ON DELETE CASCADE
);

CREATE SEQUENCE seq_comments_id START WITH 1 INCREMENT BY 1;

-- 7. POST_VOTES Table
-- Tracks votes on posts to prevent duplicate voting and calculate scores.
CREATE TABLE post_votes (
   user_id   NUMBER NOT NULL,
   post_id   NUMBER NOT NULL,
   vote_type NUMBER(1) CHECK ( vote_type IN ( 1,
                                              - 1 ) ), -- 1 for up, -1 for down
   CONSTRAINT pk_post_votes PRIMARY KEY ( user_id,
                                          post_id ),
   CONSTRAINT fk_pvotes_user FOREIGN KEY ( user_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_pvotes_post FOREIGN KEY ( post_id )
      REFERENCES posts ( post_id )
         ON DELETE CASCADE
);

-- 8. COMMENT_VOTES Table
-- Tracks votes on comments.
CREATE TABLE comment_votes (
   user_id    NUMBER NOT NULL,
   comment_id NUMBER NOT NULL,
   vote_type  NUMBER(1) CHECK ( vote_type IN ( 1,
                                              - 1 ) ),
   CONSTRAINT pk_comment_votes PRIMARY KEY ( user_id,
                                             comment_id ),
   CONSTRAINT fk_cvotes_user FOREIGN KEY ( user_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_cvotes_comment FOREIGN KEY ( comment_id )
      REFERENCES comments ( comment_id )
         ON DELETE CASCADE
);

-- 9. SAVED_ITEMS Table
-- Posts saved by users.
CREATE TABLE saved_items (
   user_id  NUMBER NOT NULL,
   post_id  NUMBER NOT NULL,
   saved_at DATE DEFAULT SYSDATE,
   CONSTRAINT pk_saved_items PRIMARY KEY ( user_id,
                                           post_id ),
   CONSTRAINT fk_saved_user FOREIGN KEY ( user_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_saved_post FOREIGN KEY ( post_id )
      REFERENCES posts ( post_id )
         ON DELETE CASCADE
);

-- 10. MESSAGES Table
-- Direct messages between users.
CREATE TABLE messages (
   message_id  NUMBER,
   sender_id   NUMBER NOT NULL,
   receiver_id NUMBER NOT NULL,
   subject     VARCHAR2(200),
   body        VARCHAR2(2000),
   sent_at     DATE DEFAULT SYSDATE,
   is_read     NUMBER(1) DEFAULT 0,
   CONSTRAINT pk_messages PRIMARY KEY ( message_id ),
   CONSTRAINT fk_msg_sender FOREIGN KEY ( sender_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_msg_receiver FOREIGN KEY ( receiver_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT chk_msg_is_read CHECK ( is_read IN ( 0,
                                                   1 ) )
);

CREATE SEQUENCE seq_messages_id START WITH 1 INCREMENT BY 1;

-- 11. REPORTS Table
-- Moderation reports for posts or comments.
CREATE TABLE reports (
   report_id   NUMBER,
   reporter_id NUMBER NOT NULL,
   post_id     NUMBER, -- Nullable, could report a comment
   comment_id  NUMBER, -- Nullable, could report a post
   reason      VARCHAR2(500) NOT NULL,
   status      VARCHAR2(20) DEFAULT 'OPEN',
   reported_at DATE DEFAULT SYSDATE,
   CONSTRAINT pk_reports PRIMARY KEY ( report_id ),
   CONSTRAINT fk_reports_reporter FOREIGN KEY ( reporter_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_reports_post FOREIGN KEY ( post_id )
      REFERENCES posts ( post_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_reports_comment FOREIGN KEY ( comment_id )
      REFERENCES comments ( comment_id )
         ON DELETE CASCADE,
   CONSTRAINT chk_report_target
      CHECK ( post_id IS NOT NULL
          OR comment_id IS NOT NULL ),
   CONSTRAINT chk_report_status
      CHECK ( status IN ( 'OPEN',
                          'RESOLVED',
                          'DISMISSED' ) )
);

CREATE SEQUENCE seq_reports_id START WITH 1 INCREMENT BY 1;

-- 12. MODERATORS Table
-- Users with moderation privileges on specific subforums.
CREATE TABLE moderators (
   user_id          NUMBER NOT NULL,
   subforum_id      NUMBER NOT NULL,
   permission_level VARCHAR2(20) DEFAULT 'BASIC',
   grade            NUMBER DEFAULT 1,
   CONSTRAINT pk_moderators PRIMARY KEY ( user_id,
                                          subforum_id ),
   CONSTRAINT fk_mods_user FOREIGN KEY ( user_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_mods_subforum FOREIGN KEY ( subforum_id )
      REFERENCES subforums ( subforum_id )
         ON DELETE CASCADE
);

-- 13. AWARDS Table
-- Awards that can be given to posts/comments.
CREATE TABLE awards (
   award_id  NUMBER,
   name      VARCHAR2(50) NOT NULL,
   cost      NUMBER NOT NULL, -- Cost in coins/karma
   image_url VARCHAR2(255),
   CONSTRAINT pk_awards PRIMARY KEY ( award_id )
);

CREATE SEQUENCE seq_awards_id START WITH 1 INCREMENT BY 1;

-- 14. USER_AWARDS Table
-- Instances of awards given.
CREATE TABLE user_awards (
   id         NUMBER,
   award_id   NUMBER NOT NULL,
   giver_id   NUMBER NOT NULL,
   post_id    NUMBER,
   comment_id NUMBER,
   given_at   DATE DEFAULT SYSDATE,
   CONSTRAINT pk_user_awards PRIMARY KEY ( id ),
   CONSTRAINT fk_uawards_award FOREIGN KEY ( award_id )
      REFERENCES awards ( award_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_uawards_giver FOREIGN KEY ( giver_id )
      REFERENCES users ( user_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_uawards_post FOREIGN KEY ( post_id )
      REFERENCES posts ( post_id )
         ON DELETE CASCADE,
   CONSTRAINT fk_uawards_comment FOREIGN KEY ( comment_id )
      REFERENCES comments ( comment_id )
         ON DELETE CASCADE
);

CREATE SEQUENCE seq_user_awards_id START WITH 1 INCREMENT BY 1;

-- 15. TRANSACTION_LOGS Table
-- Audit log for Requirements #7.
CREATE TABLE transaction_logs (
   log_id           NUMBER,
   table_name       VARCHAR2(50),
   transaction_type VARCHAR2(10), -- INSERT, UPDATE, DELETE
   transaction_time DATE DEFAULT SYSDATE,
   details          VARCHAR2(4000),
   CONSTRAINT pk_transaction_logs PRIMARY KEY ( log_id )
);

CREATE SEQUENCE seq_logs_id START WITH 1 INCREMENT BY 1;

-- INDEXES (Requirement #3)
-- Redundant: Unique constraint pk/uq already creates index
-- CREATE INDEX idx_users_username ON
--    users (
--       username
--    );
CREATE INDEX idx_posts_subforum ON
   posts (
      subforum_id
   );
CREATE INDEX idx_posts_user ON
   posts (
      user_id
   );
CREATE INDEX idx_comments_post ON
   comments (
      post_id
   );
CREATE INDEX idx_messages_receiver ON
   messages (
      receiver_id
   );