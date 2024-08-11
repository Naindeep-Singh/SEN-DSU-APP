from flask import Flask, json, request, jsonify
import os
import requests
import google.generativeai as genai
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app = Flask(__name__)
genai.configure(api_key="AIzaSyBJJQMsJbz5wTUgTe1615WUkMFEJaNyCG0")
model = genai.GenerativeModel(
    "gemini-1.5-flash", generation_config={"response_mime_type": "application/json"}
)


def process_and_send_to_gemini(filepath):
    extension = os.path.splitext(filepath)[1].lower()
    text = ""

    if extension == ".pdf":
        # Use PyPDF2 for PDFs
        import PyPDF2

        with open(filepath, "rb") as pdf_file:
            pdf_reader = PyPDF2.PdfReader(pdf_file)
            for page in pdf_reader.pages:
                text += page.extract_text()
    elif extension == ".pptx":
        # Use python-pptx for PPTX (Not sending text to Gemini for PPTX as it's not well-suited for text processing)
        from pptx import Presentation

        prs = Presentation(filepath)
        print(
            "PPTX format is not ideal for text processing. Skipping sending text to Gemini."
        )
    elif extension == ".docx":
        # Use python-docx for DOCX
        from docx import Document

        doc = Document(filepath)
        for paragraph in doc.paragraphs:
            text += paragraph.text
    else:
        print("Unsupported file format")

    if text:
        # Send the text to Gemini API
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
"You should have a maximum of 4 topics"
"Structure the output in the following JSON format:",
"{topicname: {questionNumber: {question: "question here", difficultylevels: "difficulty", answer: "answer here", options: ["4 options here"]}}}"
]
}"""
        )
        return response.json()  # Return the response from Gemini API
    else:
        return {"error": "No text extracted from document"}


@app.route("/process_document", methods=["POST"])
def process_doc():
    # Get the uploaded file from the request
    if "document" not in request.files:
        return jsonify({"error": "No file uploaded"}), 400
    file = request.files["document"]

    # Save the file temporarily
    filepath = os.path.join(app.config["uploads"], file.filename)
    file.save(filepath)

    # Process the document and send to Gemini
    response = process_and_send_to_gemini(filepath)

    # Remove the temporary file
    os.remove(filepath)

    # Return the response from Gemini
    return jsonify(response)


@app.route("/get_document", methods=["GET"])
def send_data():
    text = """The "Harry Potter" series, written by J.K. Rowling, is a seven-book saga following the life of a young wizard named Harry Potter. The series is known for its intricate plot, rich world-building, and exploration of themes such as friendship, bravery, and the battle between good and evil. Here’s a detailed summary of each book in the series:

    ### 1. Harry Potter and the Philosopher's Stone (Sorcerer's Stone in the U.S.)

    **Plot Overview:**
    Harry Potter, an orphan living with his abusive aunt, uncle, and cousin, discovers on his eleventh birthday that he is a wizard. Hagrid, a giant who works at Hogwarts School of Witchcraft and Wizardry, delivers this news along with an invitation to attend the school. At Hogwarts, Harry learns about his parents' mysterious death at the hands of the dark wizard Voldemort and that he survived a killing curse from Voldemort as an infant, leaving him with a lightning-shaped scar on his forehead.

    **Key Events:**
    - Harry makes friends with Ron Weasley and Hermione Granger.
    - They discover the existence of the Philosopher's Stone, which grants immortality.
    - The trio unravels the mystery of the stone’s location within the school and prevents it from being stolen by Voldemort, who is trying to regain his physical form.

    ### 2. Harry Potter and the Chamber of Secrets

    **Plot Overview:**
    In his second year at Hogwarts, Harry finds that the school is plagued by mysterious attacks that leave students petrified. The legend of the Chamber of Secrets, a hidden chamber within the school said to house a monster, becomes central to the plot.

    **Key Events:**
    - Harry learns to communicate with snakes (Parseltongue) and finds out that he is linked to the founder of Slytherin house.
    - With Ron and Hermione, Harry discovers the Chamber of Secrets and confronts the monster, a giant basilisk.
    - He also meets Tom Riddle (Voldemort’s teenage self) in the form of a magical diary and destroys both the diary and the basilisk, saving Ginny Weasley.

    ### 3. Harry Potter and the Prisoner of Azkaban

    **Plot Overview:**
    In his third year, Harry learns that Sirius Black, a dangerous prisoner who escaped from Azkaban, is supposedly after him. As the year progresses, Harry uncovers the truth about his parents’ betrayal and the real identity of their friend and betrayer.

    **Key Events:**
    - The presence of Dementors at Hogwarts causes Harry to learn the Patronus Charm, a spell to ward off these dark creatures.
    - Harry discovers that Sirius Black is his godfather and was wrongly accused of betraying his parents.
    - With Hermione’s help, using a time-turner, Harry rescues Sirius and Buckbeak, a hippogriff sentenced to death.

    ### 4. Harry Potter and the Goblet of Fire

    **Plot Overview:**
    In Harry’s fourth year, Hogwarts hosts the Triwizard Tournament, a magical competition between three schools. Harry is mysteriously entered into the tournament and faces a series of dangerous tasks.

    **Key Events:**
    - The tournament's tasks include retrieving a golden egg from a dragon, rescuing friends from underwater, and navigating a dangerous maze.
    - During the final task, Harry and Cedric Diggory are transported to a graveyard where Voldemort is resurrected.
    - Harry witnesses Cedric’s death and narrowly escapes Voldemort’s clutches, bringing back news of the dark lord’s return.

    ### 5. Harry Potter and the Order of the Phoenix

    **Plot Overview:**
    Harry's fifth year at Hogwarts is marked by the Wizarding World's denial of Voldemort's return. The Ministry of Magic interferes at Hogwarts by appointing Dolores Umbridge as the new Defense Against the Dark Arts teacher, who imposes strict and cruel rules.

    **Key Events:**
    - Harry forms "Dumbledore's Army," a group of students who secretly learn defensive spells.
    - Harry and his friends are lured to the Department of Mysteries in a trap set by Voldemort.
    - A battle ensues between the Order of the Phoenix and Death Eaters, during which Sirius Black is killed.

    ### 6. Harry Potter and the Half-Blood Prince

    **Plot Overview:**
    In his sixth year, Harry becomes obsessed with learning about Voldemort’s past and his rise to power. He discovers that Voldemort has split his soul into pieces (Horcruxes) to attain immortality.

    **Key Events:**
    - Harry uncovers important information about Voldemort's Horcruxes with the help of Professor Dumbledore.
    - Dumbledore and Harry retrieve one Horcrux, but Dumbledore is gravely weakened.
    - Draco Malfoy is tasked by Voldemort to kill Dumbledore, but he hesitates. Snape ultimately kills Dumbledore, fulfilling an unbreakable vow he made to protect Draco.

    ### 7. Harry Potter and the Deathly Hallows

    **Plot Overview:**
    The final book follows Harry, Ron, and Hermione as they leave Hogwarts to hunt down and destroy Voldemort’s Horcruxes. The Wizarding World is in turmoil under Voldemort's rule.

    **Key Events:**
    - The trio goes on a dangerous journey to find and destroy the remaining Horcruxes.
    - They learn about the Deathly Hallows, three powerful magical objects, and Harry becomes the master of these Hallows.
    - The Battle of Hogwarts ensues, and many characters are killed, including Fred Weasley, Remus Lupin, and Nymphadora Tonks.
    - Harry sacrifices himself to Voldemort, but survives. In the final showdown, Voldemort is defeated when Harry's mastery of the Elder Wand turns Voldemort's killing curse back on him.

    ### Epilogue

    Set nineteen years after the final battle, the epilogue shows Harry, now married to Ginny Weasley, sending their children off to Hogwarts. It highlights the enduring friendship between Harry, Ron, and Hermione, and the peaceful, hopeful future of the Wizarding World.

    ---

    **Themes:**
    The series explores themes of friendship, loyalty, the importance of choices, the battle between good and evil, and the power of love and sacrifice. It emphasizes the impact of one's character over their background and heritage.

    **Cultural Impact:**
    The "Harry Potter" series has had a profound impact on literature, film, and popular culture. It has inspired a generation of readers, a highly successful film series, and a wide array of merchandise, theme parks, and spin-offs, including the "Fantastic Beasts" series and "Harry Potter and the Cursed Child."

    ---

    This summary captures the essence and major plot points of each book, giving an overview of Harry's journey from an ordinary boy to the savior of the Wizarding World."""

    if text:
        # Send the text to Gemini API
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
                "For each identified topic, generate 3 multiple-choice questions with only easy and  hard difficulty level ",
                "Structure the output in the following JSON format:",
                "{topicname: {questionnumber: {question: "question here", difficultylevels: "difficulty", answer: "answer here", options: ["4 options here"]}}, names: ["all topic name here"]}"
                ]
                }"""
        )
        print(response.text)
        return response.text

    else:
        return {"error": "No text extracted from document"}


@app.route("/t_get_document", methods=["GET"])
def sendd_data():
    text = """The PDF titled "Introduction To Neural Networks" provides a comprehensive overview of neural networks, covering various topics such as the development, techniques, and comparisons with traditional computers. Here are some key points extracted from the document:

