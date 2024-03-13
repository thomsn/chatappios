from firebase_admin import firestore, initialize_app
from firebase_functions.firestore_fn import (
    on_document_created,
    Event,
    DocumentSnapshot
)
from firebase_functions import logger
from firebase_functions.params import SecretParam

from account import Account
from comedian import Comedian

initialize_app()
OPEN_AI_KEY = SecretParam('OPENAI_KEY')


@on_document_created(document="account/{account_id}/message/{message_id}", region="us-east1", secrets=[OPEN_AI_KEY])
def new_message(event: Event[DocumentSnapshot]):

    account = Account(event.params["account_id"])

    message = event.data.to_dict()

    if 'author' in message and message['author']:

        comedian = Comedian(OPEN_AI_KEY.value)

        conversation = account.get_conversation()

        logger.log(f"conversation {conversation}")

        joke = comedian.be_funny(conversation)

        logger.log(f"joke {joke}")

        account.new_message(joke)
