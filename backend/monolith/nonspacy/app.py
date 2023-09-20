import os
import string
from datetime import datetime, timedelta
from functools import wraps
from random import randint, random, choice

import psycopg2
from flask import Flask, request, jsonify
from psycopg2 import errorcodes
from unique_names_generator import get_random_name

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

POINTS_PER_VID = 1


@app.route('/')
def index():
    return jsonify({'success': True, 'message': 'Hello World'}), 200


@app.route('/search', methods=['GET'])
@err_handling_decorator
def search():
    data = request.json

    query = data['query']
    language = data['language']
    page = data['page']
    rows_per_page = data['rows_per_page']

    cursor.execute("SET pg_trgm.similarity_threshold = 0.05; "
                   "SELECT word_id, word, pos "
                   "FROM word_table "
                   "WHERE language = %s AND word %% %s "
                   "ORDER BY similarity(word, %s) DESC "
                   "OFFSET (%s - 1) * %s "
                   "LIMIT %s",
                   (language, query, query, page, rows_per_page, rows_per_page))

    # TODO: only return the words that start with lower case
    result = cursor.fetchall()
    lower_result = set()

    data = []
    for row in result:
        word_to_lower = row[1].lower()
        if word_to_lower not in lower_result:
            if not any(p in word_to_lower for p in string.punctuation):
                data.append({
                    "word_id": row[0],
                    "word": row[1].lower(),
                    "pos": row[2]
                })
                lower_result.add(row[1].lower())

    return jsonify({'success': True, 'data': data}), 200


@app.route('/leaderboard', methods=['GET'])
@err_handling_decorator
def get_leaderboard():
    data = request.json

    uid = data['uid']
    language = data['language']

    cursor.execute("SELECT score, row_to_json(UT) "
                   "FROM leaderboard, user_table UT "
                   "WHERE "
                   "    leaderboard.uid = UT.uid AND "
                   "    language = %s "
                   "ORDER BY score desc", (language,))

    return jsonify({'success': True,
                    'data': [
                        {
                            "score": row[0],
                            "user": row[1]
                        } for row in cursor.fetchall()]
                    }), 200


@app.route('/get-user-time-in-language', methods=['GET'])
@err_handling_decorator
def get_user_time_in_language():
    data = request.json

    uid = data['uid']
    language = data['language']

    # check if user does not exist
    cursor.execute("SELECT * FROM user_table "
                   "WHERE uid = %s", (uid,))

    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': f'User with id {uid} is not found'}), 400

    # check if user is learning that language. if not, give error
    cursor.execute("SELECT * FROM user_learned_language "
                   "WHERE uid = %s AND learned_language = %s", (uid, language))

    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': f'User with id {uid} does not learn {language}'}), 400

    cursor.execute("SELECT total_time FROM user_stat_table "
                   "WHERE uid = %s AND language = %s", (uid, language))

    return jsonify(cursor.fetchone()), 200


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

    regex = result[0] if full_sentence else '^(.*)$'

    # get words in sentences with video_id same as a video that is in the correct language
    query = """
        with user_words as (
            select word_id
            from word_strength
            where uid = %s and strength = 8
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
                V.language = %s and
                S.content ~ %s and
                length(S.content) > 1 and
                UVC.video_category = V.category and
                UVC.uid = %s)
            
        select * 
        from suggestions 
        order by random()
        limit %s
        """

    # TODO: maybe think about adding offset as: "OFFSET ((%s - 1) * %s) ROWS "

    # cursor.execute(query, (uid, language, regex, uid, page, rows_per_page, rows_per_page))
    cursor.execute(query, (uid, language, regex, uid, rows_per_page))

    return jsonify({'success': True,
                    'data': [{
                        'properties': {
                            'sentence': row[0],
                            'video': row[1],
                            'word': row[2]
                        }} for row in cursor.fetchall()]}), 200


@app.route("/transcript/<video_id>", methods=['GET'])
@err_handling_decorator
def get_video_transcript(video_id):
    """This function returns the transcript of a video.
    param video_id: the id of the video
    """
    cursor.execute("SELECT CAST(start_time * 1000 AS INT) AS start, "
                   "CAST((start_time + duration) * 1000 AS INT) AS end, "
                   "content, tokens, token_ids FROM sentence WHERE video_id = %s ORDER BY start_time", (video_id,))

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


