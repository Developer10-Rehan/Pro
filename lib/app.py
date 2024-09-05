from flask import Flask, request, jsonify
from transformers import GPT2LMHeadModel, GPT2Tokenizer

app = Flask(__name__)

# Load fine-tuned GPT-2 model
model = GPT2LMHeadModel.from_pretrained('./emotional-support-gpt2')
tokenizer = GPT2Tokenizer.from_pretrained('./emotional-support-gpt2')

@app.route('/generate_response', methods=['POST'])
def generate_response():
    data = request.json
    input_text = data.get('text', '')

    # Generate response using GPT-2
    inputs = tokenizer.encode(input_text, return_tensors='pt')
    outputs = model.generate(inputs, max_length=150, num_return_sequences=1)
    response_text = tokenizer.decode(outputs[0], skip_special_tokens=True)

    return jsonify({'response': response_text})

if __name__ == '__main__':
    app.run(debug=True)
