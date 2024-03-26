import google.cloud.firestore
from datetime import datetime
from firebase_admin import firestore, storage


class Account:
    def __init__(self, account_id):
        self.message_path = f"account/{account_id}/message"
        self.account_ref = firestore.client().collection("account").document(account_id)
        self.messages_ref = self.account_ref.collection("message")

    def new_message(self, text, author):
        return self.messages_ref.add({
            "time": datetime.now(),
            "text": text,
            "author": author
        })[1].id

    def set_message(self, key, text, author):
        self.messages_ref.document(key).set({
            "time": datetime.now(),
            "text": text,
            "author": author
        })

    def get_conversation(self):
        max_messages = 5

        stream = self.messages_ref.order_by("time", direction=firestore.Query.DESCENDING).limit(max_messages).stream()
        ordered_documents = [doc.to_dict() for doc in reversed(list(stream))]

        messages = []
        for document in ordered_documents:
            messages.append({
                'role': 'user' if document['author'] else 'assistant',
                'content': document['text']
            })
        return messages

    def store_audio(self, message_id, audio):
        bucket = storage.bucket()
        path = f"{self.message_path}/{message_id}/robot.mp3"
        blob = bucket.blob(path)
        blob.upload_from_string(audio)

    def complete_audio(self, message_id, audio_path):
        self.messages_ref.document(message_id).update({
            "audio": audio_path
        })