@app.route('/remove-categories-from-user', methods=['DELETE'])
@err_handling_decorator
def remove_categories():
    """This function removes a list of video categories from user_video_category table."""
    data = request.json
    uid = data['uid']
    categories = data['categories']

    cursor.execute("DELETE FROM user_video_category "
                   "WHERE uid = %s AND video_category in %s", (uid, categories))
    connection.commit()

    return jsonify({'success': True}), 200


@app.route('/add-categories-to-user', methods=['PUT'])
@err_handling_decorator
def add_categories():
    """This function adds categories to user_video_category table."""
    data = request.json

    uid = data['uid']
    categories = data['categories']

    for category in categories:
        cursor.execute("INSERT INTO user_video_category (uid, video_category) "
                       "VALUES (%s, %s) ON CONFLICT DO NOTHING", (uid, category))

    connection.commit()

    return jsonify({'success': True}), 200


@app.route('/update-user-time', methods=['POST'])
@err_handling_decorator
def update_user_time():
    """An HTTP request will be sent to this endpoint every 60 seconds to update the user's total time."""
    data = request.json

    uid = data['uid']
    language = data['language']

    # increase user_time by 60 seconds
    cursor.execute("UPDATE user_stat_table "
                   "SET total_time = user_stat_table.total_time + 60 "
                   "WHERE uid = %s AND language = %s", (uid, language))

    connection.commit()

    return jsonify({'success': True}), 200


@app.route('/get-user-languages', methods=['GET'])
@err_handling_decorator
def get_user_languages():
    """This function returns the languages the user has started learning,
    and all languages available for learning."""

    data = request.json

    uid = data['uid']

    # get all learnable languages
    cursor.execute("select language "
                   "from language_table "
                   "where is_learnable = true")

    all_learnable_languages = [row[0] for row in cursor.fetchall()]

    cursor.execute("SELECT learned_language "
                   "FROM user_learned_language "
                   "WHERE uid = %s", (uid,))

    return jsonify({'success': True,
                    'data': {
                        'learned_languages': [data[0] for data in cursor.fetchall()],
                        'all_languages': all_learnable_languages
                    }}), 200


@app.route('/get-user-word-ids', methods=['GET'])
@err_handling_decorator
def get_user_word_ids():
    data = request.json

    uid = data['uid']
    language = data['language']

    cursor.execute("SELECT WT.word_id, WS.strength "
                   "FROM word_strength WS, word_table WT "
                   "WHERE "
                   "    WS.word_id = WT.word_id AND "
                   "    uid = %s AND"
                   "    language = %s", (uid, language))

    return jsonify({'success': True,
                    'data': [{
                        "word_id": data[0],
                        "strength": data[1]
                    } for data in cursor.fetchall()]}), 200


@app.route('/list-user-words', methods=['GET'])
@err_handling_decorator
def list_user_words():
    """This function lists all words the user has started learning with pagination."""

    data = request.json

    uid = data['uid']
    language = data['language']

    page = data['page']
    rows_per_page = data['rows_per_page']

    cursor.execute("SELECT * "
                   "FROM user_table "
                   "WHERE uid = %s", (uid,))

    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': 'User does not exist'}), 400

    cursor.execute("SELECT word, due_date, WT.word_id, strength "
                   "FROM word_strength WS, word_table WT "
                   "WHERE "
                   "   uid = %s "
                   "   AND WS.word_id = WT.word_id "
                   "   AND WT.language = %s "
                   "ORDER BY strength = 8, due_date "
                   "OFFSET ((%s - 1) * %s) ROWS "
                   "LIMIT %s", (uid, language, page, rows_per_page, rows_per_page))

    return jsonify({
        'success': True,
        'data': [
            {
                'word': data[0],
                'due_date': data[1].isoformat(),
                'word_id': data[2],
                'percent': data[3] / 8
            } for data in cursor.fetchall() if not any(p in data[0] for p in string.punctuation)
        ]
    }), 200


@app.route('/get-user-word-count', methods=['GET'])
@err_handling_decorator
def get_user_word_count():
    """This function lists all words the user has started learning with pagination."""

    data = request.json

    uid = data['uid']
    language = data['language']

    cursor.execute("SELECT * "
                   "FROM user_table "
                   "WHERE uid = %s", (uid,))
    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': 'User does not exist'}), 400

    cursor.execute("SELECT count(*) "
                   "FROM word_strength WS, word_table WT "
                   "WHERE "
                   "    WT.word_id = WS.word_id AND "
                   "    uid = %s AND "
                   "    WT.language = %s",
                   (uid, language))

    return jsonify({
        'success': True,
        'data': {
            'count': cursor.fetchone()[0]
        }
    }), 200


