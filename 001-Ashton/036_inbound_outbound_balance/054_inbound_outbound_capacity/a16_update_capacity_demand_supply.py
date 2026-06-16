import pandas as pd
import time
from datetime import datetime, timedelta

def run(dfs):
    print("Executing a16_UpdateCapacityDemandSupply (summary.py) - High Speed Version...")
    start_time = time.time()
    
    wsItem = dfs.get('Item_Master', pd.DataFrame())
    wsLoc = dfs.get('LocationCapacity', pd.DataFrame())
    wsOnHand = dfs.get('OnHand', pd.DataFrame())
    wsYard = dfs.get('Yard', pd.DataFrame())
    wsOpenPO = dfs.get('OpenPO', pd.DataFrame())
    wsFirmedPO = dfs.get('Firmed_Planned_PO', pd.DataFrame())
    wsCO = dfs.get('CustomerOrder', pd.DataFrame())

    today = datetime.now()
    days_to_saturday = (5 - today.weekday()) % 7
    sat_date = today + timedelta(days=days_to_saturday)
    sat_date = sat_date.replace(hour=0, minute=0, second=0, microsecond=0)
    
    dates = [sat_date + timedelta(days=i*7) for i in range(8)]

    # Load Item_Master into a dictionary
    item_dict = {}
    if not wsItem.empty:
        col_a = wsItem.columns[0]
        col_f = 'Product' if 'Product' in wsItem.columns else (wsItem.columns[5] if len(wsItem.columns) > 5 else wsItem.columns[-1])
        
        # Fast Zip Iteration
        for itnbr, product in zip(wsItem[col_a], wsItem[col_f]):
            if pd.notnull(itnbr) and pd.notnull(product):
                item_dict[str(itnbr).strip()] = str(product).strip().upper()

    print(f"Loaded {len(item_dict)} items from Item_Master.")

    dictCap = {}
    dictOH = {}
    dictYard = {}
    dictInTransit = {}
    dictPO = {}
    dictFirmed = {}
    dictPlanned = {}
    dictTripped = {}
    dictOpenCO = {}

    def safe_float(val):
        try:
            return float(val) if pd.notnull(val) else 0.0
        except:
            return 0.0

    # LocationCapacity
    if not wsLoc.empty:
        try:
            cols_upper = [str(c).upper() for c in wsLoc.columns]
            colSub = wsLoc.columns[cols_upper.index('SUB_AREA_1')] if 'SUB_AREA_1' in cols_upper else wsLoc.columns[0]
            colCtrl = wsLoc.columns[cols_upper.index('LOC_CONTROL_VALUE')] if 'LOC_CONTROL_VALUE' in cols_upper else wsLoc.columns[1]
            
            # Using position 22 (W) for quantity
            for ctrl, sub, qty_val in zip(wsLoc[colCtrl], wsLoc[colSub], wsLoc.iloc[:, 22] if len(wsLoc.columns) > 22 else [0]*len(wsLoc)):
                if pd.notnull(ctrl) and pd.notnull(sub):
                    if str(ctrl).strip().upper() == 'A':
                        prod = str(sub).strip().upper()
                        qty = safe_float(qty_val)
                        dictCap[prod] = dictCap.get(prod, 0) + qty
        except Exception as e:
            print(f"Warning parsing LocationCapacity: {e}")

    # OnHand
    if not wsOnHand.empty:
        col_a = 'item_number' if 'item_number' in wsOnHand.columns else wsOnHand.columns[0]
        col_b = 'actual_qty' if 'actual_qty' in wsOnHand.columns else wsOnHand.columns[1]
        
        product2_list = []
        for itm_val, qty_val in zip(wsOnHand[col_a], wsOnHand[col_b]):
            itm = str(itm_val).strip() if pd.notnull(itm_val) else None
            prod = item_dict.get(itm, "CG")
            product2_list.append(prod)
            qty = safe_float(qty_val)
            dictOH[prod] = dictOH.get(prod, 0) + qty
        
        wsOnHand['Product2'] = product2_list
        dfs['OnHand'] = wsOnHand

    # Yard
    if not wsYard.empty:
        try:
            cols_upper = [str(c).upper() for c in wsYard.columns]
            colQty = wsYard.columns[cols_upper.index('QTY REMAINING')] if 'QTY REMAINING' in cols_upper else wsYard.columns[13]
            colDate = wsYard.columns[cols_upper.index('WEEKSATURDAY')] if 'WEEKSATURDAY' in cols_upper else wsYard.columns[18]
            col_k = wsYard.columns[cols_upper.index('ITEM NUMBER')] if 'ITEM NUMBER' in cols_upper else wsYard.columns[10]
            
            product2_list = []
            for itm_val, d_val, qty_val in zip(wsYard[col_k], wsYard[colDate], wsYard[colQty]):
                itm = str(itm_val).strip() if pd.notnull(itm_val) else None
                prod = item_dict.get(itm, "CG")
                product2_list.append(prod)
                
                if pd.notnull(d_val):
                    try:
                        d_str = str(d_val)[:10] if isinstance(d_val, str) else pd.to_datetime(d_val).strftime('%Y-%m-%d')
                        qty = safe_float(qty_val)
                        key = f"{prod}|{d_str}"
                        dictYard[key] = dictYard.get(key, 0) + qty
                    except:
                        pass
            
            wsYard['Product2'] = product2_list
            dfs['Yard'] = wsYard
        except Exception as e:
            print(f"Warning parsing Yard: {e}")

    # OpenPO
    if not wsOpenPO.empty:
        try:
            cols_upper = [str(c).upper() for c in wsOpenPO.columns]
            colDate = wsOpenPO.columns[cols_upper.index('WEEKSATURDAY')] if 'WEEKSATURDAY' in cols_upper else wsOpenPO.columns[17]
            col_b = wsOpenPO.columns[cols_upper.index('ITNBR')] if 'ITNBR' in cols_upper else wsOpenPO.columns[1]
            col_n = wsOpenPO.columns[cols_upper.index('OPEN_PO')] if 'OPEN_PO' in cols_upper else wsOpenPO.columns[13]
            col_q = wsOpenPO.columns[cols_upper.index('NEW_STATUS')] if 'NEW_STATUS' in cols_upper else wsOpenPO.columns[16]
            col_prod = wsOpenPO.columns[cols_upper.index('PRODUCT')] if 'PRODUCT' in cols_upper else wsOpenPO.columns[11]
            
            product2_list = []
            for itm_val, d_val, stat_val, qty_val, cprod_val in zip(wsOpenPO[col_b], wsOpenPO[colDate], wsOpenPO[col_q], wsOpenPO[col_n], wsOpenPO[col_prod]):
                itm = str(itm_val).strip() if pd.notnull(itm_val) else None
                
                if itm in item_dict:
                    prod = item_dict[itm]
                else:
                    prod = str(cprod_val).strip().upper() if pd.notnull(cprod_val) else "CG"
                
                product2_list.append(prod)
                
                if pd.notnull(d_val) and pd.notnull(stat_val):
                    try:
                        d_str = str(d_val)[:10] if isinstance(d_val, str) else pd.to_datetime(d_val).strftime('%Y-%m-%d')
                        qty = safe_float(qty_val)
                        stat = str(stat_val).strip().upper()
                        
                        key = f"{prod}|{d_str}"
                        if stat == "IN_TRANSIT":
                            dictInTransit[key] = dictInTransit.get(key, 0) + qty
                        elif stat == "OPEN_PO":
                            dictPO[key] = dictPO.get(key, 0) + qty
                    except:
                        pass
            
            wsOpenPO['Product2'] = product2_list
            dfs['OpenPO'] = wsOpenPO
        except Exception as e:
            print(f"Warning parsing OpenPO: {e}")

    # Firmed_Planned_PO
    if not wsFirmedPO.empty:
        try:
            cols_upper = [str(c).upper() for c in wsFirmedPO.columns]
            colDate = wsFirmedPO.columns[cols_upper.index('SPDWEEKENDING')] if 'SPDWEEKENDING' in cols_upper else wsFirmedPO.columns[2]
            col_a = wsFirmedPO.columns[cols_upper.index('SPDITEM')] if 'SPDITEM' in cols_upper else wsFirmedPO.columns[0]
            col_d = wsFirmedPO.columns[cols_upper.index('SPDFIRMPURCHASEORDERS')] if 'SPDFIRMPURCHASEORDERS' in cols_upper else wsFirmedPO.columns[3]
            col_e = wsFirmedPO.columns[cols_upper.index('SPDPLANNEDPURCHASEORDERS')] if 'SPDPLANNEDPURCHASEORDERS' in cols_upper else wsFirmedPO.columns[4]
            
            product2_list = []
            for itm_val, d_val, f_val, p_val in zip(wsFirmedPO[col_a], wsFirmedPO[colDate], wsFirmedPO[col_d], wsFirmedPO[col_e]):
                itm = str(itm_val).strip() if pd.notnull(itm_val) else None
                prod = item_dict.get(itm, "CG")
                product2_list.append(prod)
                
                if pd.notnull(d_val):
                    try:
                        d_str = str(d_val)[:10] if isinstance(d_val, str) else pd.to_datetime(d_val).strftime('%Y-%m-%d')
                        firm_qty = safe_float(f_val)
                        planned_qty = safe_float(p_val)
                        key = f"{prod}|{d_str}"
                        
                        dictFirmed[key] = dictFirmed.get(key, 0) + firm_qty
                        dictPlanned[key] = dictPlanned.get(key, 0) + planned_qty
                    except:
                        pass
            
            wsFirmedPO['Product2'] = product2_list
            dfs['Firmed_Planned_PO'] = wsFirmedPO
        except Exception as e:
            print(f"Warning parsing Firmed_Planned_PO: {e}")

    # CustomerOrder
    if not wsCO.empty:
        try:
            cols_upper = [str(c).upper() for c in wsCO.columns]
            col_e = wsCO.columns[cols_upper.index('ITNBR')] if 'ITNBR' in cols_upper else wsCO.columns[4]
            col_u = wsCO.columns[cols_upper.index('OPEN_CO_QTY')] if 'OPEN_CO_QTY' in cols_upper else wsCO.columns[20]
            col_z = wsCO.columns[cols_upper.index('BDITQT')] if 'BDITQT' in cols_upper else wsCO.columns[25]
            col_ap = wsCO.columns[cols_upper.index('WEEKSATURDAY')] if 'WEEKSATURDAY' in cols_upper else wsCO.columns[41]
            col_x = wsCO.columns[cols_upper.index('BDTRP#')] if 'BDTRP#' in cols_upper else wsCO.columns[23]
            col_prod = wsCO.columns[cols_upper.index('PRODUCT')] if 'PRODUCT' in cols_upper else wsCO.columns[22]

            product2_list = []
            for itm_val, d_val, z_val, u_val, x_val, cprod_val in zip(wsCO[col_e], wsCO[col_ap], wsCO[col_z], wsCO[col_u], wsCO[col_x], wsCO[col_prod]):
                itm = str(itm_val).strip() if pd.notnull(itm_val) else None
                
                if itm in item_dict:
                    prod = item_dict[itm]
                else:
                    prod = str(cprod_val).strip().upper() if pd.notnull(cprod_val) else "CG"
                
                product2_list.append(prod)

                if pd.notnull(d_val):
                    try:
                        d_str = str(d_val)[:10] if isinstance(d_val, str) else pd.to_datetime(d_val).strftime('%Y-%m-%d')
                        bditqt = safe_float(z_val)
                        openco = safe_float(u_val)
                        key = f"{prod}|{d_str}"
                        
                        dictTripped[key] = dictTripped.get(key, 0) + bditqt
                        x_str = str(x_val).strip().upper() if pd.notnull(x_val) else ""
                        if x_str == "" or x_str == "NAN" or x_str == "NONE":
                            dictOpenCO[key] = dictOpenCO.get(key, 0) + openco
                    except:
                        pass
            
            wsCO['Product2'] = product2_list
            dfs['CustomerOrder'] = wsCO
        except Exception as e:
            print(f"Warning parsing CustomerOrder: {e}")

    dfs['Summary_Calculations'] = {
        'dictCap': dictCap,
        'dictOH': dictOH,
        'dictYard': dictYard,
        'dictInTransit': dictInTransit,
        'dictPO': dictPO,
        'dictFirmed': dictFirmed,
        'dictPlanned': dictPlanned,
        'dictTripped': dictTripped,
        'dictOpenCO': dictOpenCO,
        'dates': dates
    }

    elapsed_time = time.time() - start_time
    print(f"Summary calculations completed in {elapsed_time:.2f} seconds.")
    print(f"Stats Debug: Yard={len(dictYard)}, PO={len(dictPO)}, InTransit={len(dictInTransit)}, Firmed={len(dictFirmed)}, Planned={len(dictPlanned)}, OpenCO={len(dictOpenCO)}")