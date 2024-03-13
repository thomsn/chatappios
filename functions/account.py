import google.cloud.firestore
from datetime import datetime
from firebase_admin import firestore


class Account:
    def __init__(self, account_id):
        self.account_ref = firestore.client().collection("account").document(account_id)
        self.messages_ref = self.account_ref.collection("message")

    def new_message(self, text):
        self.messages_ref.add({
            "time": datetime.now(),
            "text": text,
            "author": False
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