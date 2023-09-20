import datetime
import json
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

    language = data['language']
    word_count = data['word_count']

    # get all learnable languages
    cursor.execute("select language "
                   "from language_table "
                   "where is_learnable = true")

    all_learnable_languages = [row[0] for row in cursor.fetchall()]

    if language not in all_learnable_languages:
        return jsonify({'success': False, 'error': 'Language is not learnable'}), 400

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
