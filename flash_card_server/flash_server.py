from flask import Flask, json, request, jsonify
import os
import PyPDF2
import google.generativeai as genai
from flask_cors import CORS
import pandas as pd
import datetime
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
CORS(app)
genai.configure(api_key="AIzaSyBJJQMsJbz5wTUgTe1615WUkMFEJaNyCG0")
model = genai.GenerativeModel(
    "gemini-1.5-flash", generation_config={"response_mime_type": "application/json"}
)

app.config["SQLALCHEMY_DATABASE_URI"] = "postgresql://postgres:root18@localhost/senDB"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)


# Define the LoginCreds model
class LoginCreds(db.Model):
    __tablename__ = "login_creds"

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(255), nullable=False)
    password = db.Column(db.String(255), nullable=False)

class FileInfo(db.Model):
    __tablename__ = "file_info"

    id = db.Column(db.Integer, primary_key=True)
    file_path = db.Column(db.String(255), nullable=False)
    file_type = db.Column(db.String(50), nullable=False)
    status = db.Column(db.String(50), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.datetime.utcnow, nullable=False)
    active = db.Column(db.Boolean, default=True, nullable=False)


# Initialize the database
with app.app_context():
    db.create_all()


def process_and_send_to_gemini(filepath):
    text = ""
    print(f"Processing file: {filepath}")

    # Extract text from PDF
    with open(filepath, "rb") as pdf_file:
        pdf_reader = PyPDF2.PdfReader(pdf_file)
        for page in pdf_reader.pages:
            text += page.extract_text()

    print(
        f"Extracted text: {text[:500]}..."
    )  # Print first 500 characters for debugging

    if text:
        # Send the text to Gemini API
        response = model.generate_content(
            json.dumps(
                {
                    "instructions": [
                        "Here is an article. Please read it carefully and then answer the following questions: ",
                        "1. Identify the main topics discussed in the article.",
                    ],
                    "text": text,
                    "desired_output": [
                        "For each identified topic, generate 3 multiple-choice questions with only easy and hard difficulty levels.",
                        "You should have a maximum of 4 topics.",
                        "Structure the output in the following JSON format:",
                        "{topicname: {questionNumber: {question: 'question here', difficultyLevel: 'difficulty', answer: 'answer here', options: ['4 options here']}}}",
                    ],
                    "examples": {
                        "good": [
                            {
                                "Neural Networks": {
                                    "1": {
                                        "question": "What is a neural network inspired by?",
                                        "difficultyLevel": "easy",
                                        "answer": "Biological neural networks",
                                        "options": [
                                            "Biological neural networks",
                                            "Mechanical systems",
                                            "Quantum computing",
                                            "Traditional algorithms",
                                        ],
                                    },
                                    "2": {
                                        "question": "Which learning method involves the network adjusting weights based on errors?",
                                        "difficultyLevel": "hard",
                                        "answer": "Supervised learning",
                                        "options": [
                                            "Unsupervised learning",
                                            "Reinforcement learning",
                                            "Supervised learning",
                                            "Semi-supervised learning",
                                        ],
                                    },
                                    "3": {
                                        "question": "What is a key feature of recurrent neural networks?",
                                        "difficultyLevel": "easy",
                                        "answer": "Information flows in a loop",
                                        "options": [
                                            "Information flows in a loop",
                                            "Information flows in one direction",
                                            "They are used for image recognition",
                                            "They have a fixed number of layers",
                                        ],
                                    },
                                }
                            },
                            {
                                "Evolution and Biological Inspiration": {
                                    "1": {
                                        "question": "What inspired the development of neural networks?",
                                        "difficultyLevel": "easy",
                                        "answer": "The brain's ability to solve complex problems",
                                        "options": [
                                            "The brain's ability to solve complex problems",
                                            "Advancements in traditional computing",
                                            "Development of new programming languages",
                                            "Increased data storage capabilities",
                                        ],
                                    },
                                    "2": {
                                        "question": "When did significant advances in neural networks occur?",
                                        "difficultyLevel": "hard",
                                        "answer": "Late 1980s",
                                        "options": [
                                            "Early 1940s",
                                            "Late 1980s",
                                            "Early 2000s",
                                            "Late 1990s",
                                        ],
                                    },
                                    "3": {
                                        "question": "What function do synapses serve in a neuron?",
                                        "difficultyLevel": "easy",
                                        "answer": "Connect axons to dendrites",
                                        "options": [
                                            "Connect axons to dendrites",
                                            "Process information",
                                            "Transmit electrical signals",
                                            "Store memories",
                                        ],
                                    },
                                }
                            },
                            {
                                "Training Methods": {
                                    "1": {
                                        "question": "Which learning method involves the network self-organizing based on input features?",
                                        "difficultyLevel": "hard",
                                        "answer": "Unsupervised learning",
                                        "options": [
                                            "Supervised learning",
                                            "Unsupervised learning",
                                            "Reinforcement learning",
                                            "Semi-supervised learning",
                                        ],
                                    },
                                    "2": {
                                        "question": "What is the primary goal of supervised learning?",
                                        "difficultyLevel": "easy",
                                        "answer": "Adjust weights based on errors",
                                        "options": [
                                            "Adjust weights based on errors",
                                            "Self-organize based on input features",
                                            "Maximize reward signals",
                                            "Minimize training time",
                                        ],
                                    },
                                    "3": {
                                        "question": "What type of neural network is suitable for time-series forecasting?",
                                        "difficultyLevel": "hard",
                                        "answer": "Recurrent neural networks",
                                        "options": [
                                            "Feedforward neural networks",
                                            "Recurrent neural networks",
                                            "Auto-associative neural networks",
                                            "Convolutional neural networks",
                                        ],
                                    },
                                }
                            },
                        ],
                        "bad": [
                            {
                                "Neural Networks": {
                                    "question1": {
                                        "question": "What is the color of the sky?",
                                        "difficultyLevel": "easy",
                                        "answer": "Blue",
                                        "options": ["Blue", "Green", "Red", "Yellow"],
                                    },
                                    "question2": {
                                        "question": "How many continents are there?",
                                        "difficultyLevel": "hard",
                                        "answer": "Seven",
                                        "options": ["Five", "Six", "Seven", "Eight"],
                                    },
                                    "3": {
                                        "question": "Which is the largest ocean?",
                                        "difficultyLevel": "easy",
                                        "answer": "Pacific Ocean",
                                        "options": [
                                            "Atlantic Ocean",
                                            "Indian Ocean",
                                            "Arctic Ocean",
                                            "Pacific Ocean",
                                        ],
                                    },
                                }
                            },
                            {
                                "Neural Networks": {
                                    "1": {
                                        "question": "What is it?",
                                        "difficultyLevel": "easy",
                                        "answer": "",
                                        "options": ["", "", "", ""],
                                    },
                                    "2": {
                                        "question": "Explain the concept.",
                                        "difficultyLevel": "hard",
                                        "answer": "",
                                        "options": ["", "", "", ""],
                                    },
                                    "3": {
                                        "question": "What do you think?",
                                        "difficultyLevel": "easy",
                                        "answer": "",
                                        "options": ["", "", "", ""],
                                    },
                                }
                            },
                        ],
                    },
                }
            )
        )
        print(
            f"Response from Gemini: {response.text[:500]}..."
        )  # Print first 500 characters of response for debugging
        return response.text  # Return the response from Gemini API
    else:
        return {"error": "No text extracted from document"}


