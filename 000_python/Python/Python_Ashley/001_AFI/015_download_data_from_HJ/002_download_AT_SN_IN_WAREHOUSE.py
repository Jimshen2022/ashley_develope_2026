from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
import time

# ✅ 设置 chromedriver 路径
chromedriver_path = r"C:\Program Files\Google\Chrome\Application\chromedriver.exe"  # ← 请改成你的实际路径

# ✅ 启动浏览器
options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")
driver = webdriver.Chrome(service=Service(chromedriver_path), options=options)

# ✅ 打开登录页
driver.get("https://phumywhjwebprod:30000/core/Default.html")

# ✅ 选择 Workspace Authentication
auth_dropdown = WebDriverWait(driver, 15).until(
    EC.element_to_be_clickable((By.XPATH, "//span[contains(@class, 'k-dropdown-wrap')]"))
)
auth_dropdown.click()

workspace_option = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.XPATH, "//li[contains(text(), 'Workspace Authentication')]"))
)
workspace_option.click()

# ✅ 登录账户
WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.XPATH, "//input[@placeholder='User Name']"))
).send_keys("SJIM")  # ← 替换为你的用户名

driver.find_element(By.XPATH, "//input[@placeholder='Password']").send_keys("JIM2012")  # ← 替换密码
# driver.find_element(By.XPATH, "//input[@placeholder='Tenant']").send_keys("Default")  # ← 租户名

driver.find_element(By.XPATH, "//button[text()='Login']").click()

# ✅ 登录完成后等待主页面加载
# time.sleep(5)  # 可以换成更智能的等待，比如等待菜单图标出现

# 登录完成后，等待左上角菜单图标加载完成（智能等待）
WebDriverWait(driver, 15).until(
    EC.element_to_be_clickable((By.ID, "menuButtonToggle"))
)

# ✅ 点击左上角三条横线图标（菜单按钮）
menu_button = WebDriverWait(driver, 15).until(
    EC.element_to_be_clickable((By.ID, "menuButtonToggle"))
)
menu_button.click()

# ✅ 等右侧搜索框出现
search_box = WebDriverWait(driver, 15).until(
    EC.presence_of_element_located((By.XPATH, "//input[@placeholder='Search']"))
)
search_box.send_keys("Search for Active Serial Numbers")

# ✅ 等待搜索结果出现并点击 "Search for Active Serial Numbers"
try:
    # 方法1：等待包含特定文本的元素出现并点击
    search_result = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//span[contains(text(), 'Search for Active Serial Numbers')]"))
    )
    search_result.click()
    print("✅ 成功点击了 'Search for Active Serial Numbers'")

except Exception as e:
    print(f"方法1失败，尝试方法2: {e}")
    try:
        # 方法2：如果方法1失败，尝试更通用的选择器
        search_result = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//*[contains(text(), 'Search for Active Serial Numbers')]"))
        )
        search_result.click()
        print("✅ 成功点击了 'Search for Active Serial Numbers' (方法2)")

    except Exception as e2:
        print(f"方法2也失败，尝试方法3: {e2}")
        try:
            # 方法3：尝试通过li元素选择
            search_result = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//li[contains(text(), 'Search for Active Serial Numbers')]"))
            )
            search_result.click()
            print("✅ 成功点击了 'Search for Active Serial Numbers' (方法3)")

        except Exception as e3:
            print(f"所有方法都失败了: {e3}")
            # 如果还是失败，可以按Enter键
            print("尝试按Enter键...")
            search_box.send_keys(Keys.ENTER)

# ✅ 等待页面加载完成
time.sleep(3)

# ✅ 首先选择Warehouse为"Ashton"
print("正在选择Warehouse为Ashton...")
try:
    # 等待Warehouse下拉框加载并点击
    warehouse_dropdown = WebDriverWait(driver, 15).until(
        EC.element_to_be_clickable(
            (By.XPATH, "//span[contains(@class, 'k-dropdown-wrap') and contains(@class, 'k-state-default')]"))
    )
    warehouse_dropdown.click()
    print("✅ 成功点击Warehouse下拉框")

    # 等待下拉选项加载并选择"Ashton"
    ashton_option = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//li[contains(text(), 'Ashton')]"))
    )
    ashton_option.click()
    print("✅ 成功选择 'Ashton' 选项")

