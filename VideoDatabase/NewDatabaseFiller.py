import json
import string
import copy
import os

import psycopg2
from scrapetube import scrapetube

from youtube_transcript_api import YouTubeTranscriptApi, NoTranscriptFound, TranscriptsDisabled
import spacy

# !pip install google-api-python-client
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

from langdetect import detect

import config

config.set_values()


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
        "sv": "sv_core_news_sm",
    }

    if language not in lang_model_map:
        raise Exception(f"Language {language} not supported")

    print(f"{language} model loaded")
    return spacy.load(lang_model_map[language])


def insert_all_words_into_word_to_sentence_table(word_set, sentence_id, language):
    """
    This function returns a string of insert queries for unique words in a sentence
    (words will be inserted in bulk in the parent function).
    The words are parsed before calling this function, so they are lowercase, and their punctuation is removed.

    param word_set: the set of processed words
    param sentence_id: the id of the sentence
    param language: the language of the sentence
    """

    """word[0] = token
    word[1] = pos
    word[2] = lemma
    word[3] = tag
    """

    word_id = None
    tup = []

    for word in word_set:
        cursor.execute("SELECT word_id "
                       "FROM word_table "
                       "WHERE word = %s AND "
                       "language = %s AND "
                       "pos = %s", (word[0], language, word[1]))

        # guaranteed to exist in database
        word_id = cursor.fetchone()

        tup.append((word_id, sentence_id))

    return b','.join(cursor.mogrify("(%s,%s)", x) for x in tup)


def insert_all_sentences_into_sentence_table(video_id, transcript, nlp, sentence_types):
    """
    This function inserts (in bulk) all (cleaned) sentences in the transcript of a video.
    The sentences in the transcript are cleaned from newlines and extra spaces.

    This function also stores the sentence types according to the word properties in a separate table.

    param video_id: the id of the video
    param transcript: the transcript of the video
    param nlp: the nlp model from spacy
    param sentence_types: sentence type information as a dictionary (for fast access)
    """

    # list of parts of speech that we want to store in sentence properties
    pos_list = ['VERB', 'ADJ', 'NOUN', 'ADV', 'PRON']

    # languages for which we do not want to store morphological information
    no_morph_language_list = ['ja', 'ko']

    # find the language of the video
    cursor.execute("SELECT language "
                   "FROM video "
                   "WHERE video_id = %s", (video_id,))

    language = cursor.fetchone()[0]

    # insert all sentences in bulk
    tup = [(video_id, sentence['start'], sentence['duration'],
            clean_sentence(sentence['text']), [token.text for token in nlp(sentence['text'])
                                               if token.pos_ != 'PUNCT' and token.text.strip() != ''])
           for sentence in transcript]

    types = []
    # get the current value of sentence_id
    cursor.execute("SELECT currval('sentence_id_seq')")
    cur_sentence_id = cursor.fetchone()[0]

    # add the sentence information into the sentence table, too.
    # insert all word information there
    if language not in no_morph_language_list:
        for sentence in transcript:
            cur_sentence_id += 1

            for token in nlp(sentence['text']):
                if token.pos_ in pos_list:
                    morph_dict = token.morph.to_dict()

                    for word_property in morph_dict:
                        rule = token.pos_ + str(word_property) + str(morph_dict[word_property])
                        rule_id = sentence_types.get(language + '_' + rule, -1)

                        # sentence type not encountered before
                        if rule_id == -1:
                            print(language, token, token.pos_, word_property, morph_dict[word_property])
                            cursor.execute("INSERT INTO grammar_rule (rule, language) VALUES (%s,%s) RETURNING rule_id",
                                           (rule, language))
                            rule_id = cursor.fetchone()[0]
                            sentence_types[language + '_' + rule] = rule_id

                        # print(cur_sentence_id, type_id)
                        types.append((cur_sentence_id, rule_id))

    args_str = b','.join(cursor.mogrify("(%s,%s,%s,%s,%s)", x) for x in tup)
    type_str = b','.join(cursor.mogrify("(%s,%s)", x) for x in types)

    cursor.execute(b"INSERT INTO sentence (video_id, start_time, duration, content, tokens) VALUES " + args_str)

    # if types is not empty, insert the sentence types
    if types:
        cursor.execute(b"INSERT INTO sentence_to_grammar_rule (sentence_id, rule_id) VALUES " + type_str +
                       b"ON CONFLICT DO NOTHING")


