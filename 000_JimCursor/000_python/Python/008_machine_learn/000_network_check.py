import urllib.request

try:
    urllib.request.urlopen("https://www.google.com", timeout=5)
    print("Network is available")
except Exception as e:
    print("Network error:", e)