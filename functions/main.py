from firebase_admin import firestore, initialize_app
from firebase_functions.firestore_fn import (
    on_document_created,
    Event,
    DocumentSnapshot
)
from firebase_functions import logger, storage_fn
from firebase_functions.params import SecretParam
import pathlib
from account import Account
from comedian import Comedian
from speech import Speech
initialize_app()
OPEN_AI_KEY = SecretParam('OPENAI_KEY')


@on_document_created(document="account/{account_id}/message/{message_id}", region="us-east4", secrets=[OPEN_AI_KEY])
def new_message(event: Event[DocumentSnapshot]):

    account = Account(event.params["account_id"])

    message = event.data.to_dict()

    if 'author' in message and message['author']:

        comedian = Comedian(OPEN_AI_KEY.value)

        conversation = account.get_conversation()

        logger.log(f"conversation {conversation}")

        joke = comedian.be_funny(conversation)

        logger.log(f"joke {joke}")

        joke_id = account.new_message(joke, False)

        audio = Speech().speak(joke)

        account.store_audio(joke_id, audio)


@storage_fn.on_object_finalized(region="us-east4")
def new_file(event: storage_fn.CloudEvent[storage_fn.StorageObjectData]):

    account_id = event.data.name.split("/")[1]

    message_id = event.data.name.split("/")[3]

    file_path = pathlib.PurePath(event.data.name)

    account = Account(account_id)

    gcs_uri = "gs://" + event.data.bucket + "/" + event.data.name

    if file_path.match("account/*/message/*/author.wav"):

        text = Speech().listen(gcs_uri)

        account.set_message(message_id, text, True)

    elif file_path.match("account/*/message/*/robot.mp3"):

        account.complete_audio(message_id, event.data.name)
