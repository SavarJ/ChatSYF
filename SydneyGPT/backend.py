import openai
import os
import sys
from dotenv import load_dotenv
load_dotenv()

openai.api_key = os.getenv("OPENAI_API_KEY")

def transcribe_audio_to_text(audio_file_path):
    print("hi", audio_file_path[7:])
    try:
        audio_file = open(audio_file_path[7:], "rb")
    except:
        return {"status": "ERROR", "message": "File not found"}
    
    try:
        transcript = openai.Audio.translate("whisper-1", audio_file)
        print(transcript.text + "LOL")
        return str(transcript.text)

        


    except:
        return {"status": "ERROR", "message": "Something went wrong"}
    

def hello_world(hi):
    return "yo lol"


from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/transcribe", methods=["POST"])
def transcribe():
    print("Request received")
    audio_file_path = request.json["audio_file_path"]
    return jsonify(transcribe_audio_to_text(audio_file_path))
    

if __name__ == "__main__":
    app.run(debug=True)