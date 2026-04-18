import os
from openai import OpenAI

# 设置 OPENAI_API_KEY 环境变量
os.environ["OPENAI_API_KEY"] = "sk-2HimFCuVKlIvwikvEbAd8f125c12489384Be7c37F4E3Bf9f"
# 设置 OPENAI_BASE_URL 环境变量
os.environ["OPENAI_BASE_URL"] = "https://xiaoai.plus/v1"
client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),
    base_url=os.environ.get("OPENAI_BASE_URL"),
)

messages = [
    {"role": "system", "content": "You are a helpful assistant."},
]

while True:
    message = input("You: ")
    if message:
        if message.lower() in ["exit", "quit"]:
            break
        messages.append({"role": "user", "content": message})

        # 使用 GPT-4 模型调用 ChatCompletion API
        response = openai.ChatCompletion.create(  # 注意这里是 ChatCompletion 而不是 chat_completions
            model="gpt-4-vision-preview",  # 使用 gpt-4 模型
            messages=messages
        )

        reply = response.choices[0].message['content']
        print(f"Assistant: {reply}")

        messages.append({"role": "assistant", "content": reply})