@app.route('/get-current-language', methods=['GET'])
@err_handling_decorator
def get_current_language():
    # if the user has not started to learn any language, return first_time = True
    # if the user has started to learn a language, return first_time = False

    data = request.json

    uid = data['uid']

    language_code = ''

    cursor.execute("SELECT learned_language FROM user_learned_language "
                   "WHERE uid = %s", (uid,))

    # user is not learning any language atm
    if cursor.rowcount != 0:
        cursor.execute("SELECT current_language FROM user_table "
                       "WHERE uid = %s", (uid,))

        language_code = cursor.fetchone()[0]

    return jsonify({'language_code': language_code}), 200


@app.route('/signup', methods=['POST'])
@err_handling_decorator
def signup():
    """This function checks the database if the user already exists in the database.
    If the user does not exist, it creates a new user with the given username and (hashed) password.
    """

    data = request.json

    uid = data['uid']
    username = data['username']
    email = data['email']
    photo = data['photo']

    # check if user already exists
    cursor.execute("SELECT * "
                   "FROM user_table "
                   "WHERE uid = %s", (uid,))

    if cursor.rowcount > 0:
        return jsonify({'success': False, 'error': 'User already exists'}), 400

    # the user does not exist, so we create a new user
    cursor.execute("INSERT INTO user_table (uid, username, email, photo) "
                   "VALUES (%s, %s, %s, %s)", (uid, username, email, photo))

    connection.commit()

    return jsonify({'success': True}), 200


@app.route('/delete-user', methods=['DELETE'])
@err_handling_decorator
def delete_user():
    """This function deletes the user from the database, if such a user exists."""

    data = request.json

    uid = data['uid']

    # if user does not exist, return false
    cursor.execute("SELECT * "
                   "FROM user_table "
                   "WHERE uid = %s", (uid,))

    if cursor.rowcount == 0:
        print("User with uid = " + str(uid) + " does not exist.")
        return jsonify({'success': False}), 400

    # then delete from user_table
    cursor.execute("DELETE FROM user_table "
                   "WHERE uid = %s", (uid,))

    connection.commit()

    return jsonify({'success': True}), 200


def add_punctuation_to_user(uid, language):
    queries = []
    params = []

    for punct in string.punctuation:
        queries.append("select word_id "
                       "from word_table "
                       "where "
                       "    word = %s and "
                       "    language = %s")
        params.extend([punct, language])

    query_str = ' union '.join(queries)
    cursor.execute(query_str, params)

    word_ids = [row[0] for row in cursor.fetchall()]

    # add the word_ids into the word_strength table
    tup = []
    due_date = datetime.now() + timedelta(days=10 * 365)

    for word_id in word_ids:
        tup.append((uid, word_id, due_date, 8))

    arg_str = b','.join(cursor.mogrify("(%s,%s,%s,%s)", x) for x in tup)

    if arg_str != b'':
        cursor.execute(b"INSERT INTO word_strength (uid, word_id, due_date, strength) " +
                       b" VALUES " + arg_str + b' ON CONFLICT DO NOTHING')

    connection.commit()

    return jsonify({'success': True}), 200


@app.route('/add-multiple-words-to-user', methods=['POST'])
@err_handling_decorator
def add_multiple_words_to_user():
    """This function is called at the very beginning of the user's learning process.
    It is intended to give the user a headstart, when starting to learn a language on our app."""

    data = request.json

    uid = data['uid']
    word_ids = data['word_ids']

    tup = []
    due_date = datetime.now() + timedelta(days=10 * 365)

    for word_id in word_ids:
        tup.append((uid, word_id, due_date, 8))

    arg_str = b','.join(cursor.mogrify("(%s,%s,%s,%s)", x) for x in tup)

    if arg_str != b'':
        cursor.execute(b"INSERT INTO word_strength (uid, word_id, due_date, strength) " +
                       b" VALUES " + arg_str + b' ON CONFLICT DO NOTHING')

    connection.commit()

    return jsonify({'success': True}), 200


@app.route('/sentence-watched', methods=['POST'])
@err_handling_decorator
def sentence_watched():
    """This function is called when the user watches a sentence."""
    # increase the number of sentences watched by the user by 1
    # then increase the score by 1 point
    data = request.json

    uid = data['uid']
    language = data['language']

    cursor.execute("UPDATE user_stat_table "
                   "SET shown_sentence_count = user_stat_table.shown_sentence_count + 1", (uid, language))

    cursor.execute("UPDATE leaderboard "
                   "SET score = leaderboard.score + %s "
                   "WHERE uid = %s AND language = %s",
                   (POINTS_PER_VID, uid, language))

    connection.commit()


