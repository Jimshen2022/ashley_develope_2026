# 1. 学习爬取静态网站
import requests
from bs4 import BeautifulSoup


def simple_scraping_example():
    """简单爬虫示例 - 豆瓣电影TOP250"""
    url = "https://movie.douban.com/top250"
    headers = {'User-Agent': 'Mozilla/5.0'}

    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.text, 'html.parser')

    # 提取电影信息
    movies = soup.find_all('div', class_='hd')
    for movie in movies[:5]:  # 只显示前5个
        title = movie.find('span', class_='title').text
        print(f"电影: {title}")


# 2. 学习处理JSON API
def api_example():
    """API请求示例"""
    # 很多网站提供公开API
    url = "https://api.github.com/users/github"
    response = requests.get(url)
    data = response.json()
    print(f"用户名: {data['login']}")
    print(f"仓库数: {data['public_repos']}")