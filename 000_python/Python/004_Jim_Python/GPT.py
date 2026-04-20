import openai
import os

openai.api_key = "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"
messages = [
    # System messages should be at the beginning; they help set the behavior of the assistant.
    {"role": "system", "content": "You are a helpful assistant."},
]

while True:
    message = input("‍: ")
    if message:
        # Check if the user wants to exit the program.
        if message.lower() in ["exit", "quit"]:
            break
        messages.append(
            {"role": "user", "content": message},
        )
        chat_completion = openai.ChatCompletion.create(
            model="gpt-3.5-turbo", messages=messages  # Update the model name to GPT-4.
        )
    # Get the reply.
    reply = chat_completion.choices[0].message.content
    print(f": {reply}")
    messages.append({"role": "assistant", "content": reply})