@app.route('/learn-word', methods=['POST'])
@err_handling_decorator
def learn_word():
    """This function adds the word to the user's vocabulary, and sets the strength to 8.

    param uid: the id of the user
    param word: the word to be added
    param language: the language of the word
    param pos: the part of speech of the word
    """

    data = request.json

    uid = data['uid']
    word_id = data['word_id']

    # check the language of the word
    cursor.execute("SELECT language "
                   "FROM word_table "
                   "WHERE word_id = %s", (word_id,))

    # check if word exists
    if cursor.rowcount == 0:
        return jsonify({'success': False, 'error': 'Word does not exist'}), 400

    # check if language is in the user's language list
    language = cursor.fetchone()[0]
    cursor.execute("SELECT * "
                   "FROM user_learned_language "
                   "WHERE "
                   "    uid = %s AND"
                   "    learned_language = %s", (uid, language))

    if cursor.rowcount == 0:
        return jsonify({'success': False,
                        'error': f"Language does not exist in user {str(uid)}'s list "
                                 f"of learned languages."}), 400

    # word is already mastered
    if get_word_strength(uid=uid, word_id=word_id) == 8:
        return jsonify({'success': False, 'error': 'Word already mastered'}), 200

    due_date = calculate_due_date(uid=uid, word_id=word_id, strength=8)

    # add the word with strength 8 and due date 10 years from now with insert + on conflict update
    cursor.execute("INSERT INTO word_strength (uid, word_id, strength, due_date) "
                   "VALUES (%s, %s, %s, %s)"
                   "ON CONFLICT (uid, word_id) "
                   "DO UPDATE SET strength = 8, due_date = %s",
                   (uid, word_id, 8, due_date, due_date))

    connection.commit()

    return jsonify({'success': True}), 200


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


@app.route('/add-word-to-user', methods=['POST'])
@err_handling_decorator
def add_word_to_user():
    """This function adds a word to user's vocabulary, and sets the strength to 1.

    param uid: the id of the user
    param language: the language of the word
    param word: the word to be added
    """

    data = request.json

    uid = data['uid']
    word_id = data['word_id']

    # check if user exists
    cursor.execute("SELECT * FROM user_table WHERE uid = %s", (uid,))
    if cursor.fetchone() is None:
        print("Cannot add word to user, user does not exist")
        return jsonify({'success': False}), 400

    # check if word language is in user's learned languages list
    cursor.execute("SELECT language "
                   "FROM word_table "
                   "WHERE word_id = %s", (word_id,))

    language = cursor.fetchone()[0]

    # check if the language already exists in the user's language list
    cursor.execute("SELECT * "
                   "FROM user_learned_language "
                   "WHERE "
                   "    uid = %s "
                   "    AND learned_language = %s", (uid, language))

    if cursor.rowcount == 0:
        return jsonify({'success': False,
                        'error': f"Word cannot be added. "
                                 f"Language does not exist in user {str(uid)}'s list "
                                 f"of learned languages."}), 400

    # check if word already exists in word_strength
    cursor.execute("SELECT * "
                   "FROM word_strength "
                   "WHERE uid = %s AND word_id = %s", (uid, word_id))

    if cursor.rowcount != 0:
        return jsonify({'success': False, 'error': 'Word already exists in user\'s list'}), 200

    due_date = datetime.now() + timedelta(minutes=1)

    cursor.execute("INSERT INTO word_strength (uid, word_id, due_date) VALUES (%s, %s, %s)",
                   (uid, word_id, due_date))

    connection.commit()

    return jsonify({'success': True}), 200


