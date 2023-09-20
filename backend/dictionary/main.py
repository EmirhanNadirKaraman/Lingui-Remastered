import os
import string
from functools import wraps

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
