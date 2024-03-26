from google.cloud import speech_v2, texttospeech
import os

project_id = os.environ.get('GCP_PROJECT')


class Speech:

    def __init__(self):
        self.client = speech_v2.SpeechClient()

    def listen(self, gcs_uri):
        config = speech_v2.types.cloud_speech.RecognitionConfig(
            auto_decoding_config=speech_v2.types.cloud_speech.AutoDetectDecodingConfig(),
            language_codes=["en-US"],
            model="long",
            features=speech_v2.types.cloud_speech.RecognitionFeatures(
                enable_automatic_punctuation=True
            ),
        )

        request = speech_v2.types.cloud_speech.RecognizeRequest(
            recognizer=f"projects/{project_id}/locations/global/recognizers/_",
            config=config,
            uri=gcs_uri
        )

        text = ""
        for res in self.client.recognize(request=request).results:
            text += res.alternatives[0].transcript

        return text

    def speak(self, text):
        client = texttospeech.TextToSpeechClient()

        synthesis_input = texttospeech.SynthesisInput(text=text)

        voice = texttospeech.VoiceSelectionParams(
            language_code="en-US", ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL
        )

        audio_config = texttospeech.AudioConfig(
            audio_encoding=texttospeech.AudioEncoding.MP3
        )

        response = client.synthesize_speech(
            input=synthesis_input, voice=voice, audio_config=audio_config
        )
        return response.audio_content
