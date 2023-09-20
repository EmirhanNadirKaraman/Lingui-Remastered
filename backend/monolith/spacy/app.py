import datetime
import os
from functools import wraps
from random import randint

import psycopg2
import spacy
from flask import Flask, jsonify, request
from psycopg2 import errorcodes

import config

app = Flask(__name__)
config.set_values()

POINTS_PER_CLOZE = 3


def connect():
    conn = psycopg2.connect(
        host=os.getenv('URL'),
        database=os.getenv('DATABASE_NAME'),
        user=os.getenv('USERNAME'),
        password=os.getenv('PASSWORD')
    )

    return conn


def err_handling_decorator(function):
    @wraps(function)
    def wrapper(*args, **kwargs):
        try:
            return function(*args, **kwargs)
        except psycopg2.Error as e:
            cursor.execute("ROLLBACK")
            print({'success': False, 'error': errorcodes.lookup(e.pgcode)})
            return jsonify({'success': False, 'error': errorcodes.lookup(e.pgcode)}), 400

        # Renaming the function name:

    wrapper.__name__ = function.__name__
    return wrapper


connection = connect()
cursor = connection.cursor()


@app.route('/')
def index():
    return jsonify({'success': True, 'message': 'Hello World'}), 200


def translate_language(language):
    lang_dict = {
        "en": "eng",
        "de": "deu",
        "fr": "fra",
        "es": "spa",
        "it": "ita",
        "pt": "por",
        "ja": "jpn",
        "ru": "rus",
        "ko": "kor",
        "tr": "tur",
        "pl": "pol",
        "sv": "swe"
    }

    if language not in lang_dict:
        raise ValueError("Language not found")

    return lang_dict[language]


def load_model(language):
    lang_model_map = {
        "en": "en_core_web_sm",
        "de": "de_core_news_sm",
        "fr": "fr_core_news_sm",
        "es": "es_core_news_sm",
        "it": "it_core_news_sm",
        "pt": "pt_core_news_sm",
        "ja": "ja_core_news_sm",
        "ru": "ru_core_news_sm",
        "ko": "ko_core_news_sm",
        "pl": "pl_core_news_sm",
        "sv": "sv_core_news_sm"
    }

    print(f"{language} model loaded")
    return spacy.load(lang_model_map[language])


def _replace(sentence, word, start_index):
    return sentence[:start_index] + '_' + sentence[start_index + len(word):]


def _find(sentence, word, start_index, end_index):
    return sentence[start_index:end_index].find(word)


def remove_word_from_sentence(nlp, sentence, word, word_pos):
    tokens = [{
        'text': token.text,
        'pos': token.pos_
    } for token in nlp(sentence)]

    index = 0
    for token in tokens:
        if token['text'] == word and token['pos'] == word_pos:
            index += _find(sentence, word, index, len(sentence))
            sentence = _replace(
                sentence=sentence,
                word=word,
                start_index=index
            )
        else:
            index += len(token['text'])

    return sentence

def remove_word_from_sentence_without_pos(nlp, sentence, word):
    tokens = [{
        'text': token.text
    } for token in nlp(sentence)]

    index = 0
    for token in tokens:
        if token['text'] == word:
            index += _find(sentence, word, index, len(sentence))
            sentence = _replace(
                sentence=sentence,
                word=word,
                start_index=index
            )
        else:
            index += len(token['text'])

    return sentence


# TODO: to prevent multiple post requests to have an effect,
#  we might try to check if datetime.now < due_date.
#  if it is, then we don't update the database.
#  if it is not, then we update the database
@app.route('/check-answer', methods=['POST'])
@err_handling_decorator
def check_answer():
    """This function updates the word_strength table in the database,
    according to the truth value of the database.
    """

    data = request.json

    uid = data['uid']
    word_id = data['word_id']
    correct = data['correct']

    # check if user exists
    cursor.execute("SELECT * "
                   "FROM user_table "
                   "WHERE uid = %s", (uid,))
    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': 'User does not exist'}), 400

    cursor.execute("SELECT word_id, strength "
                   "FROM word_strength "
                   "WHERE "
                   "    uid = %s AND "
                   "    word_id = %s", (uid, word_id))

    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': 'Word, language pair does not exist in user vocab'}), 400

    result = cursor.fetchone()
    word_id = result[0]
    strength = result[1]

    if strength == 8:
        return jsonify({'success': False, 'error': 'Word is already mastered'}), 400

    if correct:
        correct_answer(uid, word_id)
    else:
        incorrect_answer(uid, word_id)

    return jsonify({'success': True}), 200