### Introduction to Neural Networks
- Development dates back to the early 1940s, with significant advances in the late 1980s.
- Neural networks (NNs) are inspired by biological neural networks and aim to create systems capable of sophisticated computations.

### Neural Network Techniques
- Traditional computers require explicit programming, whereas NNs learn from examples and adapt during a training period.

### Comparison with Traditional Computers
- Traditional computers use deductive reasoning, centralized computation, and are not fault-tolerant.
- NNs use inductive reasoning, parallel computation, and are fault-tolerant with dynamic connectivity.

### Evolution and Biological Inspiration
- The brain's ability to solve complex problems with simple neuron functions and massive parallelism inspired NNs.
- Engineers modified biological neural models for practical applications.

### Structure of Neurons
- A neuron has a cell body, dendrites (inputs), and an axon (output).
- Synapses connect axons to dendrites, and signals are propagated through these connections.

### Artificial Neural Networks (ANN)
- ANNs consist of neurons with multiple inputs and one output.
- They use a weighted sum of inputs and a threshold to produce a non-linear response.
- Key elements include layers of neurons, weights, and transfer functions.

### Training Methods
- *Supervised Learning*: Inputs and desired outputs are provided; the network adjusts weights based on errors.
- *Unsupervised Learning*: Only inputs are provided; the network self-organizes based on input features.

### Types of Neural Networks
- *Feedforward NNs*: Information flows in one direction from input to output.
- *Recurrent NNs*: Outputs are fed back into the network, suitable for time-series forecasting.
- *Auto-associative NNs*: Used for data validation and compression.

### Generalization and Overfitting
- Generalization is the ability of NNs to apply learned knowledge to new data.
- Overfitting occurs when a network performs well on training data but poorly on unseen data.
- To avoid overfitting, data is divided into training, validation, and testing sets.

### Practical Applications
- ANNs are used in image classification, speech recognition, pattern recognition, and more.
- Example project: Automated Wildfire Detection using ANNs to identify wildfires in satellite images.

The document also discusses the challenges and considerations in neural network training, including the need for large and high-quality training datasets, network architecture, and learning rates."""
    if text:
        # Send the text to Gemini API
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
                "For each identified topic, generate 3 multiple-choice questions with only easy and  hard difficulty level ",
                "Structure the output in the following JSON format:",
                "{topicname: {questionnumber: {question: "question here", difficultylevels: "difficulty", answer: "answer here", options: ["4 options here"]}}, names: ["all topic name here"]}"
                ]
                }"""
        )
        print(response.text)
        return response.text


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
