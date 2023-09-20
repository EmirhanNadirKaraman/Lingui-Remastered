import datetime
import os
import string
from functools import wraps
from random import randint

import psycopg2
from psycopg2 import errorcodes

import config

from flask import Flask, request, jsonify


app = Flask(__name__)
config.set_values()


POINTS_PER_VID = 1


# TODO: user, language'deki errorları implement et

def connect():
    conn = psycopg2.connect(
        host=os.getenv('URL'),
        database=os.getenv('DATABASE_NAME'),
        user=os.getenv('USERNAME'),
        password=os.getenv('PASSWORD')
    )

    return conn


connection = connect()
cursor = connection.cursor()


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


@app.route('/')
def index():
    return jsonify({'success': True, 'message': 'Hello World'}), 200


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
                   "   AND strength < 8 "
                   "ORDER BY strength DESC "
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
    # TODO: find the ids of the punctuation marks in the database

    queries = []
    params = []

    for punct in string.punctuation:
        queries.append("select word_id "
                       "from word_table "
                       "where "
                       "    word = %s and "
                       "    language = %s")
        params.extend([punct, language])

    query_str = 'union'.join(queries)
    cursor.execute(query_str, params)

    word_ids = [row[0] for row in cursor.fetchall()]

    # add the word_ids into the word_strength table
    tup = []
    due_date = datetime.datetime.now() + datetime.timedelta(days=10 * 365)

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
    due_date = datetime.datetime.now() + datetime.timedelta(days=10 * 365)

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

    due_date = datetime.datetime.now() + datetime.timedelta(minutes=1)

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
