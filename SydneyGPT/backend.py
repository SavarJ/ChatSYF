import openai
import os
import sys
from dotenv import load_dotenv
load_dotenv()

openai.api_key = os.getenv("OPENAI_API_KEY")

def transcribe_audio_to_text(audio_file_path, messages):
    print("hi", audio_file_path[7:])
    try:
        audio_file = open(audio_file_path[7:], "rb")
    except:
        return {"status": "ERROR", "message": "File not found"}
    
    try:
        
        transcript = openai.Audio.translate("whisper-1", audio_file)
        print(transcript.text + "LOL")
        # return str(transcript.text)
        user_messages = [{"role": "user", "content": str(transcript.text)}]

        system_message = """Using this conversation given, choose which of the following categories the text would fall under. 
        Pretend like you are talking directly to the customer and not to the developer.
        Would it be 1)Account access and balance inquiries, 2)Lost or stolen card reporting, 3)Payment inquiries and options, 4)New account applications, 
        5)Credit line increases or decreases, 6)Disputes and fraud reporting, 7)Credit limit changes, 8) Account updates and personal information changes, 9) Interest rates and fees inquiries, or 10) General customer service inquiries?
        If the category you choose is 'Other', do not mention that. Do not put the category in quotes. 
        At the end of your response, ask if this is correct and if they'd like to be transferred over to the department.
        
        
        If the customer seems to have agreed that they would be transferred to the right department, tell them that you have placed a call on their behalf and they will be getting a call back shortly.
        """

        assistant_messages = [{"role" : "assistant", "content" : m} for i, m in enumerate(messages) if i % 2 == 0]
        user_messages += [{"role" : "user", "content" : m} for i, m in enumerate(messages) if i % 2 == 1]
        all = assistant_messages + user_messages + [{"role" : "assistant", "content" : system_message}]
        print(all)
        completion = openai.ChatCompletion.create(
             model="gpt-3.5-turbo",
            messages=all,
        )
        return transcript.text + "IAMGREAT" + completion.choices[0].message.content

        
    except:
        return {"status": "ERROR", "message": "Something went wrong"}
    

def hello_world(hi):
    return "yo lol"


from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/transcribe", methods=["POST"])
def transcribe():
    print("Request received")
    audio_file_path, messages = request.json["audio_file_path"], request.json["convo"]
    return jsonify(transcribe_audio_to_text(audio_file_path, messages))
    

if __name__ == "__main__":
    app.run(debug=True)