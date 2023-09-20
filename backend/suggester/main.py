import os
from functools import wraps
from math import ceil

import psycopg2
from flask import Flask, request, jsonify
from psycopg2 import errorcodes

import config

app = Flask(__name__)
config.set_values()


# run the flask app from terminal with this command:
# FLASK_APP=backend/main.py flask run

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
            print({'success': False, 'error': errorcodes.lookup(e.pgcode), 'long_error': e})
            return jsonify({'success': False, 'error': errorcodes.lookup(e.pgcode), 'long_error': e}), 400

        # Renaming the function name:

    wrapper.__name__ = function.__name__
    return wrapper


connection = connect()
cursor = connection.cursor()


@app.route('/')
def index():
    return jsonify({'success': True, 'message': 'Hello World'}), 200


@app.route('/get-unknown-sentences', methods=['GET'])
@err_handling_decorator
def get_unknown_sentences():
    """
    This function returns a list of suggested sentences (with pagination) for a given user,
    without taking grammar into account.

    param uid: the id of the user
    param language: the language of the suggested sentences
    param full_sentence: suggested sentence starts with capital letter and ends with punctuation if true
    param page: the page number of the sentences
    param rows_per_page: the number of sentences per page
    param max_unknown_count: the maximum number of unknown words in a sentence
    """

    data = request.json

    uid = data['uid']
    max_unknown_count = data['max_unknown_count']
    language = data['language']
    full_sentence = data['full_sentence']

    page = data['page']
    rows_per_page = data['rows_per_page']

    # check if user exists
    cursor.execute("SELECT * "
                   "FROM user_table "
                   "WHERE uid = %s", (uid,))

    # if user does not exist, return false
    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': f'User with id = {uid} does not exist'}), 400

    # check if the user has not learned the language
    cursor.execute("SELECT * FROM user_learned_language "
                   "WHERE "
                   "    uid = %s AND "
                   "    learned_language = %s", (uid, language))

    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': 'Language is not in user\'s list of learned languages.'}), 400

    cursor.execute("select regex, is_learnable "
                   "from language_table "
                   "where language = %s", (language,))

    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': f'Language with code = {language} does not exist'}), 400

    result = cursor.fetchone()

    if not result[1]:
        return jsonify({'success': False, 'error': f'Language with code = {language} is not learnable'}), 400

    regex = cursor.fetchone()[0] if full_sentence else '^(.*)$'

    # get words in sentences with video_id same as a video that is in the correct language
    query = """
        with user_words as (
            select word_id
            from word_strength
            where uid = %s and strength = 8
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
            V.language = %s and
            S.content ~ %s and
            length(S.content) > 1 and
            UVC.video_category = V.category and
            UVC.uid = %s
        OFFSET ((%s - 1) * %s) ROWS
        LIMIT %s"""

    cursor.execute(query, (uid, language, regex, uid, page, rows_per_page, rows_per_page))

    return jsonify({'success': True,
                    'data': [{
                        'properties': {
                            'sentence': row[0],
                            'video': row[1],
                            'word': row[2]
                        }} for row in cursor.fetchall()]}), 200


