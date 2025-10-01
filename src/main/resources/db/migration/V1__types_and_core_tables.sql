-- V1__types_and_core_tables.sql
-- 1) create enum types
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'role_t') THEN
CREATE TYPE role_t AS ENUM ('QLY','NDUNG','CTV');
END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status_t') THEN
CREATE TYPE user_status_t AS ENUM ('ACTIVE','DEACTIVE');
END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'post_status_t') THEN
CREATE TYPE post_status_t AS ENUM ('DRAFT','REJECTED','PUBLISHED','DELETED');
END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'comment_status_t') THEN
CREATE TYPE comment_status_t AS ENUM ('REJECTED','PUBLISHED','DELETED');
END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'interact_type_t') THEN
CREATE TYPE interact_type_t AS ENUM ('LIKE','DISLIKE');
END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_status_t') THEN
CREATE TYPE notification_status_t AS ENUM ('UNREAD','READ','DELETED');
END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'activity_type_t') THEN
CREATE TYPE activity_type_t AS ENUM ('SUCCESS','FAILED','CANCELLED');
END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'test_label_t') THEN
CREATE TYPE test_label_t AS ENUM ('FLYER','VSTEP');
END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vocab_level_t') THEN
CREATE TYPE vocab_level_t AS ENUM ('A1','A2','B1','B2','C1','C2');
END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vocab_label_t') THEN
CREATE TYPE vocab_label_t AS ENUM ('FLYER','VSTEP');
END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'grammar_label_t') THEN
CREATE TYPE grammar_label_t AS ENUM ('FLYER','VSTEP');
END IF;
END$$;


-- 2) core tables (order respects FK dependencies)

-- USERS
CREATE TABLE IF NOT EXISTS users
(
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username       VARCHAR(255) UNIQUE NOT NULL,
    email          VARCHAR(255) UNIQUE NOT NULL,
    password       VARCHAR(1000)       NOT NULL,
    phone          VARCHAR(11) UNIQUE,
    salt           VARCHAR(50),
    gg_id          VARCHAR(255) UNIQUE,
    fb_id          VARCHAR(255) UNIQUE,
    streak         INTEGER   DEFAULT 0,
    longest_streak INTEGER   DEFAULT 0,
    last_login     TIMESTAMP,
    role           role_t,
    status         user_status_t,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP
    );

-- TOPIC (for posts)
CREATE TABLE IF NOT EXISTS topic
(
    id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
    );

-- TOPIC_VOCABULARY
CREATE TABLE IF NOT EXISTS topic_vocabulary
(
    id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL
    );

-- VOCABULARY (main) references topic_vocabulary
CREATE TABLE IF NOT EXISTS vocabulary
(
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    part_of_speech VARCHAR(10)  NOT NULL,
    ipa            VARCHAR(50)  NOT NULL,
    word           VARCHAR(255) NOT NULL,
    meaning        VARCHAR(255) NOT NULL,
    definition     TEXT         NOT NULL,
    example        TEXT,
    vocab_level    vocab_level_t,
    vocab_label    vocab_label_t,
    topic_id       INTEGER      NOT NULL,
    CONSTRAINT fk_vocab_topic FOREIGN KEY (topic_id) REFERENCES topic_vocabulary (id)
    );

-- GRAMMAR
CREATE TABLE IF NOT EXISTS grammar
(
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    content       TEXT         NOT NULL,
    example       TEXT,
    grammar_label grammar_label_t
    );

-- PRONUNCIATION (self reference allowed)
CREATE TABLE IF NOT EXISTS pronunciation
(
    id              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    audio_link      VARCHAR(255) NOT NULL,
    video_link      VARCHAR(255),
    ipa             VARCHAR(50),
    explanation     TEXT,
    confusion_ipa   INTEGER,
    differentiation TEXT,
    example         TEXT,
    CONSTRAINT fk_pron_confusion FOREIGN KEY (confusion_ipa) REFERENCES pronunciation (id)
    );