def get_word_set(sentence, nlp):
    """
    The function takes in a sentence, and returns the set of words in the sentence.
    The words are cleaned from punctuation and special characters, and are lowered.

    param sentence: the sentence to be processed
    """
    sentence = clean_sentence(sentence=sentence)
    doc = nlp(sentence)
    word_set = set()

    for token in doc:
        if token.pos_ != 'PUNCT':
            word_set.add((token.text, token.pos_, token.lemma_, token.tag_))

    return word_set


def clean_sentence(sentence):
    """
    This function returns the given sentence with all newlines and extra spaces removed.

    param sentence: the sentence to be cleaned
    """
    sentence = sentence.replace('\n', ' ').replace('\xa0', ' ').replace('\u00a0', ' ')

    return " ".join(sentence.split())


def insert_all_words_into_word_table(db_words, word_set, language):
    """
    This function returns a string of insert queries for unique words in a sentence.
    Words in the sentence will be inserted in bulk in the parent function.

    db_words is also a parameter in order to update its content with the new words.

    param db_words: the set of words already in the database
    param word_set: the set of words in the sentence
    param language: the language of the sentence
    """
    word_set = set(filter(lambda word: word not in db_words, word_set))

    for word in word_set:
        db_words.add(word)

    print("*" * 100, "\n", len(word_set), len(set(word_set)))

    # insert all words in bulk
    tup = [(word[0], language, word[1], word[2], word[3]) for word in word_set]
    return b','.join(cursor.mogrify("(%s,%s,%s,%s,%s)", x) for x in tup)


def update_video_table(video_id, title, thumbnail_url, duration, video_language, dialect, category=None):
    """
    This function inserts the new video table with the given video info.

    param video_id: the id of the video
    param title: the title of the video
    param thumbnail_url: the thumbnail url of the video
    param duration: the duration of the video
    param video_language: the language of the video     (example: en)
    param dialect: the dialect of the video             (example: en-US, en-GB)
    """
    # if video already exists, return
    cursor.execute("SELECT * FROM video WHERE video_id = %s", (video_id,))
    if cursor.rowcount != 0:
        return

    cursor.execute("INSERT INTO video (video_id, title, thumbnail_url, duration, language, dialect, category) "
                   "VALUES (%s, %s, %s, %s, %s, %s, %s)",
                   (video_id, title, thumbnail_url, duration, video_language, dialect, category))


def populate(db_words, video_id, title, thumbnail_url, transcript,
             video_language, dialect, nlp, category, sentence_types):
    """
    This function populates the database with the given video info, and calls the appropriate functions
    for filling the video, sentence and word tables.

    param db_words: the set of words already in the database
    param video_id: the id of the video
    param title: the title of the video
    param thumbnail_url: the thumbnail url of the video
    param transcript: the transcript of the video
    param video_language: the language of the video     (example: en)
    param dialect: the dialect of the video             (example: en-US, en-GB)
    """

    args = []
    last_sentence = transcript[-1]

    # add video to video table
    update_video_table(video_id=video_id, title=title, thumbnail_url=thumbnail_url,
                       duration=last_sentence["start"] + last_sentence["duration"],
                       video_language=video_language, dialect=dialect, category=category)

    cursor.execute("SELECT nextval FROM nextval('sentence_id_seq')")
    sentence_id = cursor.fetchone()[0] + 1
    copy_ = sentence_id

    insert_all_sentences_into_sentence_table(video_id=video_id,
                                             transcript=transcript,
                                             nlp=nlp,
                                             sentence_types=sentence_types)

    print("old sentence id: ", sentence_id)

    # insert each sentence and its related info to the sentence table
    video_word_set = set()

    # The words have to be inserted into the word table first.
    for sentence in transcript:
        word_set = get_word_set(sentence['text'], nlp=nlp)
        sentence_id += 1
        video_word_set.update(word_set)

    print(video_word_set)

    word_arg_str = insert_all_words_into_word_table(db_words=db_words,
                                                    word_set=video_word_set,
                                                    language=video_language)

    if word_arg_str != b'':
        cursor.execute(
            b"INSERT INTO word_table (word, language, pos, lemma, tag) VALUES " + word_arg_str +
            b" ON CONFLICT DO NOTHING")

    connection.commit()

    sentence_id = copy_

    # Now we can insert the word_ids into the word_to_sentence table.
    for sentence in transcript:
        word_set = get_word_set(sentence['text'], nlp=nlp)
        args.append(insert_all_words_into_word_to_sentence_table(word_set,
                                                                 sentence_id,
                                                                 video_language))
        sentence_id += 1

        video_word_set.update(word_set)

    args = filter(lambda arg: arg != b'', args)
    arg_str = b','.join(args)

    if arg_str != b'':
        cursor.execute(
            b"INSERT INTO word_to_sentence (word_id, sentence_id) VALUES " + arg_str + b" ON CONFLICT DO NOTHING")

    connection.commit()


