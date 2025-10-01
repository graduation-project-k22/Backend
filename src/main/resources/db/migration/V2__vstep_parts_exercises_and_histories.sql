-- V2__vstep_parts_exercises_and_histories.sql

-- VSTEP_PART (references test)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'part_skill_t') THEN
CREATE TYPE part_skill_t AS ENUM ('S','L','R','W');
END IF;
END$$;

CREATE TABLE IF NOT EXISTS vstep_part
(
    id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    part             VARCHAR(10),
    duration_minutes INTEGER NOT NULL,
    name             VARCHAR(255),
    attempt_count    INTEGER DEFAULT 0,
    skill            part_skill_t,
    test_id          INTEGER,
    CONSTRAINT fk_part_test FOREIGN KEY (test_id) REFERENCES test (id)
    );

-- Speaking/Writing/Reading/Listening parts (id references vstep_part.id)
CREATE TABLE IF NOT EXISTS speaking_vstep_part
(
    id                INTEGER PRIMARY KEY,
    name              VARCHAR(255),
    description       TEXT,
    audio_sample      VARCHAR(255),
    transcript_sample TEXT,
    topic_id          INTEGER NOT NULL,
    CONSTRAINT fk_speak_part_vstep FOREIGN KEY (id) REFERENCES vstep_part (id),
    CONSTRAINT fk_speak_part_topic FOREIGN KEY (topic_id) REFERENCES question_topic (id)
    );

CREATE TABLE IF NOT EXISTS writing_vstep_part
(
    id          INTEGER PRIMARY KEY,
    description TEXT,
    sample      TEXT,
    topic_id    INTEGER NOT NULL,
    CONSTRAINT fk_write_part_vstep FOREIGN KEY (id) REFERENCES vstep_part (id),
    CONSTRAINT fk_write_part_topic FOREIGN KEY (topic_id) REFERENCES question_topic (id)
    );

CREATE TABLE IF NOT EXISTS reading_vstep_part
(
    id      INTEGER PRIMARY KEY,
    topic   VARCHAR(255) NOT NULL,
    passage TEXT         NOT NULL,
    CONSTRAINT fk_read_part_vstep FOREIGN KEY (id) REFERENCES vstep_part (id)
    );

CREATE TABLE IF NOT EXISTS listening_vstep_part
(
    id         INTEGER PRIMARY KEY,
    audio_link VARCHAR(255),
    transcript TEXT,
    topic1     VARCHAR(255),
    topic2     VARCHAR(255),
    topic3     VARCHAR(255),
    CONSTRAINT fk_listen_part_vstep FOREIGN KEY (id) REFERENCES vstep_part (id)
    );

-- MCQ
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'mcq_answer_t') THEN
CREATE TYPE mcq_answer_t AS ENUM ('A','B','C','D');
END IF;
END$$;

CREATE TABLE IF NOT EXISTS mcq
(
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question       TEXT          NOT NULL,
    answerA        VARCHAR(1000) NOT NULL,
    answerB        VARCHAR(1000) NOT NULL,
    answerC        VARCHAR(1000) NOT NULL,
    answerD        VARCHAR(1000) NOT NULL,
    correct_answer mcq_answer_t,
    explanation    TEXT,
    no             INTEGER       NOT NULL,
    topic_id       INTEGER,
    part_id        INTEGER       NOT NULL,
    CONSTRAINT fk_mcq_topic FOREIGN KEY (topic_id) REFERENCES question_topic (id),
    CONSTRAINT fk_mcq_part FOREIGN KEY (part_id) REFERENCES vstep_part (id)
    );

-- VSTEP_PART_HISTORY
CREATE TABLE IF NOT EXISTS vstep_part_history
(
    id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    start_time TIMESTAMP,
    end_time   TIMESTAMP,
    score      NUMERIC,
    status     VARCHAR(10),
    user_id    INTEGER,
    part_id    INTEGER,
    CONSTRAINT fk_vph_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_vph_part FOREIGN KEY (part_id) REFERENCES vstep_part (id)
    );

-- USER_ANSWER
CREATE TABLE IF NOT EXISTS user_answer
(
    id              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    answer          TEXT,
    part_history_id INTEGER NOT NULL,
    CONSTRAINT fk_user_answer_part_history FOREIGN KEY (part_history_id) REFERENCES vstep_part_history (id)
    );

-- FULL_TEST_HISTORY
CREATE TABLE IF NOT EXISTS full_test_history
(
    id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    start_time TIMESTAMP,
    end_time   TIMESTAMP,
    score      NUMERIC,
    status     VARCHAR(10),
    user_id    INTEGER,
    test_id    INTEGER,
    CONSTRAINT fk_fth_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_fth_test FOREIGN KEY (test_id) REFERENCES test (id)
    );

-- GRAMMAR_EXERCISE
CREATE TABLE IF NOT EXISTS grammar_exercise
(
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question      TEXT,
    answer        TEXT,
    explanation   TEXT,
    question_type VARCHAR(20),
    grammar_id    INTEGER NOT NULL,
    CONSTRAINT fk_grammar_ex_grammar FOREIGN KEY (grammar_id) REFERENCES grammar (id)
    );

-- PRONUNCIATION_EXERCISE
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'pron_ex_type_t') THEN
CREATE TYPE pron_ex_type_t AS ENUM ('WORD','SENTENCE','PARAGRAPH');

END IF;
END$$;

CREATE TABLE IF NOT EXISTS pronunciation_exercise
(
    id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question         TEXT,
    audio_link       VARCHAR(255),
    ipa              VARCHAR(50),
    meaning          TEXT,
    type             pron_ex_type_t,
    pronunciation_id INTEGER NOT NULL,
    CONSTRAINT fk_pron_ex_pron FOREIGN KEY (pronunciation_id) REFERENCES pronunciation (id)
    );

