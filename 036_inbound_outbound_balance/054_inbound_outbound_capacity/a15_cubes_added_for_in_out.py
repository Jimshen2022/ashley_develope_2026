import pandas as pd
import time

def run(dfs):
    print("Executing a15_cubes_added_for_in_out (High Speed Version)...")
    start_time = time.time()
    
    if 'ItemBalance_by_Cubes_Data' not in dfs or 'Target_Dates' not in dfs:
        print("Required cube data or dates not found in memory.")
        return

    df_cubes = dfs['ItemBalance_by_Cubes_Data']
    dates = dfs['Target_Dates']

    in_cols = [f'Inbound_{i}' for i in range(7)]
    out_cols = [f'Outbound_{i}' for i in range(7)]
    balance_cols = [f'Balance_{i}' for i in range(7)]

    # Dictionaries to aggregate cubes
    item_dict = {str(item).strip().upper(): idx for idx, item in enumerate(df_cubes['Item'])}
    
    num_items = len(df_cubes)
    arr_onhand = [0.0] * num_items
    arr_yard = [0.0] * num_items
    arr_inbound = {col: [0.0] * num_items for col in in_cols}
    arr_outbound = {col: [0.0] * num_items for col in out_cols}

    def safe_float(val):
        try:
            return float(val) if pd.notnull(val) else 0.0
        except:
            return 0.0

    # Process OnHand
    df_onhand = dfs.get('OnHand', pd.DataFrame())
    if not df_onhand.empty:
        i_col_name = df_onhand.columns[0]
        v_col_name = df_onhand.columns[7] if len(df_onhand.columns) > 7 else None
        if v_col_name:
            for itm_val, v_val in zip(df_onhand[i_col_name], df_onhand[v_col_name]):
                item = str(itm_val).strip().upper() if pd.notnull(itm_val) else ""
                if item in item_dict:
                    arr_onhand[item_dict[item]] += safe_float(v_val)

    # Process Yard
    df_yard = dfs.get('Yard', pd.DataFrame())
    if not df_yard.empty:
        i_col_name = df_yard.columns[10] if len(df_yard.columns) > 10 else None
        v_col_name = df_yard.columns[19] if len(df_yard.columns) > 19 else None
        if i_col_name and v_col_name:
            for itm_val, v_val in zip(df_yard[i_col_name], df_yard[v_col_name]):
                item = str(itm_val).strip().upper() if pd.notnull(itm_val) else ""
                if item in item_dict:
                    arr_yard[item_dict[item]] += safe_float(v_val)

    # Process OpenPO
    df_po = dfs.get('OpenPO', pd.DataFrame())
    if not df_po.empty:
        cols_upper = [str(c).upper() for c in df_po.columns]
        po_i = df_po.columns[1]
        po_d = df_po.columns[cols_upper.index('WEEKSATURDAY')] if 'WEEKSATURDAY' in cols_upper else df_po.columns[17]
        po_v = df_po.columns[cols_upper.index('CUBES')] if 'CUBES' in cols_upper else df_po.columns[18]
        po_f = df_po.columns[cols_upper.index('NEW_STATUS')] if 'NEW_STATUS' in cols_upper else df_po.columns[16]
        
        for itm_val, d_val, v_val, f_val in zip(df_po[po_i], df_po[po_d], df_po[po_v], df_po[po_f]):
            cell_f = str(f_val).strip().upper() if pd.notnull(f_val) else ""
            if cell_f == "IN_YARD":
                continue
            
            if pd.notnull(d_val):
                try:
                    d_str = str(d_val)[:10] if isinstance(d_val, str) else pd.to_datetime(d_val).strftime('%Y-%m-%d')
                    if d_str in dates:
                        target_col = in_cols[dates.index(d_str)]
                        item = str(itm_val).strip().upper() if pd.notnull(itm_val) else ""
                        if item in item_dict:
                            arr_inbound[target_col][item_dict[item]] += safe_float(v_val)
                except:
                    pass

    # Process Firmed_Planned_PO
    df_fp = dfs.get('Firmed_Planned_PO', pd.DataFrame())
    if not df_fp.empty:
        cols_upper = [str(c).upper() for c in df_fp.columns]
        fp_i = df_fp.columns[0]
        fp_d = df_fp.columns[cols_upper.index('SPDWEEKENDING')] if 'SPDWEEKENDING' in cols_upper else df_fp.columns[2]
        fp_v = df_fp.columns[cols_upper.index('CUBES')] if 'CUBES' in cols_upper else df_fp.columns[7]
        
        for itm_val, d_val, v_val in zip(df_fp[fp_i], df_fp[fp_d], df_fp[fp_v]):
            if pd.notnull(d_val):
                try:
                    d_str = str(d_val)[:10] if isinstance(d_val, str) else pd.to_datetime(d_val).strftime('%Y-%m-%d')
                    if d_str in dates:
                        target_col = in_cols[dates.index(d_str)]
                        item = str(itm_val).strip().upper() if pd.notnull(itm_val) else ""
                        if item in item_dict:
                            arr_inbound[target_col][item_dict[item]] += safe_float(v_val)
                except:
                    pass

    # Process CustomerOrder
    df_co = dfs.get('CustomerOrder', pd.DataFrame())
    if not df_co.empty:
        cols_upper = [str(c).upper() for c in df_co.columns]
        co_i = df_co.columns[4]
        co_d = df_co.columns[cols_upper.index('WEEKSATURDAY')] if 'WEEKSATURDAY' in cols_upper else df_co.columns[41]
        co_v = df_co.columns[cols_upper.index('CUBES')] if 'CUBES' in cols_upper else df_co.columns[42]
        
        for itm_val, d_val, v_val in zip(df_co[co_i], df_co[co_d], df_co[co_v]):
            if pd.notnull(d_val):
                try:
                    d_str = str(d_val)[:10] if isinstance(d_val, str) else pd.to_datetime(d_val).strftime('%Y-%m-%d')
                    if d_str in dates:
                        target_col = out_cols[dates.index(d_str)]
                        item = str(itm_val).strip().upper() if pd.notnull(itm_val) else ""
                        if item in item_dict:
                            arr_outbound[target_col][item_dict[item]] += safe_float(v_val)
                except:
                    pass

    # Assign to dataframe
    df_cubes['OnHand'] = arr_onhand
    df_cubes['Yard'] = arr_yard
    
    for c in in_cols: df_cubes[c] = arr_inbound[c]
    for c in out_cols: df_cubes[c] = arr_outbound[c]
    
    # Calculate Rolling Balance
    arr_balance = {col: [0.0] * num_items for col in balance_cols}
    
    for i in range(num_items):
        # Week 0 Balance = OnHand + Yard + Inbound_0 - Outbound_0
        arr_balance[balance_cols[0]][i] = arr_onhand[i] + arr_yard[i] + arr_inbound[in_cols[0]][i] - arr_outbound[out_cols[0]][i]
        
        # Weeks 1-6
        for w in range(1, 7):
            arr_balance[balance_cols[w]][i] = arr_balance[balance_cols[w-1]][i] + arr_inbound[in_cols[w]][i] - arr_outbound[out_cols[w]][i]

    for c in balance_cols: df_cubes[c] = arr_balance[c]
    
    dfs['ItemBalance_by_Cubes_Data'] = df_cubes

    elapsed_time = time.time() - start_time
    print(f"a15_cubes_added_for_in_out completed in {elapsed_time:.2f} seconds.")