UPLOAD_FOLDER = os.path.join(os.getcwd(), "uploads")
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)


@app.route("/store_data", methods=["POST"])
def upload_json():
    try:
        # Get JSON data from the request
        data = request.get_json()
        if not data:
            return jsonify({"error": "Invalid JSON data"}), 400

        # Check if the JSON data is a list of dictionaries
        if not isinstance(data, list) or not all(
            isinstance(item, dict) for item in data
        ):
            return jsonify({"error": "JSON data must be a list of dictionaries"}), 400

        # Convert JSON to DataFrame
        df = pd.DataFrame(data)

        # Generate a unique filename based on the current timestamp
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        excel_file_path = os.path.join(UPLOAD_FOLDER, f"data_{timestamp}.xlsx")
        csv_file_path = os.path.join(UPLOAD_FOLDER, f"data_{timestamp}.csv")

        # Save DataFrame to Excel and CSV files
        df.to_excel(excel_file_path, index=False)
        df.to_csv(csv_file_path, index=False)

        return (
            jsonify(
                {
                    "message": "File saved successfully",
                    "excel_path": excel_file_path,
                    "csv_path": csv_file_path,
                }
            ),
            200,
        )

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/process_document", methods=["POST"])
def process_doc():
    print("Enter process doc")
    print(request.files)  # Debugging line to print all files in the request

    # Get the uploaded file from the request
    if "document" not in request.files:
        return jsonify({"error": "No file uploaded"}), 400
    file = request.files["document"]
    print(f"Received file: {file.filename}")  # Debugging line to confirm file receipt

    # Save the file temporarily
    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)
    print(f"File saved to: {filepath}")

    # Process the document and send to Gemini
    response = process_and_send_to_gemini(filepath)

    # Remove the temporary file
    os.remove(filepath)
    print(f"File removed: {filepath}")

    # Return the response from Gemini
    return jsonify(response)


@app.route('/add_creds', methods=['POST'])
def add_creds():
    data = request.get_json()
    if not data or 'username' not in data or 'password' not in data:
        return jsonify({"error": "Invalid data"}), 400

    # Check if the user already exists
    existing_user = LoginCreds.query.filter_by(username=data['username']).first()
    if existing_user:
        return jsonify({"error": "User already exists"}), 409

    new_cred = LoginCreds(username=data['username'], password=data['password'])
    db.session.add(new_cred)
    db.session.commit()
    return jsonify({"message": "Credentials added successfully"}), 201

# POST endpoint to verify login credentials
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or 'username' not in data or 'password' not in data:
        return jsonify({"error": "Invalid data"}), 400

    # Find the user by username
    user = LoginCreds.query.filter_by(username=data['username']).first()
    if not user:
        return jsonify({"error": "User does not exist"}), 404

    # Check if the password matches
    if user.password != data['password']:
        return jsonify({"error": "Wrong password"}), 401

    return jsonify({"message": "Login successful"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
