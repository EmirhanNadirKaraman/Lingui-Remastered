"""

sentence table = original_lang, target_lang, sentence, translation


query(word, language, part of speech)

query('leaves', 'en', 'verb')

word_to_sentence table:   word, sentence_id, pos
sentence table:           sentence_id, sentence
sentence_pairs table:     original_sentence_id, translation_sentence_id
word table:               word_id, word, pos
"""

import json
import os
from functools import wraps

import psycopg2
import spacy
from flask import jsonify, app
from psycopg2 import errorcodes

import config

config.set_values()

# LANGUAGES = ['eng', 'deu', 'fra', 'spa', 'ita', 'por', 'jpn', 'rus', 'kor', 'tur', 'pol', 'swe']
LANGUAGES = ['eng', 'deu', 'fra', 'ita', 'spa', 'por']


def connect():
    conn = psycopg2.connect(
        host=os.getenv('URL'),
        database=os.getenv('DATABASE_NAME'),
        user=os.getenv('USERNAME'),
        password=os.getenv('PASSWORD')
    )

    return conn


def load_model(language):
    lang_model_map = {
        "eng": "en_core_web_sm",
        "deu": "de_core_news_sm",
        "fra": "fr_core_news_sm",
        "spa": "es_core_news_sm",
        "ita": "it_core_news_sm",
        "por": "pt_core_news_sm",
        "jpn": "ja_core_news_sm",
        "rus": "ru_core_news_sm",
        "kor": "ko_core_news_sm",
        "pol": "pl_core_news_sm",
        "swe": "sv_core_news_sm"
    }

    if language not in lang_model_map:
        raise ValueError("Language not supported")

    return spacy.load(lang_model_map[language])


def err_handling_decorator(function):
    @wraps(function)
    def wrapper(*args, **kwargs):
        try:
            return function(*args, **kwargs)
        except psycopg2.Error as e:
            cursor.execute("ROLLBACK")
            return jsonify({'success': False, 'error': errorcodes.lookup(e.pgcode)}), 400

        # Renaming the function name:

    wrapper.__name__ = function.__name__
    return wrapper


connection = connect()
cursor = connection.cursor()


@err_handling_decorator
def fill_tatoeba_sentence(languages):
    # read the sentences from the sentences.csv file
    with open('good_sentences.csv', 'r') as f:
        sentences = f.readlines()

        count = 0

        tup = []

        for sentence in sentences:
            # remove the newline character, and split the sentence into its components
            sentence = sentence.split('\t')
            sentence[2] = sentence[2][:-1]

            if sentence[1] not in languages:
                continue

            count += 1

            sentence_id = int(sentence[0])
            language = sentence[1]
            sentence_text = sentence[2]

            tup.append((sentence_id, sentence_text, language))

            print(count, sentence_id, sentence_text, language)

            if count % 10000 == 0:
                # insert all sentences in bulk
                arg_str = b','.join(cursor.mogrify("(%s,%s,%s)", x) for x in tup)

                if arg_str != b'':
                    cursor.execute(
                        b"INSERT INTO tatoeba_sentence (sentence_id, sentence, language) VALUES " + arg_str
                        + b" ON CONFLICT DO NOTHING")

                connection.commit()
                tup = []

        arg_str = b','.join(cursor.mogrify("(%s,%s,%s)", x) for x in tup)
        if arg_str != b'':
            cursor.execute(
                b"INSERT INTO tatoeba_sentence (sentence_id, sentence, language) VALUES "
                + arg_str + b" ON CONFLICT DO NOTHING")
        connection.commit()

    print("fill tatoeba sentence done")


# @err_handling_decorator
def fill_word_to_sentence_table(language):
    """
    create table if not exists tatoeba_word_to_sentence (
    word varchar(255) not null,
    sentence_id int not null,
    pos varchar(255) not null,
    primary key (word, pos, sentence_id),
    foreign key (sentence_id) references tatoeba_sentence (sentence_id)
);
    """

    """
    1. get the id of the last sentence in the table
    2. ignore the sentences until that point
    3. now we are at a sentence that should be parsed.
        3.1. doc = nlp(sentence)
        3.2. using for token in doc, save each word, pos, sentence_id in the table.
    """

    cursor.execute("insert into tatoeba_last_sentence_id (language) values (%s) "
                   "on conflict do nothing", (language, ))
    connection.commit()

    while True:
        # find the id of the last sentence in the table in that language
        cursor.execute("select last_sentence_id "
                       "from tatoeba_last_sentence_id "
                       "where language = %s", (language,))

        last_sentence = cursor.fetchone()[0]

        print("last sentence = ", last_sentence)

        # find the next 10000 sentences in that language
        cursor.execute("select sentence_id, sentence, language "
                       "from tatoeba_sentence "
                       "where sentence_id > %s and "
                       "language = %s "
                       "order by sentence_id limit 10000", (last_sentence, language))

        sentences = cursor.fetchall()

        if len(sentences) == 0:
            print("fill word to sentence table done")
            return

        nlp = load_model(language)

        tup = []
        for index, sentence in enumerate(sentences):
            sentence_id = sentence[0]
            sentence_text = sentence[1]
            language = sentence[2]

            if index % 100 == 0:
                print(index, sentence_id, sentence_text, language)

            doc = nlp(sentence_text)

            for token in doc:
                if token.pos_ != 'PUNCT':
                    tup.append((token.text, sentence_id, token.pos_))

        arg_str = b','.join(cursor.mogrify("(%s,%s,%s)", x) for x in tup)

        if arg_str != b'':
            cursor.execute(
                b"insert into tatoeba_word_to_sentence (word, sentence_id, pos) " +
                b"values " + arg_str + b" on conflict do nothing")

            # update last_sentence info
            cursor.execute("update tatoeba_last_sentence_id "
                           "set last_sentence_id = %s "
                           "where language = %s", (tup[-1][1], language))

            connection.commit()