def get_transcript(video_id, language):
    transcript = None

    language_map = {
        "en": ["en-GB", "en", "en-US"],
        "de": ["de", "de-DE", "de-AT"],
        "fr": ["fr", "fr-FR", "fr-CA"],

        # not sure if this works, commented out for now
        # "es": ["es", "es-ES", "es-MX", "es-419", "es-CO", "es-AR", "es-CL",
        #       "es-PE", "es-VE", "es-CR", "es-EC", "es-PA",],

        "es": ["es", "es-ES", "es-MX", "es-419"],
        # "it": ["it", "it-IT", "it-CH"],
        "it": ["it", "it-IT"],
        "pt-pt": ["pt-PT"],
        "pt-br": ["pt-BR"],
        "pt": ["pt"],
        "ru": ["ru", "ru-RU", "ru-UA"],
        "ja": ["ja", "ja-JP"],
        "ko": ["ko", "ko-KR"],

        # TODO: add swedish and polish just for the fun of it
    }

    try:
        transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)

        if language in language_map:
            transcript = transcript_list.find_manually_created_transcript(language_map[language])

    except NoTranscriptFound:
        print("No transcript found for this video")

    except TranscriptsDisabled:
        print("Transcripts are disabled for this video")

    except:
        print("Unexpected error.")

    return transcript


def youtube_authenticate():
    api_service_name = "youtube"
    api_version = "v3"
    developer_key = os.getenv("YOUTUBE_API_KEY")

    youtube = build(api_service_name, api_version, developerKey=developer_key)

    return youtube


def get_video_categories(video_id):
    youtube = youtube_authenticate()
    response = youtube.videos().list(
        part="snippet",
        id=video_id
    ).execute()

    # extract category ID
    if response['items'] == []:
        return None

    category_id = response["items"][0]["snippet"]["categoryId"]

    # use categories().list() method to get category information
    category_response = youtube.videoCategories().list(
        part="snippet",
        id=category_id
    ).execute()

    # extract category name
    category_name = category_response["items"][0]["snippet"]["title"]

    return category_name


