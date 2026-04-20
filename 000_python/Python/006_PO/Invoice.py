import pandas as pd

# 重新加载上传的 Excel 文件
file_path = r"C:\Users\jishen\Downloads\country_classify.xlsx"
df = pd.read_excel(file_path)

# 修复列名空格问题
df.columns = df.columns.str.strip()

# 统一国家名为大写（更稳健）
df["COUNTRY"] = df["COUNTRY"].str.strip().str.upper()

# 定义区域集合（统一为大写）
far_east = {
    'CHINA', 'JAPAN', 'SOUTH KOREA', 'NORTH KOREA', 'TAIWAN', 'HONG KONG',
    'MACAU', 'MONGOLIA',
    'VIETNAM', 'THAILAND', 'MALAYSIA', 'SINGAPORE', 'INDONESIA',
    'PHILIPPINES', 'MYANMAR', 'LAOS', 'CAMBODIA'
}
europe = {
    'UNITED KINGDOM', 'UK', 'GERMANY', 'FRANCE', 'ITALY', 'SPAIN', 'POLAND', 'NETHERLANDS',
    'BELGIUM', 'AUSTRIA', 'SWITZERLAND', 'SWEDEN', 'NORWAY', 'FINLAND', 'DENMARK',
    'IRELAND', 'PORTUGAL', 'GREECE', 'CZECH REPUBLIC', 'HUNGARY', 'ROMANIA', 'BULGARIA',
    'SLOVAKIA', 'SLOVENIA', 'UKRAINE', 'RUSSIA', 'SERBIA', 'CROATIA', 'LITHUANIA',
    'LATVIA', 'ESTONIA', 'ICELAND'
}
middle_east = {
    'SAUDI ARABIA', 'UNITED ARAB EMIRATES', 'UAE', 'ISRAEL', 'QATAR', 'KUWAIT',
    'BAHRAIN', 'OMAN', 'JORDAN', 'LEBANON', 'SYRIA', 'IRAQ', 'IRAN', 'YEMEN', 'PALESTINE'
}
south_america = {
    'BRAZIL', 'ARGENTINA', 'CHILE', 'PERU', 'COLOMBIA', 'ECUADOR', 'BOLIVIA',
    'PARAGUAY', 'URUGUAY', 'VENEZUELA', 'GUYANA', 'SURINAME'
}
north_america = {
    'UNITED STATES', 'USA', 'CANADA', 'MEXICO', 'GREENLAND', 'BERMUDA', 'BAHAMAS',
    'CUBA', 'JAMAICA', 'DOMINICAN REPUBLIC', 'HAITI', 'GUATEMALA', 'HONDURAS',
    'EL SALVADOR', 'NICARAGUA', 'COSTA RICA', 'PANAMA'
}

# 定义分类函数
def classify_region(country):
    if pd.isna(country):
        return "Africa / Other"
    country = str(country).strip().upper()
    if country in far_east:
        return "Far East"
    elif country in europe:
        return "Europe"
    elif country in middle_east:
        return "Middle East"
    elif country in south_america:
        return "South America"
    elif country in north_america:
        return "North America"
    else:
        return "Africa / Other"

# 应用分类
df["AREA"] = df["COUNTRY"].apply(classify_region)

# 保存新文件
output_path = r"C:/Users/jishen/Downloads/country_classified_output.xlsx"
df.to_excel(output_path, index=False)
