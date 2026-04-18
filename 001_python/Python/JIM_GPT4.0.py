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


def chat_with_model():
    messages = [{"role": "system", "content": "You are a helpful assistant."}]
    while True:
        # 获取用户输入
        user_input = input("User: ")
        if user_input.lower() == 'quit':
            break

        # 将用户输入添加到消息列表
        messages.append({"role": "user", "content": user_input})

        # 发送消息到模型并获取响应
        completion = client.chat.completions.create(
            # model="gpt-4-vision-preview",
            model="gpt-4o",
            messages=messages,
            max_tokens = 4096  # 设置最大的token数量来获取更长的回答
        )

        # 打印模型的回答
        answer = completion.choices[0].message.content
        print("AI:", answer)

        # 将模型的回答也添加到消息列表，以便模型可以跟踪对话
        messages.append({"role": "assistant", "content": answer})


# 开始与模型的对话
chat_with_model()
