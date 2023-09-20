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
