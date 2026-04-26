import requests
import os
from urllib.parse import urlparse
import re


class FreeMusicDownloader:
    """
    从合法免费音乐网站下载歌曲
    """

    def __init__(self, download_dir="downloaded_music"):
        self.download_dir = download_dir
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }

        # 创建下载目录
        if not os.path.exists(download_dir):
            os.makedirs(download_dir)
            print(f"✅ 创建下载目录: {download_dir}")

        # 可用的免费音乐列表（Incompetech - Kevin MacLeod）
        self.available_songs = {
            "1": {
                "name": "Wallpaper",
                "url": "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Wallpaper.mp3",
                "description": "轻快的背景音乐"
            },
            "2": {
                "name": "Sneaky Snitch",
                "url": "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Sneaky%20Snitch.mp3",
                "description": "俏皮有趣的音乐"
            },
            "3": {
                "name": "Cipher",
                "url": "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Cipher.mp3",
                "description": "神秘氛围音乐"
            },
            "4": {
                "name": "Carefree",
                "url": "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Carefree.mp3",
                "description": "无忧无虑的轻音乐"
            },
            "5": {
                "name": "Monkeys Spinning Monkeys",
                "url": "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Monkeys%20Spinning%20Monkeys.mp3",
                "description": "欢快搞笑的音乐"
            }
        }

    def download_file(self, url, filename=None):
        """
        通用文件下载函数
        """
        try:
            print(f"\n📥 开始下载: {url}")

            # 发送请求
            response = requests.get(url, headers=self.headers, stream=True, timeout=30)
            response.raise_for_status()

            # 确定文件名
            if not filename:
                filename = os.path.basename(urlparse(url).path)
                # URL解码
                from urllib.parse import unquote
                filename = unquote(filename)

            # 清理文件名（移除非法字符）
            filename = re.sub(r'[<>:"/\\|?*]', '_', filename)

            # 完整路径
            filepath = os.path.join(self.download_dir, filename)

            # 获取文件大小
            total_size = int(response.headers.get('content-length', 0))

            # 下载文件
            downloaded = 0
            print(f"文件大小: {total_size / 1024 / 1024:.2f} MB")

            with open(filepath, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)

                        # 显示进度
                        if total_size > 0:
                            percent = (downloaded / total_size) * 100
                            print(
                                f"\r进度: {percent:.1f}% ({downloaded / 1024 / 1024:.2f}/{total_size / 1024 / 1024:.2f} MB)",
                                end='')

            print(f"\n✅ 下载成功: {filepath}")
            print(f"📁 文件保存在: {os.path.abspath(filepath)}")
            return filepath

        except requests.exceptions.RequestException as e:
            print(f"\n❌ 下载失败: {e}")
            return None
        except Exception as e:
            print(f"\n❌ 发生错误: {e}")
            return None

    def list_available_songs(self):
        """列出可用的免费歌曲"""
        print("\n" + "=" * 70)
        print("🎼 可用的免费音乐列表")
        print("=" * 70)

        print("\n【来源：Incompetech - Kevin MacLeod】")
        print("许可：Creative Commons Attribution 4.0")
        print("说明：可免费使用（包括商业用途），但需署名作者\n")

        for key, song in self.available_songs.items():
            print(f"  {key}. {song['name']}")
            print(f"     {song['description']}")
            print()

        print("💡 使用提示:")
        print("  - 这些音乐完全免费且合法")
        print("  - 可用于视频、游戏、播客等项目")
        print("  - 使用时请注明: Music by Kevin MacLeod (incompetech.com)")
        print("  - 许可: CC BY 4.0 (http://creativecommons.org/licenses/by/4.0/)")
        print("=" * 70)

    def download_by_number(self, number):
        """根据编号下载歌曲"""
        if number not in self.available_songs:
            print(f"❌ 无效的歌曲编号: {number}")
            return None

        song = self.available_songs[number]
        print(f"\n🎵 准备下载: {song['name']}")
        print(f"📝 描述: {song['description']}")

        result = self.download_file(song['url'], f"{song['name']}.mp3")

        if result:
            print("\n📝 版权信息:")
            print(f"   歌曲: {song['name']}")
            print(f"   作者: Kevin MacLeod (incompetech.com)")
            print(f"   许可: Licensed under Creative Commons: By Attribution 4.0")
            print(f"   链接: http://creativecommons.org/licenses/by/4.0/")

        return result

    def download_from_url(self, url, filename=None):
        """从直接链接下载音频文件"""
        print("\n🎵 从直接链接下载")
        print("=" * 70)
        return self.download_file(url, filename)


def main():
    """主函数"""
    print("=" * 70)
    print("🎵 免费音乐下载器 v1.0")
    print("=" * 70)
    print("\n⚠️  重要提示:")
    print("  - 本工具仅下载合法、免费的音乐")
    print("  - 所有音乐采用 Creative Commons 许可")
    print("  - 使用这些音乐时请遵守许可协议并署名作者")
    print("=" * 70)

    # 创建下载器实例
    downloader = FreeMusicDownloader()

    # 主循环
    while True:
        print("\n" + "=" * 70)
        print("请选择操作:")
        print("=" * 70)
        print("1. 查看可用的免费音乐列表")
        print("2. 下载指定编号的歌曲")
        print("3. 批量下载所有歌曲")
        print("4. 从自定义URL下载")
        print("0. 退出程序")
        print("=" * 70)

        choice = input("\n👉 请输入选项 (0-4): ").strip()

        if choice == "1":
            downloader.list_available_songs()

        elif choice == "2":
            downloader.list_available_songs()
            song_number = input("\n👉 请输入要下载的歌曲编号 (1-5): ").strip()
            downloader.download_by_number(song_number)

        elif choice == "3":
            print("\n🎵 开始批量下载所有歌曲...")
            for number in downloader.available_songs.keys():
                downloader.download_by_number(number)
                print("\n" + "-" * 70)
            print("\n✅ 批量下载完成！")

        elif choice == "4":
            url = input("\n👉 请输入音频文件的直接URL: ").strip()
            if url:
                filename = input("👉 请输入保存的文件名（按回车使用默认名称）: ").strip()
                if not filename:
                    filename = None
                downloader.download_from_url(url, filename)
            else:
                print("❌ URL不能为空")

        elif choice == "0":
            print("\n" + "=" * 70)
            print("👋 感谢使用免费音乐下载器！")
            print("=" * 70)
            break

        else:
            print("\n❌ 无效选项，请输入 0-4 之间的数字")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n👋 程序已退出")
    except Exception as e:
        print(f"\n❌ 程序出错: {e}")