@app.route('/get-magic-sentences', methods=['GET'])
@err_handling_decorator
def get_magic_sentences():
    """
    This function returns a list of suggested sentences (with pagination) for a given user that contains the unknown word.
    param uid: the id of the user
    param unknown_word: the unknown word
    param language: the language of the suggested sentences
    param full_sentence: suggested sentence starts with capital letter and ends with punctuation if true
    param page: the page number of the sentences
    param rows_per_page: the number of sentences per page
    """

    data = request.json

    unknown_word_id = data['word_id']
    uid = data['uid']
    language = data['language']
    full_sentence = data['full_sentence']

    page = data['page']
    rows_per_page = data['rows_per_page']

    cursor.execute("select regex, is_learnable "
                   "from language_table "
                   "where language = %s", (language,))

    if cursor.rowcount == 0:
        print("there")
        return jsonify({'success': False, 'error': f'Language with code = {language} does not exist'}), 400

    result = cursor.fetchone()

    if not result[1]:
        print("here")
        return jsonify({'success': False, 'error': f'Language with code = {language} is not learnable'}), 400

    regex = result[0] if full_sentence else '^(.*)$'

    cursor.execute("WITH sentences_with_word AS ("
                   "    SELECT S.sentence_id, S.content, row_to_json(V) as video"
                   "    FROM sentence S, video V "
                   "    WHERE "
                   "        EXISTS (SELECT 1 "
                   "                FROM word_to_sentence WTS "
                   "                WHERE "
                   "                    WTS.word_id = %s AND "
                   "                    S.sentence_id = WTS.sentence_id) "
                   "                    AND S.video_id = V.video_id AND V.language = %s), "

                   "word_count AS ("
                   "    SELECT count(*) AS cnt, sentence_id "
                   "    FROM word_to_sentence "
                   "    WHERE EXISTS (SELECT 1 "
                   "                    FROM sentences_with_word "
                   "                    WHERE "
                   "                        sentences_with_word.sentence_id = "
                   "                        word_to_sentence.sentence_id) "
                   "    GROUP BY sentence_id), "

                   "known_words AS ("
                   "    SELECT count(*) AS cnt, WTS.sentence_id "
                   "    FROM word_to_sentence WTS INNER JOIN word_strength WS "
                   "        ON WS.word_id = WTS.word_id AND WS.uid = %s "
                   "    WHERE strength = 8 "
                   "    GROUP BY sentence_id), "

                   "distinct_sentences AS (SELECT DISTINCT ON (SWW.content) "
                   "    SWW.content, SWW.sentence_id, SWW.video, "
                   "    word_count.cnt - COALESCE(known_words.cnt, 0) as unknown_count "
                   "FROM sentences_with_word SWW "
                   "    INNER JOIN word_count ON SWW.sentence_id = word_count.sentence_id "
                   "    LEFT JOIN known_words ON word_count.sentence_id = known_words.sentence_id "
                   "WHERE SWW.content ~ %s "
                   "ORDER BY SWW.content "
                   "OFFSET ((%s - 1) * %s) ROWS "
                   "LIMIT %s) "
                   
                   "SELECT * "
                   "FROM distinct_sentences "
                   "ORDER BY unknown_count",
                   (unknown_word_id, language, uid, regex, page, rows_per_page, rows_per_page))

    sentences = [{'content': sentence[0],
                  'sentence_id': sentence[1],
                  'video_properties': sentence[2],
                  'unknown_count': sentence[3]} for sentence in cursor.fetchall()]

    # find the number of sentences the word is in
    cursor.execute("SELECT count(*) "
                   "FROM word_to_sentence WTS, sentence S "
                   "WHERE "
                   "    WTS.sentence_id = S.sentence_id AND "
                   "    WTS.word_id = %s AND"
                   "    S.content ~ %s", (unknown_word_id, regex))

    total_count = cursor.fetchone()[0]

    return jsonify({'success': True,
                    'data': {
                        'sentences': sentences,
                        'total_count': total_count
                    }}), 200