def main():
    # we do not have korean support for now
    language_list = ["en", "de", "fr", "es", "it", "ru", "ja", "pt", "pl", "sv"]

    channel_dict = json.load(open("channels.json", "r"))

    video_per_channel = 1

    # find the blacklist
    cursor.execute("SELECT * FROM video_blacklist")
    blacklist = set([video[0] for video in cursor.fetchall()])

    # find the already processed (video) list
    cursor.execute("SELECT video_id FROM video")
    processed_list = set([video[0] for video in cursor.fetchall()])

    # find the already processed channel list
    cursor.execute("SELECT channel_id, channel_name FROM processed_channel")
    processed_channel_list = set([(channel[0], channel[1]) for channel in cursor.fetchall()])

    # find the grammar rules that we already have
    cursor.execute("SELECT * FROM grammar_rule")
    sentence_types = dict()
    for res in cursor.fetchall():
        sentence_types[res[2] + '_' + res[1]] = res[0]

    # number of channels that we have
    total_len = 0
    for _, value in channel_dict.items():
        if value:
            total_len += len(value)

    while True:
        if len(processed_channel_list) == total_len:
            break

        for language in channel_dict:
            print("language is:", language)
            print("channel_dict[language] is:", channel_dict[language])
            nlp = load_model(language)

            count = 0
            for channel in channel_dict[language]:
                channel_id = channel["id"]
                channel_name = channel["name"]

                if (channel_id, channel_name) in processed_channel_list:
                    continue

                videos = scrapetube.get_channel(channel_id)

                cursor.execute("SELECT word, pos, lemma FROM word_table")
                db_words = set([(word[0], word[1], word[2]) for word in cursor.fetchall()])

                print(channel_id, channel_name)
                print("=====================================")

                # count = (the number of videos with subtitles in audio language)
                count = 0
                for index, video in enumerate(videos):
                    if count == video_per_channel:
                        print()
                        break

                    # check if video is in video_blacklist
                    if video["videoId"] in blacklist:
                        print(f"{index} video with id {video['videoId']} is blacklisted")
                        continue

                    # if video is already processed, do not process again
                    if video["videoId"] in processed_list:
                        print(f"{index} video with id {video['videoId']} is already processed")
                        continue

                    transcript = get_transcript(video["videoId"], language)

                    if transcript is not None:
                        count += 1
                        print(index, video["title"]["runs"][0]["text"])

                        # TODO: make category = None when API key does not have quota left
                        # get category
                        category = get_video_categories(video["videoId"])

                        # get title
                        title = video['title']['runs'][0]['text']
                        if language == 'tr' and detect(title) == 'tr':
                            title = update_video_title(video["videoId"])

                        """title = update_video_title(video["videoId"]) \
                            if (language == 'tr' and detect(title) == 'tr') else title"""

                        populate(db_words=db_words,
                                 video_id=video["videoId"],
                                 title=title,
                                 thumbnail_url=video['thumbnail']['thumbnails'][-1]['url'],
                                 transcript=transcript.fetch(),
                                 video_language=language,
                                 dialect=transcript.language_code,
                                 nlp=nlp,
                                 category=category,
                                 sentence_types=sentence_types)

                        processed_list.add(video["videoId"])

                    else:
                        # add video to video_blacklist
                        print(index)
                        cursor.execute("INSERT INTO video_blacklist (video_id) VALUES (%s)", (video["videoId"],))
                        # blacklist_args.append(video["videoId"])
                        blacklist.add(video["videoId"])

                if count != video_per_channel:
                    processed_channel_list.add((channel_id, channel_name))

                    # check if channel is in processed_channel
                    cursor.execute("SELECT channel_id FROM processed_channel WHERE channel_id = %s", (channel_id,))
                    if cursor.fetchone() is not None:
                        continue

                    # add channel_id to channel_blacklist
                    cursor.execute("INSERT INTO processed_channel (channel_id, channel_name) VALUES (%s, %s)",
                                   (channel_id, channel_name))

                # update_token_ids_in_sentence(language_list)
                connection.commit()

                print("channels that are done parsing atm: ", processed_channel_list)


def update_video_title(video_id):
    youtube = youtube_authenticate()
    response = youtube.videos().list(
        part="snippet",
        id=video_id
    ).execute()

    video_title = response['items'][0]['snippet']['title']
    return video_title


def update_token_ids_in_sentence(language_list):
    for language in language_list:
        nlp = load_model(language)

        cursor.execute("SELECT S.sentence_id, S.content "
                       "FROM sentence S, video V "
                       "WHERE "
                       "    S.video_id = V.video_id AND"
                       "    V.language = %s AND "
                       "    S.token_ids IS NULL", (language,))

        result = cursor.fetchall()

        all_sentences = [{
            "sentence_id": sentence[0],
            "content": sentence[1]
        } for sentence in result]

        for index, sentence in enumerate(all_sentences):
            tokens = nlp(sentence['content'])

            word_id_arr = []

            for token in tokens:
                word = token.text
                pos = token.pos_

                if pos != 'PUNCT':
                    cursor.execute("SELECT word_id "
                                   "FROM word_table "
                                   "WHERE "
                                   "    word = %s AND "
                                   "    pos = %s AND "
                                   "    language = %s", (word, pos, language))

                    word_id_arr.append(cursor.fetchone()[0])

            print(sentence['sentence_id'], sentence['content'], word_id_arr)

            # we have the ids, lets insert them into the sentence table
            cursor.execute("UPDATE sentence SET token_ids = %s "
                           "WHERE sentence_id = %s", (word_id_arr, sentence['sentence_id']))

            if index % 100 == 0:
                connection.commit()

        connection.commit()


# database will be populated once, then it will be commented out
if __name__ == "__main__":
    main()

    # we do not have korean support for now
    language_list = ["en", "de", "fr", "es", "it", "ru", "ja", "pt", "pl", "sv"]

    # update_token_ids_in_sentence(language_list)
