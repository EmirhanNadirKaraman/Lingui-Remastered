/*
drop index if exists fuzzy_word_search_index_gin;
drop index if exists wts_sentence_id_index;
drop index if exists sentence_video_id_idx;
drop index if exists video_idx;
drop index if exists video_idx_video_id;
drop index if exists word_strength_idx;
drop index if exists user_learned_language_cognito;
drop index if exists user_grammar_cognito;
drop index if exists grammar_rule_language_idx;

*/

/*
drop sequence if exists sentence_id_seq cascade;
drop sequence if exists video_id_seq cascade;

drop table if exists sentence_to_grammar_rule cascade;
drop table if exists video cascade;
drop table if exists sentence cascade;
drop table if exists word_to_sentence cascade;
drop table if exists word_table cascade;
drop table if exists processed_channel cascade;
drop table if exists grammar_rule cascade;
drop table if exists processed_channel cascade;

 */

/*
drop table if exists user_table cascade;
drop table if exists user_grammar cascade;
drop table if exists user_learned_language cascade;
drop table if exists word_strength cascade;
drop table if exists user_stat_table cascade;

 */

create sequence if not exists sentence_id_seq;
create sequence if not exists video_id_seq;

CREATE TABLE IF NOT EXISTS processed_channel (
    channel_id TEXT PRIMARY KEY,
    channel_name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS user_table (
    uid TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    current_language TEXT DEFAULT '',
    email TEXT NOT NULL,
    photo TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS video (
    video_id TEXT DEFAULT nextval('video_id_seq') PRIMARY KEY,
    title TEXT NOT NULL,
    thumbnail_url TEXT NOT NULL,
    duration FLOAT8 NOT NULL,
    language TEXT NOT NULL,
    dialect TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'other'
);

CREATE TABLE IF NOT EXISTS sentence (
    sentence_id INT DEFAULT nextval('sentence_id_seq') PRIMARY KEY,
    video_id TEXT NOT NULL,
    start_time FLOAT8 NOT NULL,
    duration FLOAT8 NOT NULL,
    content TEXT NOT NULL,
    tokens TEXT[] NOT NULL,
    token_ids INT[],
    CONSTRAINT fk_sentence_video FOREIGN KEY (video_id) REFERENCES video (video_id) ON DELETE CASCADE
);

ALTER TABLE sentence ADD COLUMN IF NOT EXISTS token_ids INT[];

CREATE TABLE IF NOT EXISTS word_table (
    word_id SERIAL PRIMARY KEY,
    word TEXT NOT NULL,
    language TEXT NOT NULL,
    pos TEXT NOT NULL,
    tag TEXT NOT NULL,
    lemma TEXT NOT NULL,
    UNIQUE (word, language, pos)
);

CREATE TABLE IF NOT EXISTS word_strength (
    uid TEXT NOT NULL,
    word_id INT NOT NULL,
    due_date TIMESTAMP NOT NULL,
    strength INT DEFAULT 1,
    PRIMARY KEY (uid, word_id),
    CONSTRAINT fk_word_strength_user FOREIGN KEY (uid) REFERENCES user_table (uid) ON DELETE CASCADE,
    CONSTRAINT fk_word_strength_word FOREIGN KEY (word_id) REFERENCES word_table (word_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS word_to_sentence (
    word_id INT NOT NULL,
    sentence_id INT DEFAULT currval('sentence_id_seq'),
    PRIMARY KEY (word_id, sentence_id),
    CONSTRAINT fk_word_to_sentence_word FOREIGN KEY (word_id) REFERENCES word_table (word_id) ON DELETE CASCADE,
    CONSTRAINT fk_word_to_sentence_sentence FOREIGN KEY (sentence_id) REFERENCES sentence (sentence_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS processed_channel (
    channel_id TEXT PRIMARY KEY,
    channel_name TEXT NOT NULL
);

-- GRAMMAR RULE TABLE
CREATE TABLE IF NOT EXISTS grammar_rule (
    rule_id SERIAL PRIMARY KEY,
    rule TEXT NOT NULL,
    language TEXT NOT NULL,
    UNIQUE (rule, language)
);

-- SENTENCE TO GRAMMAR RULE TABLE
CREATE TABLE IF NOT EXISTS sentence_to_grammar_rule (
    sentence_id INT NOT NULL,
    rule_id INT NOT NULL,
    PRIMARY KEY (sentence_id, rule_id),
    CONSTRAINT fk_sentence_to_sentence_type_sentence FOREIGN KEY (sentence_id) REFERENCES sentence (sentence_id) ON DELETE CASCADE,
    CONSTRAINT fk_sentence_to_sentence_type_type FOREIGN KEY (rule_id) REFERENCES grammar_rule (rule_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_learned_language (
    uid TEXT NOT NULL,
    learned_language TEXT NOT NULL,
    CONSTRAINT fk_user_learned_languages_user FOREIGN KEY (uid) REFERENCES user_table (uid) ON DELETE CASCADE,
    PRIMARY KEY (uid, learned_language)
);

CREATE TABLE IF NOT EXISTS user_grammar (
    uid TEXT NOT NULL,
    rule_id INT NOT NULL,
    CONSTRAINT fk_user_grammar_user FOREIGN KEY (uid) REFERENCES user_table (uid) ON DELETE CASCADE,
    CONSTRAINT fk_user_grammar_sentence_type FOREIGN KEY (rule_id) REFERENCES grammar_rule (rule_id) ON DELETE CASCADE,
    PRIMARY KEY (uid, rule_id)
);

CREATE TABLE IF NOT EXISTS user_stat_table (
    uid TEXT NOT NULL,
    language TEXT NOT NULL,
    total_time INT DEFAULT 0,
    shown_sentence_count INT DEFAULT 0,
    cloze_count INT DEFAULT 0,
    PRIMARY KEY (uid, language),
    CONSTRAINT fk_user_time_table_user FOREIGN KEY (uid) REFERENCES user_table (uid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS leaderboard (
    uid TEXT NOT NULL,
    language TEXT NOT NULL,
    score INT DEFAULT 0,
    PRIMARY KEY (uid, language),
    CONSTRAINT fk_leaderboard_user FOREIGN KEY (uid) REFERENCES user_table (uid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_video_category (
    uid TEXT NOT NULL,
    video_category TEXT NOT NULL,
    PRIMARY KEY (uid, video_category),
    CONSTRAINT fk_user_categories_user FOREIGN KEY (uid) REFERENCES user_table (uid) ON DELETE CASCADE
);


create index if not exists leaderboard_score_idx on leaderboard using btree (score desc);

create index if not exists fuzzy_word_search_index_gin on word_table
using gin(word gin_trgm_ops);

CREATE INDEX IF NOT EXISTS wts_sentence_id_index ON word_to_sentence(sentence_id);
CREATE INDEX IF NOT EXISTS sentence_video_id_idx ON sentence (video_id);
CREATE INDEX IF NOT EXISTS video_idx ON video (video_id, language);
CREATE INDEX IF NOT EXISTS video_idx_video_id ON video (video_id);
-- CREATE INDEX IF NOT EXISTS word_strength_idx ON word_strength (uid, language, strength);

CREATE INDEX IF NOT EXISTS word_table_language_idx ON word_table (language);

CREATE INDEX IF NOT EXISTS user_learned_language_cognito ON user_learned_language (uid);
CREATE INDEX IF NOT EXISTS user_grammar_cognito ON user_grammar (uid);

CREATE INDEX IF NOT EXISTS grammar_rule_language_idx ON grammar_rule (language);
CREATE INDEX IF NOT EXISTS word_strength_uid_strength_idx ON word_strength (uid, strength);
CREATE INDEX IF NOT EXISTS word_table_word_id_idx ON word_table (word_id);


explain analyze
with user_words as (
    select word_id
    from word_strength
    where uid = 'dEuxpbW6yifo0Ca1X2DDh3y53XO2' and strength = 8
)

select distinct on (V.video_id) row_to_json(S), row_to_json(V), row_to_json(WT)
from sentence S, video V, user_video_category UVC, word_table WT
where
    (select count(*)
        from (
            (select word_id
            from word_to_sentence WTS
            where WTS.sentence_id = S.sentence_id)
            except
            (select word_id
            from user_words)) as unknown_words
    ) = 1 and
    WT.word_id = (select word_id
        from (
            (select word_id
            from word_to_sentence WTS
            where WTS.sentence_id = S.sentence_id)
            except
            (select word_id
            from user_words)) as unknown_words
    ) and
    S.video_id = V.video_id and
    V.language = 'en' and
    S.content ~ '^.*$' and
    length(S.content) > 1 and
    UVC.video_category = V.category and
    UVC.uid = 'dEuxpbW6yifo0Ca1X2DDh3y53XO2'
OFFSET ((1 - 1) * 10) ROWS
LIMIT 10;

create table if not exists language_table (
    language text not null,
    iso_code char(3) not null,
    regex text default '^[A-Z](.*)[!?.]$',
    is_learnable boolean not null default true,
    is_interface_language boolean not null default false,
    primary key (language)
);

/*
-- languages with latin script, no interface language support for now
insert into language_table (language, iso_code) values ('de', 'deu');
insert into language_table (language, iso_code) values ('fr', 'fra');
insert into language_table (language, iso_code) values ('es', 'spa');
insert into language_table (language, iso_code) values ('it', 'ita');
insert into language_table (language, iso_code) values ('pt', 'por');
insert into language_table (language, iso_code) values ('pl', 'pol');
insert into language_table (language, iso_code) values ('sv', 'swe');

-- languages with a different script, same punctuation system
insert into language_table (language, iso_code, regex) values ('ru', 'rus', '^[А-Я](.*)[!?.]$');

-- languages with a different script or punctuation system
insert into language_table (language, iso_code, regex) values ('ja', 'jpn', '^.*$');
insert into language_table (language, iso_code, regex) values ('ko', 'kor', '^.*$');

-- languages that are
insert into language_table (language, iso_code, regex, is_interface_language)
values ('en', 'eng', '^[A-Z](.*)[!?.]$', true);

insert into language_table (language, iso_code, regex, is_learnable, is_interface_language)
values ('tr', 'tur', null, false, true);
*/

create table if not exists video_category (
    category text not null,
    language text not null,
    CONSTRAINT fk_category_language_idx FOREIGN KEY (language) REFERENCES language_table (language) ON DELETE CASCADE,
    primary key (category)
);

create table if not exists most_frequent_words (
    word_id int not null,
    constraint fk_most_frequent_words_word_id FOREIGN KEY (word_id) REFERENCES word_table (word_id) ON DELETE CASCADE,
    primary key (word_id)
);

CREATE INDEX IF NOT EXISTS idx_sentence_start_time ON sentence (start_time);

explain analyze
with user_words as (
        select word_id
        from word_strength
        where uid = 'RSPs54wB4rYWczxfAlFv4xrJrVY2' and strength = 8
    ),

    suggestions as (
        select distinct on (V.video_id) row_to_json(S), row_to_json(V), row_to_json(WT)
        from sentence S, video V, user_video_category UVC, word_table WT
        where
            (select count(*)
                from (
                    (select word_id
                    from word_to_sentence WTS
                    where WTS.sentence_id = S.sentence_id)
                    except
                    (select word_id
                    from user_words)) as unknown_words
            ) = 1 and
            (select word_id
                from (
                    (select word_id
                    from word_to_sentence WTS
                    where WTS.sentence_id = S.sentence_id)
                    except
                    (select word_id
                    from user_words)) as unknown_words
            ) = WT.word_id and
            S.video_id = V.video_id and
            V.language = 'en' and
            S.content ~ '^[A-Z].*(.?!)$' and
            length(S.content) > 1 and
            UVC.video_category = V.category and
            UVC.uid = 'RSPs54wB4rYWczxfAlFv4xrJrVY2')

    select *
    from suggestions
    -- order by random()
    limit 10
