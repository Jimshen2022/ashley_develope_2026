import pandas as pd
import time

def run(dfs):
    print("Executing a06_Yard_add_Weeksaturday...")
    start_time = time.time()
    
    target_sheet = 'Yard'
    if target_sheet not in dfs or dfs[target_sheet].empty:
        print("No data found in the Yard sheet. Exiting.")
        return

    df = dfs[target_sheet]

    if 'Entered Yard' in df.columns:
        date_col = 'Entered Yard'
    else:
        date_col = df.columns[7]

    print("Calculating WeekSaturday dates...")
    dt_series = pd.to_datetime(df[date_col], errors='coerce')
    days_to_add = (5 - dt_series.dt.weekday) % 7
    week_saturday = dt_series + pd.to_timedelta(days_to_add, unit='D')
    
    while len(df.columns) < 18:
        df[f'Empty_Col_{len(df.columns)}'] = None
        
    if 'WeekSaturday' in df.columns:
        df['WeekSaturday'] = week_saturday.dt.date
    else:
        if len(df.columns) >= 18:
            df.insert(18, 'WeekSaturday', week_saturday.dt.date)
        else:
            df['WeekSaturday'] = week_saturday.dt.date

    # 确保存入的是纯净的字符串 YYYY-MM-DD，以便 summary 精确匹配
    df['WeekSaturday'] = pd.to_datetime(df['WeekSaturday']).dt.strftime('%Y-%m-%d')
    
    # Replace original date objects with formatted strings to prevent any mismatch later
    # Especially for 'WeekSaturday' which is heavily relied upon by summary
    
    elapsed_time = time.time() - start_time
    print(f"a06_Yard_add_Weeksaturday completed in {elapsed_time:.2f} seconds.")