@app.route('/add-language-to-user', methods=['POST'])
@err_handling_decorator
def add_language_to_user():
    """This function adds a language to the user's list of learned languages.
    It first checks if the user exists, and if the language is already in the list.
    If the user exists and the language is not in the list, the function adds the language to the list.

    param uid: id of the user
    param language: the language to be added
    """

    data = request.json

    uid = data['uid']
    language = data['language']

    # check if user exists
    cursor.execute("SELECT * FROM user_table WHERE uid = %s", (uid,))
    if cursor.fetchone() is None:
        return jsonify({'success': False}), 400

    # check if user is already learning that language
    cursor.execute("SELECT * FROM user_learned_language WHERE uid = %s AND learned_language = %s",
                   (uid, language))

    if cursor.rowcount != 0:
        return jsonify({'success': False, 'error': 'User is already learning that language'}), 400

    # add language to user's list of learned languages
    cursor.execute("INSERT INTO user_learned_language (uid, learned_language) VALUES (%s, %s)",
                   (uid, language))

    # add all the grammar rules in that language to the user's grammar rule list
    cursor.execute("SELECT * "
                   "FROM grammar_rule "
                   "WHERE language = %s", (language,))

    rule_ids = [rule[0] for rule in cursor.fetchall()]
    tup = [(uid, rule_id) for rule_id in rule_ids]

    arg_str = b','.join(cursor.mogrify("(%s,%s)", x) for x in tup)

    if arg_str != b'':
        cursor.execute(b"INSERT INTO user_grammar (uid, rule_id) " +
                       b"VALUES " + arg_str + b" ON CONFLICT DO NOTHING")

    # make language current language
    cursor.execute("UPDATE user_table SET current_language = %s WHERE uid = %s",
                   (language, uid))

    add_all_categories_to_user(uid, language)
    add_punctuation_to_user(uid, language)
    add_user_to_scoreboard(uid, language)

    connection.commit()
    return jsonify({'success': True}), 200


def add_user_to_scoreboard(uid, language):
    cursor.execute("INSERT INTO leaderboard (uid, language) VALUES (%s, %s)", (uid, language))


def add_all_categories_to_user(uid, language):
    # find all video categories
    cursor.execute("SELECT category "
                   "FROM video "
                   "WHERE language = %s "
                   "GROUP BY category", (language,))

    category_list = [data[0] for data in cursor.fetchall()]

    # add all video categories to user
    arg_arr = []

    for category in category_list:
        arg_arr.append((uid, category))

    arg_str = b','.join(cursor.mogrify("(%s,%s)", x) for x in arg_arr)

    if arg_str != b'':
        cursor.execute(b"INSERT INTO user_video_category (uid, video_category) "
                       b" VALUES " + arg_str + b' ON CONFLICT DO NOTHING')


def calculate_due_date(uid, word_id, strength):
    """This function calculates the due date of the word, based on the new strength of the word.

    param uid: the id of the user
    param word: the word of which the due date is to be calculated
    param language: the language of the word
    param strength: the new strength of the word
    """

    if strength == 8:
        return datetime.now() + timedelta(days=365 * 10)

    def fuzz(number):
        return number * (randint(100, 124) / 100)

    MINS_IN_DAY = 1440

    default_mins = get_default_mins(uid)
    ease_factor = get_ease_factor(uid)

    if strength <= len(default_mins):
        added_mins = default_mins[strength - 1]
        return datetime.now() + timedelta(minutes=fuzz(added_mins))
    else:
        days_past_after_due = (datetime.now() - get_due_date(uid, word_id)).days

        added_days = pow(ease_factor, strength - len(default_mins) - 1) + days_past_after_due / 2
        added_mins = added_days * MINS_IN_DAY

        return datetime.now() + timedelta(minutes=fuzz(added_mins))


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


@app.route('/get-most-frequent-words', methods=['GET'])
@err_handling_decorator
def get_most_frequent_words():
    data = request.json

    uid = data['uid']
    word_count = data['word_count']

    # get all learnable languages
    cursor.execute("select language "
                   "from language_table "
                   "where is_learnable = true")

    all_learnable_languages = [row[0] for row in cursor.fetchall()]

    # find the languages that the user is not learning
    cursor.execute("SELECT learned_language "
                   "FROM user_learned_language "
                   "WHERE uid = %s", (uid,))

    learned_languages = [language[0] for language in cursor.fetchall()]

    not_learned_languages = [language for language in all_learnable_languages if language not in learned_languages]

    result = {}

    for language in not_learned_languages:
        cursor.execute("SELECT WT.word_id, word, pos "
                       "FROM most_frequent_words F, word_table WT "
                       "WHERE "
                       "    F.word_id = WT.word_id AND "
                       "    language = %s "
                       "LIMIT %s", (language, word_count))

        word_list = [{"word_id": word[0], "word": word[1], "pos": word[2]} for word in cursor.fetchall()]
        result[language] = word_list

    return jsonify(result), 200