def fill_word_to_sentence_table_for_non_spacy_languages():
    while True:
        for language in ['tur']:
            # find the id of the last sentence in the table in that language
            cursor.execute("select last_sentence_id "
                           "from tatoeba_last_sentence_id "
                           "where language = %s", (language,))

            last_sentence = cursor.fetchone()[0]

            print("last sentence = ", last_sentence)

            # find the next 10000 sentences in that language
            cursor.execute("select sentence_id, sentence, language "
                           "from tatoeba_sentence "
                           "where sentence_id > %s and "
                           "language = %s "
                           "order by sentence_id limit 10000", (last_sentence, language))

            sentences = cursor.fetchall()

            tup = []
            for index, sentence in enumerate(sentences):
                sentence_id = sentence[0]
                sentence_text = sentence[1]
                language = sentence[2]

                if index % 100 == 0:
                    print(index, sentence_id, sentence_text, language)

                for word in sentence_text.split():
                    tup.append((word, sentence_id))

            arg_str = b','.join(cursor.mogrify("(%s,%s)", x) for x in tup)

            if arg_str != b'':
                cursor.execute(
                    b"insert into tatoeba_word_to_sentence (word, sentence_id) " +
                    b"values " + arg_str + b" on conflict do nothing")

                # update last_sentence info
                cursor.execute("update tatoeba_last_sentence_id "
                               "set last_sentence_id = %s "
                               "where language = %s", (tup[-1][1], language))

                connection.commit()


def fill_sentence_ids_table():
    """create table if not exists tatoeba_sentence_pairs (
    first_id int not null,
    second_id int not null,
    primary key (original_sentence_id, translation_sentence_id),
    foreign key (original_sentence_id) references tatoeba_sentence (sentence_id),
    foreign key (translation_sentence_id) references tatoeba_sentence (sentence_id)
);
    """

    """
    1. open the sentences_base.csv file
    2. for each line, get the sentence_id and the translation_id
    3. try to insert it
        3.1. the operation will fail if the sentence_id or the translation_id do not exist in the db anyway.
        3.2. so just ignore the error.
    """

    with open('good_sentence_ids.csv', 'r') as f:
        sentences = f.readlines()
        print(sentences)

        # find the last sentence pair that is in the db
        cursor.execute("select first_id, second_id "
                       "from tatoeba_sentence_pairs "
                       "order by first_id desc, second_id desc "
                       "limit 1")
        result = cursor.fetchone()
        if result is None:
            first_result = 0
            second_result = 0
        else:
            first_result, second_result = result

        sentences = [sentence[:-1] for sentence in sentences]
        sentences = [sentence.split('\t') for sentence in sentences]

        tup = []
        count = 0
        for sentence in sentences:
            first_id = sentence[0]
            second_id = sentence[1]

            # ignore the ones that are already parsed
            if int(first_id) < int(first_result) or \
                    (int(first_id) == int(first_result) and int(second_id) <= int(second_result)):
                continue

            tup.append((first_id, second_id))
            count += 1

            if count % 100 == 0:
                print(count, first_id, second_id)

            # every 10000 sentences, insert them in bulk
            if count % 10000 == 0:
                arg_str = b','.join(cursor.mogrify("(%s,%s)", x) for x in tup)

                if arg_str != b'':
                    cursor.execute(
                        b"insert into tatoeba_sentence_pairs (first_id, second_id) " +
                        b"values " + arg_str + b" on conflict do nothing")
                    connection.commit()
                    tup = []

        arg_str = b','.join(cursor.mogrify("(%s,%s)", x) for x in tup)

        if arg_str != b'':
            cursor.execute(
                b"insert into tatoeba_sentence_pairs (first_id, second_id) " +
                b"values " + arg_str + b" on conflict do nothing")
            connection.commit()


