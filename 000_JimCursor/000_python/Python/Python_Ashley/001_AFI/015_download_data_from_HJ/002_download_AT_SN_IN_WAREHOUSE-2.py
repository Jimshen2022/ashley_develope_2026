
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
import pandas as pd
import time, os

# ✅ 设置 chromedriver 路径
chromedriver_path = r"C:\Program Files\Google\Chrome\Application\chromedriver.exe"
options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")
driver = webdriver.Chrome(service=Service(chromedriver_path), options=options)

# ✅ 打开系统登录页面
driver.get("https://phumywhjwebprod:30000/core/Default.html")

# ✅ 登录 Workspace Authentication
auth_dropdown = WebDriverWait(driver, 15).until(
    EC.element_to_be_clickable((By.XPATH, "//span[contains(@class, 'k-dropdown-wrap')]"))
)
auth_dropdown.click()

workspace_option = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.XPATH, "//li[contains(text(), 'Workspace Authentication')]"))
)
workspace_option.click()

WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.XPATH, "//input[@placeholder='User Name']"))
).send_keys("SJIM")

driver.find_element(By.XPATH, "//input[@placeholder='Password']").send_keys("JIM2012")
driver.find_element(By.XPATH, "//button[text()='Login']").click()

# ✅ 等待菜单图标加载并点击
WebDriverWait(driver, 15).until(EC.element_to_be_clickable((By.ID, "menuButtonToggle"))).click()

# ✅ 搜索 Search for Active Serial Numbers
search_box = WebDriverWait(driver, 15).until(
    EC.element_to_be_clickable((By.XPATH, "//input[@placeholder='Search']"))
)
search_box.click()
search_box.clear()
search_box.send_keys("Search for Active Serial Numbers")
try:
    result = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//span[contains(text(), 'Search for Active Serial Numbers')]"))
    )
    result.click()
except:
    search_box.send_keys(Keys.ENTER)

# ✅ 选择 Warehouse 为 Ashton
time.sleep(3)
try:
    warehouse_dropdown = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "(//span[contains(@class, 'k-dropdown-wrap')])[1]"))
    )
    warehouse_dropdown.click()
    WebDriverWait(driver, 5).until(
        EC.element_to_be_clickable((By.XPATH, "//li[contains(text(), 'Ashton')]"))
    ).click()
except Exception as e:
    print("选择 Warehouse 失败：", e)

# ✅ 选择 Serial Status 为 In Warehouse
try:
    serial_status_dropdown = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "(//span[contains(@class, 'k-dropdown-wrap')])[2]"))
    )
    serial_status_dropdown.click()
    WebDriverWait(driver, 5).until(
        EC.element_to_be_clickable((By.XPATH, "//li[contains(text(), 'In Warehouse')]"))
    ).click()
except Exception as e:
    print("选择 Serial Status 失败：", e)

# ✅ 点击 Query
try:
    query_button = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//a[@href='#' and descendant::span[contains(text(),'Query')]]"))
    )
    query_button.click()
except Exception as e:
    print("点击 Query 按钮失败：", e)

# ✅ 等待表格加载完成
WebDriverWait(driver, 20).until(
    EC.presence_of_element_located((By.XPATH, "//div[contains(@class, 'k-grid-content')]"))
)
time.sleep(2)

# ✅ 抓取全部数据（无需翻页）
rows = driver.find_elements(By.XPATH, "//div[contains(@class,'k-grid-content')]//tr")
data = []
for row in rows:
    cols = row.find_elements(By.TAG_NAME, "td")
    if cols:
        data.append([c.text.strip() for c in cols])

# ✅ 获取表头
headers = [th.text.strip() for th in driver.find_elements(By.XPATH, "//div[contains(@class,'k-grid-header')]//th")]

# ✅ 写入 Excel
df = pd.DataFrame(data, columns=headers)
output_path = os.path.join(os.path.expanduser("~"), "Downloads", "AT_SN_IN_WAREHOUSE.xlsx")
df.to_excel(output_path, index=False)
print("✅ 数据导出成功：", output_path)
driver.quit()
