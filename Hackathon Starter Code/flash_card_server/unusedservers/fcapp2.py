from flask import Flask, request, jsonify
import os
import google.generativeai as genai
from flask_cors import CORS
import uuid
import PyPDF2
import time

app = Flask(__name__)
CORS(app)

genai.configure(api_key="AIzaSyBJJQMsJbz5wTUgTe1615WUkMFEJaNyCG0")
model = genai.GenerativeModel(
    "gemini-1.5-flash", generation_config={"response_mime_type": "application/json"}
)

# In-memory storage for documents
master_dictionary = {"ids": []}


# Helper function to extract text from PDF
def extract_text_from_pdf(filepath):
    text = ""
    try:
        with open(filepath, "rb") as pdf_file:
            pdf_reader = PyPDF2.PdfReader(pdf_file)
            for page in pdf_reader.pages:
                text += page.extract_text() or ""  # Safeguard against NoneType
    except Exception as e:
        print(f"Error extracting text from PDF: {e}")
    return text


@app.route("/get_document", methods=["POST"])
def send_data():
    if "file" not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files["file"]

    if file.filename == "":
        return jsonify({"error": "No selected file"}), 400

    extension = os.path.splitext(file.filename)[1].lower()
    if extension != ".pdf":
        return jsonify({"error": "Unsupported file format, only PDFs are allowed"}), 400

    # Define the upload directory
    upload_folder = "C:/Users/Naindeep/Desktop/SOUL/SEN-DSU/flash_card_server/uploads"
    os.makedirs(upload_folder, exist_ok=True)

    # Generate a unique filename using the current timestamp in seconds
    filename = f"uploaded_{int(time.time())}.pdf"
    filepath = os.path.join(upload_folder, filename)

    try:
        file.save(filepath)
        text = extract_text_from_pdf(filepath)
        os.remove(filepath)  # Clean up file after processing
    except Exception as e:
        print(f"Error handling file: {e}")
        return jsonify({"error": "Error processing file"}), 500

    if text:
        try:
            response = model.generate_content(
                """{
                    "instructions": [
                    "Here is an article. Please read it carefully and then answer the following questions: ",
                    "1. Identify the main topics discussed in the article."
                    ],
                    "text":"""
                + text
                + """,
                    "desired_output": [
                    "For each identified topic, generate 3 multiple-choice questions with only easy and hard difficulty level ",
                    "Structure the output in the following JSON format:",
                    "{topicname: {questionnumber: {question: 'question here', difficultylevels: 'difficulty', answer: 'answer here', options: ['4 options here']}}, names: ['all topic name here']}"
                    ]
                    }"""
            )
            response_content = response.text
        except Exception as e:
            print(f"Error generating content: {e}")
            return jsonify({"error": "Error generating content from AI"}), 500

        doc_id = str(uuid.uuid4())
        master_dictionary[doc_id] = {"content": response_content, "name": filename}
        master_dictionary["ids"].append(doc_id)

        print(master_dictionary)
        return {"ids": master_dictionary["ids"], **{doc_id: master_dictionary[doc_id]}}

    else:
        return jsonify({"error": "No text extracted from document"})


if __name__ == "__main__":
    app.config["uploads"] = "../uploads"  # Set the uploads folder
    app.run(host="0.0.0.0", port=5000)