@app.route('/get-cloze-questions', methods=["GET"])
@err_handling_decorator
def get_cloze_questions():
    data = request.json

    uid = data["uid"]
    native_language = data["native_language"]
    target_language = data["target_language"]
    is_exact = data["is_exact"]

    nlp = load_model(target_language)

    # get the word_arr from the database
    cursor.execute("select WT.word, WT.pos "
                   "from word_strength WS, word_table WT "
                   "where "
                   "    WS.word_id = WT.word_id and "
                   "    uid = %s and "
                   "    language = %s and"
                   "    due_date < %s",
                   (uid, target_language, datetime.datetime.now()))

    result = cursor.fetchall()

    if not result:
        return jsonify({"success": True, "error": "No words to review"}), 200

    word_arr = [{"word": word[0], "pos": word[1]} for word in result]

    if not is_exact:
        print("not exact")

    query_arr = []
    params = []

    # s1 is target sentence
    # s2 is native language translation (the hint in clozemaster)

    native_language = translate_language(native_language)
    target_language = translate_language(target_language)

    if target_language == 'eng':
        for word in word_arr:
            first_str = """
            (select 
                WTS.word, TS2.sentence, TS1.sentence, WTS.pos, WT.word_id
            from 
                tatoeba_sentence_pairs SP, 
                tatoeba_sentence TS1, 
                tatoeba_sentence TS2,
                tatoeba_word_to_sentence WTS,
                word_table WT
            where 
                WT.word = %s and 
                WT.pos = %s and 
                WTS.sentence_id = TS2.sentence_id and 
                SP.second_id = TS2.sentence_id and 
                TS2.language = %s and 
                SP.first_id = TS1.sentence_id and 
                TS1.language = %s and
                WT.word = WTS.word and 
                WT.pos = WTS.pos 
            order by random()
            limit 1)
            """

            query_arr.append(first_str)
            params.extend([word["word"], word["pos"] if word['pos'] else '', target_language, native_language])

            second_str = """
            (select 
                WTS.word, TS1.sentence, TS2.sentence, WTS.pos, WT.word_id
            from 
                tatoeba_sentence_pairs SP, 
                tatoeba_sentence TS1, 
                tatoeba_sentence TS2,
                tatoeba_word_to_sentence WTS,
                word_table WT
            where 
                WTS.sentence_id = TS1.sentence_id and  
                WT.word = %s and 
                WT.pos = %s and 
                SP.first_id = TS1.sentence_id and 
                TS1.language = %s and
                SP.second_id = TS2.sentence_id and 
                TS2.language = %s and 
                WT.word = WTS.word and 
                WT.pos = WTS.pos 
            order by random()
            limit 1)"""

            query_arr.append(second_str)
            params.extend([word["word"], word["pos"], target_language, native_language])

    else:
        for word in word_arr:
            first_str = """
            (select 
                WTS.word, TS2.sentence, TS1.sentence, WT.word_id
            from 
                tatoeba_sentence_pairs SP, 
                tatoeba_sentence TS1, 
                tatoeba_sentence TS2,
                tatoeba_word_to_sentence WTS,
                word_table WT
            where 
                WT.word = %s and 
                WTS.sentence_id = TS2.sentence_id and 
                SP.second_id = TS2.sentence_id and 
                TS2.language = %s and 
                SP.first_id = TS1.sentence_id and 
                TS1.language = %s and
                WT.word = WTS.word 
            order by random()
            limit 1)
            """

            query_arr.append(first_str)
            params.extend(
                [word["word"], target_language, native_language])

            second_str = """
            (select 
                WTS.word, TS1.sentence, TS2.sentence, WT.word_id
            from 
                tatoeba_sentence_pairs SP, 
                tatoeba_sentence TS1, 
                tatoeba_sentence TS2,
                tatoeba_word_to_sentence WTS,
                word_table WT
            where 
                WTS.sentence_id = TS1.sentence_id and  
                WT.word = %s and 
                SP.first_id = TS1.sentence_id and 
                TS1.language = %s and
                SP.second_id = TS2.sentence_id and 
                TS2.language = %s and 
                WT.word = WTS.word
            order by random()
            limit 1)"""

            query_arr.append(second_str)
            params.extend(
                [word["word"], target_language, native_language])

    query_str = " union ".join(query_arr)
    query_str = f"select distinct on (result.word) * from ({query_str}) as result"

    cursor.execute(query_str, params)

    result = cursor.fetchall()

    if result is None:
        return jsonify({'success': False, 'error': 'No sentence found'}), 400

    data = []

    if target_language == 'eng':
        for row in result:
            removed = remove_word_from_sentence(nlp=nlp,
                                                sentence=row[1],
                                                word=row[0],
                                                word_pos=row[3])
            data.append({
                'word': row[0],
                'target_sentence': row[1],
                'translation': row[2],
                'removed': removed,
                'word_id': row[4]
            })
    else:
        for row in result:
            removed = remove_word_from_sentence_without_pos(nlp=nlp,
                                                            sentence=row[1],
                                                            word=row[0])

            data.append({
                'word': row[0],
                'target_sentence': row[1],
                'translation': row[2],
                'removed': removed,
                'word_id': row[3]
            })

    return jsonify({
        'success': True,
        'data': data
    }), 200


