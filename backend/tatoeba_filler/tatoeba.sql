-- drop table if exists tatoeba_word_to_sentence cascade;
-- drop table if exists tatoeba_sentence cascade;
-- drop table if exists tatoeba_sentence_pairs cascade;

-- drop index if exists tatoeba_sentence_pairs_idx_1;
-- drop index if exists tatoeba_sentence_pairs_idx_2;
-- drop index if exists tatoeba_word_to_sentence_word_pos_idx;
-- drop index if exists tatoeba_sentence_language_idx;

create table if not exists tatoeba_sentence (
    sentence_id int primary key,
    sentence text not null,
    language text not null
);

create table if not exists tatoeba_word_to_sentence (
    word text not null,
    sentence_id int not null,
    pos text not null,
    primary key (word, pos, sentence_id),
    foreign key (sentence_id) references tatoeba_sentence (sentence_id) on delete cascade
);

/*
-- add foreign key constraint after table creation to sentence_id
alter table tatoeba_word_to_sentence add constraint tatoeba_word_to_sentence_sentence_id_fkey
    foreign key (sentence_id) references tatoeba_sentence (sentence_id) on delete cascade;
 */

create table if not exists tatoeba_sentence_pairs (
    first_id int not null,
    second_id int not null,
    primary key (first_id, second_id),
    foreign key (first_id) references tatoeba_sentence (sentence_id) on delete cascade,
    foreign key (second_id) references tatoeba_sentence (sentence_id) on delete cascade
);

drop table if exists tatoeba_last_sentence_id;
create table if not exists tatoeba_last_sentence_id (
    language text primary key not null,
    last_sentence_id int default 0
);

insert into tatoeba_last_sentence_id (language) values ('eng');
insert into tatoeba_last_sentence_id (language) values ('deu');
insert into tatoeba_last_sentence_id (language) values ('fra');
insert into tatoeba_last_sentence_id (language) values ('spa');
insert into tatoeba_last_sentence_id (language) values ('ita');
insert into tatoeba_last_sentence_id (language) values ('rus');
insert into tatoeba_last_sentence_id (language) values ('jpn');
insert into tatoeba_last_sentence_id (language) values ('kor');
insert into tatoeba_last_sentence_id (language) values ('por');
insert into tatoeba_last_sentence_id (language) values ('tur');
insert into tatoeba_last_sentence_id (language) values ('pol');


create index if not exists tatoeba_word_to_sentence_word_pos_idx on tatoeba_word_to_sentence (word, pos);
create index if not exists tatoeba_sentence_pairs_idx_1 on tatoeba_sentence_pairs (first_id);
create index if not exists tatoeba_sentence_pairs_idx_2 on tatoeba_sentence_pairs (second_id);
create index if not exists tatoeba_sentence_language_idx on tatoeba_sentence (language);