@app.route('/get-i-plus-one-sentences', methods=['GET'])
@err_handling_decorator
def get_i_plus_one_sentences():
    data = request.json

    uid = data['uid']
    language = data['language']
    full_sentence = data['full_sentence']

    page = data['page']
    rows_per_page = data['rows_per_page']

    # check if user exists
    cursor.execute("SELECT * "
                   "FROM user_table "
                   "WHERE uid = %s", (uid,))

    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': f'User with id {uid} does not exist'}), 400

    # check if language exists in user's list
    cursor.execute("SELECT * "
                   "FROM user_learned_language "
                   "WHERE uid = %s AND learned_language = %s", (uid, language))

    if cursor.rowcount == 0:
        return jsonify({'success': False,
                        'error': f'User with id {uid} has not learned language {language}'}), 400

    cursor.execute("select regex, is_learnable "
                   "from language_table "
                   "where language = %s", (language,))

    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': f'Language with code = {language} does not exist'}), 400

    result = cursor.fetchone()

    if not result[1]:
        return jsonify({'success': False, 'error': f'Language with code = {language} is not learnable'}), 400

    regex = cursor.fetchone()[0] if full_sentence else '^(.*)$'

    # The sentences we need are:
    # 1. the sentences that contain 1 unknown word
    # 2. the sentences that contain 1 unknown grammar rule, and 0 unknown words

    # get sentences that contain 1 unknown word
    cursor.execute("SELECT DISTINCT ON (V.video_id) S.sentence_id, S.content, row_to_json(V) "
                   "FROM sentence S, video V, user_video_category UVC "
                   "WHERE "
                   "    (SELECT count(*) FROM "
                   "        (("
                   "            SELECT word_id "
                   "            FROM word_to_sentence WTS "
                   "            WHERE WTS.sentence_id = S.sentence_id"
                   "        )"
                   "        EXCEPT "
                   "        (SELECT word_id "
                   "         FROM word_strength WS"
                   "         WHERE "
                   "             uid = %s AND "
                   "             language = %s AND "
                   "             strength = 8)"
                   "             ) as unknown_word_count "
                   "    ) = 1 AND "
                   "    (SELECT count(*) FROM "
                   "        (("
                   "            SELECT rule_id "
                   "            FROM grammar_rule GR "
                   "            WHERE GR.language = %s"
                   "        )"
                   "        EXCEPT "
                   "            (SELECT rule_id "
                   "            FROM user_grammar UG "
                   "        WHERE UG.uid = %s)) as unknown_grammar_rule_count"
                   "    ) = 0 AND "
                   "    S.video_id = V.video_id AND V.language = %s AND "
                   "    S.content ~ %s AND "
                   "    length(S.content) > 1 AND "
                   "    UVC.video_category = V.category AND "
                   "    UVC.uid = %s "
                   "OFFSET ((%s - 1) * %s) ROWS "
                   "LIMIT %s",
                   (uid, language, language, uid, language, regex, uid,
                    page, ceil(rows_per_page / 2), ceil(rows_per_page / 2)))

    word_suggestion_result = [{'sentence_id': row[0],
                               'content': row[1],
                               'video_properties': row[2]} for row in cursor.fetchall()]

    cursor.execute("SELECT DISTINCT ON (V.video_id) S.sentence_id, S.content, row_to_json(V) "
                   "FROM sentence S, video V, user_video_category UVC "
                   "WHERE "
                   "    (SELECT count(*) FROM "
                   "        (("
                   "            SELECT word_id "
                   "            FROM words_in_sentence WIS "
                   "            WHERE WIS.sentence_id = S.sentence_id"
                   "        )"
                   "        EXCEPT "
                   "        (SELECT word_id "
                   "         FROM word_strength WS"
                   "         WHERE "
                   "             uid = %s AND "
                   "             language = %s AND "
                   "             strength = 8)"
                   "             ) as unknown_word_count "
                   "    ) = 0 AND "
                   "    (SELECT count(*) FROM "
                   "        (("
                   "            SELECT rule_id "
                   "            FROM grammar_rule GR "
                   "            WHERE GR.language = %s"
                   "        )"
                   "        EXCEPT "
                   "            (SELECT rule_id "
                   "            FROM user_grammar UG "
                   "        WHERE UG.uid = %s)) as unknown_grammar_rule_count"
                   "    ) = 1 AND "
                   "    S.video_id = V.video_id AND V.language = %s AND "
                   "    S.content ~ %s AND "
                   "    length(S.content) > 1 AND "
                   "    UVC.video_category = V.category AND "
                   "    UVC.uid = %s "
                   "OFFSET ((%s - 1) * %s) ROWS "
                   "LIMIT %s",
                   (uid, language, language, uid, language, regex, uid,
                    page, rows_per_page // 2, rows_per_page // 2))

    grammar_rule_suggestions = [{'sentence_id': row[0],
                                 'content': row[1],
                                 'video_properties': row[2]} for row in cursor.fetchall()]

    """for index, row in enumerate(word_suggestion_result):
        cursor.execute("SELECT row_to_json(WT) "
                       "FROM word_to_sentence WTS, word_table WT, sentence S, video V "
                       "WHERE "
                       "    WTS.sentence_id = S.sentence_id AND "
                       "    S.video_id = V.video_id AND "
                       "    V.language = %s AND "
                       "    WTS.sentence_id = %s AND " 
                       "    WTS.word_id NOT IN (SELECT word_id "
                       "                        FROM word_strength "
                       "                        WHERE "
                       "                            strength = 8 AND "
                       "                            uid = %s) AND "
                       "    WTS.word_id = WT.word_id",
                       (language, row['sentence_id'], uid))

        word_suggestion_result[index]['word_properties'] = [result[0] for result in cursor.fetchall()]"""

    # TODO: normally, when rows_per_page = 11, the above parameters are supposed to give 6+5=11 results
    # but it gives 6 results, because our user initially knows all grammar rules, and the
    # second set of sentences is an empty set

    return jsonify({'success': True,
                    'data': {
                        'word_suggestions': word_suggestion_result,
                        'grammar_suggestions': grammar_rule_suggestions
                    }}), 200


@app.route("/transcript/<video_id>", methods=['GET'])
@err_handling_decorator
def get_video_transcript(video_id):
    """This function returns the transcript of a video.
    param video_id: the id of the video
    """
    cursor.execute("SELECT CAST(start_time * 1000 AS INT) AS start, "
                   "CAST((start_time + duration) * 1000 AS INT) AS end, "
                   "content, tokens, token_ids FROM sentence WHERE video_id = %s ORDER BY start", (video_id,))

    result = cursor.fetchall()

    return jsonify({'success': True,
                    'data': [{'start': row[0],
                              'end': row[1],
                              'content': row[2],
                              'tokens': row[3],
                              'token_ids': row[4]} for row in result]}), 200


def remove_word_from_list(uid, word_id):
    """This function removes the word from user's vocabulary.

    param uid: the id of the user
    param language: the language of the word
    param word: the word to be removed
    param pos: the part of speech of the word
    """

    cursor.execute("DELETE FROM word_strength "
                   "WHERE "
                   "    uid = %s AND"
                   "    word_id = %s",
                   (uid, word_id))

    connection.commit()


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5001)