def correct_answer(uid, word_id):
    """This function increments the strength of the word, and updates the due date.
    If the strength is 8, then the due date is set to 10 years from now.

    param uid: the id of the user
    param word: the word of which the strength is to be incremented
    param language: the language of the word
    """

    strength = get_word_strength(uid, word_id) + 1

    due_date = calculate_due_date(uid=uid, word_id=word_id, strength=strength)
    update_word_strength_table(uid, word_id=word_id, strength=strength, due_date=due_date)

    cursor.execute("UPDATE user_stat_table "
                   "SET cloze_count = user_stat_table.cloze_count + 1")

    # get the language of the word
    cursor.execute("SELECT language "
                   "FROM word_table "
                   "WHERE word_id = %s", (word_id,))

    language = cursor.fetchone()[0]

    cursor.execute("UPDATE leaderboard "
                   "SET score = leaderboard.score + %s "
                   "WHERE uid = %s AND language = %s", (POINTS_PER_CLOZE, uid, language))

    connection.commit()


def incorrect_answer(uid, word_id):
    """This function sets the strength of the word to 1, and updates the due date.

    param uid: the id of the user
    param word: the word of which the strength is to be incremented
    param language: the language of the word
    """

    strength = 1

    due_date = calculate_due_date(uid=uid, word_id=word_id, strength=strength)
    update_word_strength_table(uid=uid, word_id=word_id, strength=strength, due_date=due_date)


def get_word_strength(uid, word_id):
    """This function finds the strength of the word from the database, and returns the value.

    param uid: the id of the user
    param word_id: the id of the word
    """

    cursor.execute("SELECT strength "
                   "FROM word_strength "
                   "WHERE "
                   "    uid = %s AND "
                   "    word_id = %s", (uid, word_id))

    result = cursor.fetchone()

    return result[0] if result else 0


def calculate_due_date(uid, word_id, strength):
    """This function calculates the due date of the word, based on the new strength of the word.

    param uid: the id of the user
    param word: the word of which the due date is to be calculated
    param language: the language of the word
    param strength: the new strength of the word
    """

    if strength == 8:
        return datetime.datetime.now() + datetime.timedelta(days=365 * 10)

    def fuzz(number):
        return number * (randint(100, 124) / 100)

    MINS_IN_DAY = 1440

    default_mins = get_default_mins(uid)
    ease_factor = get_ease_factor(uid)

    if strength <= len(default_mins):
        added_mins = default_mins[strength - 1]
        return datetime.datetime.now() + datetime.timedelta(minutes=fuzz(added_mins))
    else:
        days_past_after_due = (datetime.datetime.now() - get_due_date(uid, word_id)).days

        added_days = pow(ease_factor, strength - len(default_mins) - 1) + days_past_after_due / 2
        added_mins = added_days * MINS_IN_DAY

        return datetime.datetime.now() + datetime.timedelta(minutes=fuzz(added_mins))


def update_word_strength_table(uid, word_id, strength, due_date):
    """This function updates the strength and due date of the word in the database.

    param uid: the id of the user
    param word: the word of which the strength and due date is to be updated
    param language: the language of the word
    param strength: the new strength of the word
    param due_date: the new due date of the word
    """

    # update word strength and due date in database
    cursor.execute("UPDATE word_strength SET strength = %s, due_date = %s "
                   "WHERE uid = %s AND word_id = %s",
                   (strength, due_date, uid, word_id))

    connection.commit()


def get_default_mins(uid):
    """This function returns the default minutes settings for each strength level.

    param uid: the id of the user
    """

    # TODO: get mins from database from the user's settings
    return [1, 10]


def get_ease_factor(uid):
    """This function returns the ease factor of the user.

    param uid: the id of the user
    """

    # TODO: get ease factor from the user
    return 2.5


def get_due_date(uid, word_id):
    """This function returns the due date of the word.

    param uid: the id of the user
    param word: the word of which the due date is to be returned
    param language: the language of the word
    """

    cursor.execute("SELECT due_date "
                   "FROM word_strength "
                   "WHERE "
                   "    uid = %s AND "
                   "    word_id = %s", (uid, word_id))

    due_date = cursor.fetchone()[0]
    return due_date


if __name__ == '__main__':
    app.run(debug=True, port=5001)