-- LISTENING_EXERCISE
CREATE TABLE IF NOT EXISTS listening_exercise
(
    id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    audio_link VARCHAR(255),
    transcript TEXT,
    question1  TEXT,
    answer1    TEXT,
    question2  TEXT,
    answer2    TEXT,
    question3  TEXT,
    answer3    TEXT
    );

-- LISTENING_EXERCISE_HISTORY
CREATE TABLE IF NOT EXISTS listening_exercise_history
(
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    learner_id  INTEGER   NOT NULL,
    learn_time  TIMESTAMP NOT NULL,
    review_time TIMESTAMP,
    status      VARCHAR(255),
    CONSTRAINT fk_listen_ex_hist_user FOREIGN KEY (learner_id) REFERENCES users (id)
    );

-- GRAMMAR_EXERCISE_HISTORY
CREATE TABLE IF NOT EXISTS grammar_exercise_history
(
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    learner_id  INTEGER   NOT NULL,
    learn_time  TIMESTAMP NOT NULL,
    review_time TIMESTAMP,
    status      VARCHAR(255),
    hist_type   VARCHAR(2),
    grammar_id  INTEGER,
    CONSTRAINT fk_gram_ex_hist_user FOREIGN KEY (learner_id) REFERENCES users (id),
    CONSTRAINT fk_gram_ex_hist_grammar FOREIGN KEY (grammar_id) REFERENCES grammar (id)
    );

-- PRONUNCIATION_EXERCISE_HISTORY
CREATE TABLE IF NOT EXISTS pronunciation_exercise_history
(
    id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    learner_id       INTEGER   NOT NULL,
    learn_time       TIMESTAMP NOT NULL,
    review_time      TIMESTAMP,
    status           VARCHAR(255),
    pr_ex_type       VARCHAR(2),
    pronunciation_id INTEGER,
    CONSTRAINT fk_pron_ex_hist_user FOREIGN KEY (learner_id) REFERENCES users (id),
    CONSTRAINT fk_pron_ex_hist_pron FOREIGN KEY (pronunciation_id) REFERENCES pronunciation (id)
    );

-- VOCABULARY_NOTEBOOK
CREATE TABLE IF NOT EXISTS vocabulary_notebook
(
    id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    part_of_speech   VARCHAR(10)  NOT NULL,
    ipa              VARCHAR(50)  NOT NULL,
    word             VARCHAR(255) NOT NULL,
    meaning          TEXT         NOT NULL,
    definition       TEXT         NOT NULL,
    example          TEXT,
    vocab_note_level vocab_level_t,
    vocab_note_label vocab_label_t,
    topic_id         INTEGER      NOT NULL,
    learn_time       TIMESTAMP    NOT NULL,
    review_time      TIMESTAMP    NOT NULL,
    status           VARCHAR(100),
    owner_id         INTEGER      NOT NULL,
    CONSTRAINT fk_vn_topic FOREIGN KEY (topic_id) REFERENCES topic_vocabulary (id),
    CONSTRAINT fk_vn_owner FOREIGN KEY (owner_id) REFERENCES users (id)
    );

-- GRAMMAR_NOTEBOOK
CREATE TABLE IF NOT EXISTS grammar_notebook
(
    id                 INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name               VARCHAR(255) NOT NULL,
    content            TEXT         NOT NULL,
    example            TEXT,
    grammar_note_label grammar_label_t,
    learn_time         TIMESTAMP    NOT NULL,
    review_time        TIMESTAMP    NOT NULL,
    status             VARCHAR(100),
    owner_id           INTEGER      NOT NULL,
    CONSTRAINT fk_gn_owner FOREIGN KEY (owner_id) REFERENCES users (id)
    );

-- LEARN VOCABULARY/GRAMMAR/PRONUNCIATION HISTORY
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'learn_type_t') THEN
CREATE TYPE learn_type_t AS ENUM ('V','G','P');
END IF;
END$$;

CREATE TABLE IF NOT EXISTS learn_vocabulary_history
(
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    learner_id    INTEGER   NOT NULL,
    learn_time    TIMESTAMP NOT NULL,
    review_time   TIMESTAMP,
    status        VARCHAR(255),
    learn_type    learn_type_t,
    vocabulary_id INTEGER,
    CONSTRAINT fk_lv_user FOREIGN KEY (learner_id) REFERENCES users (id),
    CONSTRAINT fk_lv_vocab FOREIGN KEY (vocabulary_id) REFERENCES vocabulary (id)
    );

CREATE TABLE IF NOT EXISTS learn_grammar_history
(
    id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    learner_id   INTEGER   NOT NULL,
    learn_time   TIMESTAMP NOT NULL,
    review_time  TIMESTAMP,
    status       VARCHAR(255),
    learn_g_type learn_type_t,
    grammar_id   INTEGER,
    CONSTRAINT fk_lg_user FOREIGN KEY (learner_id) REFERENCES users (id),
    CONSTRAINT fk_lg_grammar FOREIGN KEY (grammar_id) REFERENCES grammar (id)
    );

CREATE TABLE IF NOT EXISTS learn_pronunciation_history
(
    id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    learner_id       INTEGER   NOT NULL,
    learn_time       TIMESTAMP NOT NULL,
    review_time      TIMESTAMP,
    status           VARCHAR(255),
    learn_p_type     learn_type_t,
    pronunciation_id INTEGER,
    CONSTRAINT fk_lp_user FOREIGN KEY (learner_id) REFERENCES users (id),
    CONSTRAINT fk_lp_pron FOREIGN KEY (pronunciation_id) REFERENCES pronunciation (id)
    );
