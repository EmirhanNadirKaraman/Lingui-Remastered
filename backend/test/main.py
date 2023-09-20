import datetime
import os
import random
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


@app.route('/learn-top-words', methods=['POST'])
@err_handling_decorator
def learn_top_words():
    """This function adds new words to the user's vocabulary.
    This is a test function.

    param uid: the id of the user
    param language: the language of the words
    param no_of_words: the number of new words to be added to the user
    """

    data = request.json

    uid = data['uid']
    language = data['language']
    no_of_words = data['no_of_words']

    # check if language is in the user's language list
    cursor.execute("SELECT * "
                   "FROM user_learned_language "
                   "WHERE "
                   "    uid = %s "
                   "    AND learned_language = %s", (uid, language))

    result = cursor.fetchone()

    if result is None:
        return jsonify({'success': False,
                        'error': f"Language does not exist in user {str(uid)}'s list "
                                 f"of learned languages."}), 400

    # get the user's words
    cursor.execute("SELECT WS.word_id "
                   "FROM word_strength WS, word_table WT "
                   "WHERE "
                   "    WS.word_id = WT.word_id AND "
                   "    uid = %s "
                   "    AND language = %s "
                   "    AND strength = 8",
                   (uid, language))

    user_words = set([x[0] for x in cursor.fetchall()])

    # get the most frequent words in that language
    cursor.execute("SELECT WT.word_id, word, count(*) as cnt "
                   "FROM word_to_sentence WTS, word_table WT "
                   "WHERE "
                   "    WTS.word_id = WT.word_id AND "
                   "    WT.language = %s "
                   "GROUP BY WT.word_id "
                   "ORDER BY count(*) DESC "
                   "LIMIT %s",
                   (language, no_of_words))

    freq_words = [word[0] for word in cursor.fetchall()]

    # bulk insert the words
    tuples = []

    count = 0  # counts the number of new words added to the list

    for index, word_id in enumerate(freq_words):
        # check if word is already in the list
        if word_id in user_words:
            continue

        due_date = datetime.datetime.now() + datetime.timedelta(days=365 * 10)
        tuples.append((uid, word_id, 8, due_date))

        count += 1

        if count == no_of_words:
            break

    arg_str = b','.join(cursor.mogrify("(%s,%s,%s,%s)", x) for x in tuples)

    if arg_str != b'':
        cursor.execute(b"INSERT INTO word_strength (uid, word_id, strength, due_date) " +
                       b"VALUES " + arg_str + b" ON CONFLICT DO NOTHING")

    connection.commit()
    return jsonify({'success': True}), 200


@app.route('/videos', methods=['GET'])
@err_handling_decorator
def get_videos():
    """This function returns all videos in the database.
    This is a test function."""
    cursor.execute("SELECT video_id FROM video")
    return cursor.fetchall()


@app.route('/test-database', methods=['GET'])
@err_handling_decorator
def test_database():
    # write a function that adds 100 users to the database, teaches them a language,
    # and gives them random scores in the leaderboard table. don't forget to delete these users after the test

    user_table_tup = []
    user_learned_language_tup = []

    # add 100 users into the database with random names and user ids, using mogrify
    for i in range(100):
        uid = str(i)
        username = str(i)
        email = f'{str(i)}@gmail.com'

        # get a random value from the list
        language = random.choice(['en', 'fr'])

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
        score = random.randint(0, 100)

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
    cursor.execute("DELETE FROM user_table WHERE uid NOT IN %s ", (user_list,))
    connection.commit()

    return jsonify({'success': True}), 200