def create_sentences_json(languages):
    with open('sentences.csv', 'r') as f:
        sentences = f.readlines()

        sentences = [sentence[:-1] for sentence in sentences]
        sentences = [sentence.split('\t') for sentence in sentences]

        json_object = {}

        for index, sentence in enumerate(sentences):
            if index % 10000 == 0:
                print(index)

            sentence_id = sentence[0]
            language = sentence[1]
            text = sentence[2]

            if language not in languages:
                continue

            json_object[sentence_id] = {
                'sentence_id': sentence_id,
                'language': language,
                'text': text
            }

    # now write this to a json file, with special characters
    with open('sentences.json', 'w') as f:
        json.dump(json_object, f, ensure_ascii=False)

    print("create sentences json done")


def create_valid_sentences(languages):
    with open('good_sentences.csv', 'w+') as output_file:
        with open('sentences.csv', 'r') as csv:
            sentences = csv.readlines()

            index = 0

            for sentence in sentences:
                sentence = sentence[:-1]
                sentence = sentence.split('\t')

                if sentence[1] in languages:
                    output_file.write(sentence[0] + '\t' + sentence[1] + '\t' + sentence[2] + '\n')
                    index += 1

                    if index % 100 == 0:
                        print(index, sentence)

    print("create valid sentences done")


def create_valid_sentence_ids(languages):
    with open('good_sentence_ids.csv', 'w+') as output_file:
        with open('sentences_base.csv', 'r') as csv:
            with open('sentences.json', 'r') as json_:
                sentence_dict = json.load(json_)

                sentences = csv.readlines()

                sentences = [sentence[:-1] for sentence in sentences]
                sentences = [sentence.split('\t') for sentence in sentences]

                result = []
                for sentence in sentences:
                    if sentence[0] not in sentence_dict or sentence[1] not in sentence_dict:
                        continue

                    if sentence_dict[sentence[0]]['language'] in languages and \
                            sentence_dict[sentence[0]] != sentence_dict[sentence[1]]:
                        result.append(sentence)

                    elif sentence_dict[sentence[1]]['language'] in languages and \
                            sentence_dict[sentence[0]] != sentence_dict[sentence[1]]:
                        result.append(sentence)

                index = 0
                for pair in result:
                    output_file.write(pair[0] + '\t' + pair[1] + '\n')
                    index += 1

                    if index % 100 == 0:
                        print(index, pair)

    print("create valid sentence ids done")


def new_fill_sentence_ids_table():
    # read all sentence pairs from good_sentence_ids.csv
    with open('good_sentence_ids.csv', 'r') as f:
        sentences = f.readlines()
        print(sentences)

        sentences = [sentence[:-1] for sentence in sentences]
        sentences = [sentence.split('\t') for sentence in sentences]

        tup = []
        count = 0

        for sentence in sentences:
            first_id = sentence[0]
            second_id = sentence[1]

            tup.append((first_id, second_id))
            count += 1

            if count % 100 == 0:
                print(count, first_id, second_id)

            # every 10000 sentences, insert them in bulk
            if count % 10000 == 0:
                arg_str = b','.join(cursor.mogrify("(%s,%s)", x) for x in tup)

                if arg_str != b'':
                    cursor.execute(
                        b"insert into tatoeba_sentence_pairs (first_id, second_id) " +
                        b"values " + arg_str + b" on conflict do nothing")
                    connection.commit()
                    tup = []

        arg_str = b','.join(cursor.mogrify("(%s,%s)", x) for x in tup)

        if arg_str != b'':
            cursor.execute(
                b"insert into tatoeba_sentence_pairs (first_id, second_id) " +
                b"values " + arg_str + b" on conflict do nothing")
            connection.commit()

    print("new fill sentence ids table done")


def add_new_language(language):
    """This function is used to add a new learnable language to the database.
    This language is required to work with SpaCy."""

    if len(language) != 3:
        print("Language code must be 3 characters long")
        return

    # DO NOT FORGET TO APPEND LANGUAGE to LANGUAGES!

    # create_sentences_json()
    # create_valid_sentences()
    # create_valid_sentence_ids(new_language=language)
    # fill_tatoeba_sentence(new_language=language)

    # Run the following line in an environment with SpaCy installed (for the new language)
    # fill_word_to_sentence_table(language=language)

    new_fill_sentence_ids_table()

    print("done")


def tatoeba_from_scratch(languages):
    # create_sentences_json(languages=languages)
    # create_valid_sentences(languages=languages)
    # create_valid_sentence_ids(languages=languages)
    # fill_tatoeba_sentence(languages=languages)
    
    for language in languages:
        fill_word_to_sentence_table(language)



def main():
    tatoeba_from_scratch(languages=LANGUAGES)
    # add_new_language('swe')


if __name__ == '__main__':
    main()