except Exception as e:
    print(f"选择Warehouse失败，尝试备用方法: {e}")
    try:
        # 备用方法：通过更具体的路径定位Warehouse下拉框
        warehouse_dropdown = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable(
                (By.XPATH, "//div[contains(@class, 'k-dropdown-wrap')]//span[contains(@class, 'k-dropdown-wrap')]"))
        )
        warehouse_dropdown.click()

        # 选择Ashton
        ashton_option = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//li[text()='Ashton']"))
        )
        ashton_option.click()
        print("✅ 成功选择 'Ashton' 选项 (备用方法)")

    except Exception as e2:
        print(f"备用方法也失败: {e2}")

# 等待Warehouse选择完成
time.sleep(2)

# ✅ 等待Serial Status下拉框加载并点击
print("正在查找Serial Status下拉框...")
try:
    # 等待Serial Status下拉框出现并点击
    serial_status_dropdown = WebDriverWait(driver, 15).until(
        EC.element_to_be_clickable(
            (By.XPATH, "//div[contains(@class, 'k-dropdown-wrap') and contains(@class, 'k-state-default')]"))
    )

    # 如果下拉框还没有展开，则点击它
    if "k-state-focused" not in serial_status_dropdown.get_attribute("class"):
        serial_status_dropdown.click()
        print("✅ 成功点击Serial Status下拉框")

    # 等待下拉选项加载并选择"In Warehouse"
    in_warehouse_option = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//li[contains(text(), 'In Warehouse')]"))
    )
    in_warehouse_option.click()
    print("✅ 成功选择 'In Warehouse' 选项")

except Exception as e:
    print(f"选择Serial Status失败，尝试备用方法: {e}")
    try:
        # 备用方法1：直接查找并点击In Warehouse选项
        in_warehouse_option = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//li[text()='In Warehouse']"))
        )
        in_warehouse_option.click()
        print("✅ 成功选择 'In Warehouse' 选项 (备用方法1)")

    except Exception as e2:
        print(f"备用方法1失败，尝试备用方法2: {e2}")
        try:
            # 备用方法2：通过Serial Status文本定位
            serial_status_section = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.XPATH, "//div[contains(text(), 'Serial Status')]"))
            )
            # 找到Serial Status section下的下拉框
            serial_dropdown = serial_status_section.find_element(By.XPATH,
                                                                 ".//following-sibling::div//span[contains(@class, 'k-dropdown-wrap')]")
            serial_dropdown.click()

            # 选择In Warehouse
            in_warehouse_option = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//li[contains(text(), 'In Warehouse')]"))
            )
            in_warehouse_option.click()
            print("✅ 成功选择 'In Warehouse' 选项 (备用方法2)")

        except Exception as e3:
            print(f"所有方法都失败: {e3}")
            # 最后尝试：通过可见文本直接点击
            try:
                in_warehouse_visible = WebDriverWait(driver, 5).until(
                    EC.element_to_be_clickable(
                        (By.XPATH, "//*[contains(text(), 'In Warehouse') and contains(@class, 'k-item')]"))
                )
                in_warehouse_visible.click()
                print("✅ 成功选择 'In Warehouse' 选项 (最后尝试)")
            except Exception as e4:
                print(f"最后尝试也失败: {e4}")

# ✅ 等待并点击Query按钮
print("正在查找Query按钮...")
time.sleep(2)  # 等待下拉框选择完成

try:
    # 查找并点击Query按钮
    query_button = WebDriverWait(driver, 15).until(
        EC.element_to_be_clickable((By.XPATH, "//button[contains(text(), 'Query')]"))
    )
    query_button.click()
    print("✅ 成功点击Query按钮")

except Exception as e:
    print(f"点击Query按钮失败，尝试备用方法: {e}")
    try:
        # 备用方法：通过不同的选择器
        query_button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//input[@value='Query']"))
        )
        query_button.click()
        print("✅ 成功点击Query按钮 (备用方法)")

    except Exception as e2:
        print(f"所有方法都失败: {e2}")

# ✅ 等待查询结果加载
print("等待查询结果加载...")
time.sleep(5)

print("✅ 脚本执行完成 - 已选择In Warehouse并点击Query")

# 可选：保持浏览器开启以便查看结果
# input("按Enter键关闭浏览器...")
# driver.quit()