@app.route('/fill_frequency_table', methods=['PUT'])
@err_handling_decorator
def fill_frequency_table():
    data = request.json

    word_count = data['word_count']

    # get all learnable languages
    cursor.execute("select language "
                   "from language_table "
                   "where is_learnable = true")

    all_learnable_languages = [row[0] for row in cursor.fetchall()]

    # delete all previous words
    cursor.execute("DELETE FROM most_frequent_words")

    regex = r'''^.*[!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~].*'''

    for language in all_learnable_languages:
        cursor.execute("SELECT WTS.word_id "
                       "FROM word_to_sentence WTS, word_table WT "
                       "WHERE "
                       "    WTS.word_id = WT.word_id AND "
                       "    language = %s AND "
                       "    NOT word ~ %s "
                       "GROUP BY WTS.word_id, word, pos, language "
                       "ORDER BY count(*) DESC "
                       "LIMIT %s", (language, regex, word_count))

        word_ids = [row[0] for row in cursor.fetchall()]

        for word in word_ids:
            cursor.execute("INSERT INTO most_frequent_words (word_id) VALUES (%s)", (word,))

    connection.commit()

    return jsonify({'success': True}), 200


@app.route("/add-video-to-blacklist", methods=['POST'])
@err_handling_decorator
def add_video_to_blacklist():
    """This function adds a video to a blacklist, so that it will not be parsed
        (because of subtitles with an error etc.)

    param video_id: the id of the video to be added to the blacklist
    """

    data = request.json

    video_id = data['video_id']

    # check if video already exists in blacklist
    cursor.execute("SELECT * FROM video_blacklist WHERE video_id = %s", (video_id,))

    if cursor.fetchone() is not None:
        return jsonify({'success': False, 'error': 'Video already exists in blacklist'}), 400

    cursor.execute("INSERT INTO video_blacklist (video_id) VALUES (%s)", (video_id,))
    connection.commit()

    return jsonify({'success': True}), 200


@app.route('/test-database', methods=['GET'])
@err_handling_decorator
def test_database():
    # write a function that adds 100 users to the database, teaches them a language,
    # and gives them random scores in the leaderboard table. don't forget to delete these users after the test

    user_table_tup = []
    user_learned_language_tup = []

    # add 100 users into the database with random names and user ids, using mogrify
    for _ in range(100):
        name = unique_names_generator.get_random_name()

        uid = name
        username = name
        email_first_part = '_'.join(name.lower().split())
        email = f'{email_first_part}@gmail.com'

        # get a random value from the list
        language = choice(['en', 'fr'])

        user_table_tup.append((uid, username, email, language))
        user_learned_language_tup.append((uid, language))

    user_table_str = b','.join(cursor.mogrify("(%s,%s,%s,%s)", x) for x in user_table_tup)
    user_learned_language_str = b','.join(cursor.mogrify("(%s,%s)", x) for x in user_learned_language_tup)

    cursor.execute(b"INSERT INTO user_table (uid, username, email, current_language) " +
                   b"VALUES " + user_table_str + b" ON CONFLICT DO NOTHING")

    cursor.execute(b"INSERT INTO user_learned_language (uid, learned_language) " +
                   b"VALUES " + user_learned_language_str + b" ON CONFLICT DO NOTHING")

    # get the 100 users from user learned language table
    cursor.execute("SELECT uid, learned_language "
                   "FROM user_learned_language "
                   "WHERE uid != %s", ('Wn3hIT7lGNO12wLKwD2dvI7FSq42',))

    users_with_language = cursor.fetchall()

    final_tup = []

    for user in users_with_language:
        uid = user[0]
        language = user[1]

        # get a random score between 0 and 100
        score = randint(0, 100)

        final_tup.append((uid, score, language))

    final_str = b','.join(cursor.mogrify("(%s,%s,%s)", x) for x in final_tup)

    # add the user to the leaderboard table
    cursor.execute(b"INSERT INTO leaderboard (uid, score, language) "
                   b" VALUES " + final_str + b" ON CONFLICT DO NOTHING")

    connection.commit()

    return jsonify({'success': True}), 200


@app.route('/end-test', methods=['DELETE'])
@err_handling_decorator
def end_test():
    user_list = ['dEuxpbW6yifo0Ca1X2DDh3y53XO2', 'NSd8JOeE4AXgysRmRsVzB5BZIr62']
    cursor.execute("SELECT uid FROM user_table")

    user_ids = [row[0] for row in cursor.fetchall()]
    users_to_delete = [user_id for user_id in user_ids if user_id not in user_list]

    for user in users_to_delete:
        cursor.execute("DELETE FROM user_table WHERE uid = %s", (user,))
        connection.commit()

    return jsonify({'success': True}), 200

if __name__ == '__main__':
    app.run(debug=True, port=5000)