-- TEST (exam)
CREATE TABLE IF NOT EXISTS test
(
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name          VARCHAR(255),
    attempt_count INTEGER DEFAULT 0,
    test_label    test_label_t
    );

-- QUESTION_TOPIC
CREATE TABLE IF NOT EXISTS question_topic
(
    id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL
    );

-- POST (references topic, users)
CREATE TABLE IF NOT EXISTS post
(
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    content       TEXT    NOT NULL,
    topic_id      INTEGER NOT NULL,
    author_id     INTEGER NOT NULL,
    status        post_status_t,
    like_count    INTEGER   DEFAULT 0,
    comment_count INTEGER   DEFAULT 0,
    view_count    INTEGER   DEFAULT 0,
    slug          VARCHAR(255),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP,
    CONSTRAINT fk_post_topic FOREIGN KEY (topic_id) REFERENCES topic (id),
    CONSTRAINT fk_post_author FOREIGN KEY (author_id) REFERENCES users (id)
    );

-- USER_COMMENT (self ref)
CREATE TABLE IF NOT EXISTS user_comment
(
    id                INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id         INTEGER NOT NULL,
    post_id           INTEGER NOT NULL,
    parent_comment_id INTEGER,
    like_count        INTEGER DEFAULT 0,
    dislike_count     INTEGER DEFAULT 0,
    content           TEXT    NOT NULL,
    status            comment_status_t,
    CONSTRAINT fk_comment_author FOREIGN KEY (author_id) REFERENCES users (id),
    CONSTRAINT fk_comment_post FOREIGN KEY (post_id) REFERENCES post (id),
    CONSTRAINT fk_comment_parent FOREIGN KEY (parent_comment_id) REFERENCES user_comment (id)
    );

-- HISTORY_COMMENT
CREATE TABLE IF NOT EXISTS history_comment
(
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    content        TEXT      NOT NULL,
    updated_at     TIMESTAMP NOT NULL,
    new_comment_id INTEGER   NOT NULL,
    CONSTRAINT fk_history_com_new_comment FOREIGN KEY (new_comment_id) REFERENCES user_comment (id)
    );

-- INTERACT_COMMENT_USERS
CREATE TABLE IF NOT EXISTS interact_comment_users
(
    comment_id INTEGER NOT NULL,
    user_id    INTEGER NOT NULL,
    type       interact_type_t,
    CONSTRAINT pk_interact_comment PRIMARY KEY (comment_id, user_id),
    CONSTRAINT fk_interact_comment_comment FOREIGN KEY (comment_id) REFERENCES user_comment (id),
    CONSTRAINT fk_interact_comment_user FOREIGN KEY (user_id) REFERENCES users (id)
    );

-- INTERACT_POST_USERS
CREATE TABLE IF NOT EXISTS interact_post_users
(
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    type    interact_type_t,
    CONSTRAINT pk_interact_post PRIMARY KEY (post_id, user_id),
    CONSTRAINT fk_interact_post_post FOREIGN KEY (post_id) REFERENCES post (id),
    CONSTRAINT fk_interact_post_user FOREIGN KEY (user_id) REFERENCES users (id)
    );

-- NOTIFICATION
CREATE TABLE IF NOT EXISTS notification
(
    id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id    INTEGER NOT NULL,
    sender_id  INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    title      VARCHAR(255),
    message    TEXT,
    url        VARCHAR(255),
    type       VARCHAR(100),
    status     notification_status_t,
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_notification_sender FOREIGN KEY (sender_id) REFERENCES users (id)
    );

-- ACTIVITY_HISTORY
CREATE TABLE IF NOT EXISTS activity_history
(
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id       INTEGER NOT NULL,
    activity_type activity_type_t,
    url           VARCHAR(255),
    title         VARCHAR(255),
    message       TEXT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_activity_user FOREIGN KEY (user_id) REFERENCES users (id)
    );

-- POLICY
CREATE TABLE IF NOT EXISTS policy
(
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    content     TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP,
    policy_type VARCHAR(255)
    );
