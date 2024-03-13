from openai import OpenAI
import json


class Comedian:
    def __init__(self, key):
        self.ai_client = OpenAI(
            api_key=key
        )

    def be_funny(self, past_conversation):
        messages = [
            {
                "role": "system",
                "content": "You are a comedian. Make the conversation funny. Your output must be a JSON object with the "
                           "key [sentence] and the value of a single sentence."
            }
        ]
        messages.extend(past_conversation)

        return json.loads(self.ai_client.chat.completions.create(
            messages=messages,
            model="gpt-4-1106-preview",
            response_format={"type": "json_object"},
            max_tokens=100
        ).choices[0].message.content)["sentence"]
