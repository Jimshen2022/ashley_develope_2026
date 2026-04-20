import pandas as pd
import numpy as np
from math import floor, ceil
from datetime import datetime

# ==============================
# 0) I/O 与参数
# ==============================
infile = r"D:\Documents\08-Ashton_Phu_my\00_Slotting\Ashton Slotting Report - 2025.xlsb"
sheet_name = "ItemData"
timestamp = datetime.now().strftime("%Y%m%d_%H%M")
outfile_csv = fr"C:\Users\jishen\Downloads\ashton_tihi_setup_suggestion_{timestamp}.csv"
outfile_small_csv = fr"C:\Users\jishen\Downloads\ashton_tihi_setup_small_under30cm_{timestamp}.csv"

REQUIRED_COLS = ["ITNBR", "CRTLIN", "CRTWIN", "CRTHIN"]  # inches

# ==============================
# 业务参数（可调）
# ==============================
# 高度策略
HEIGHT_LIMIT_CM_DEFAULT = 170.0  # 默认 1.7 m
HEIGHT_LIMIT_CM_RAILS = 110.0  # ITMCLSID = 'RAILS' 时 1.1 m
HEIGHT_TOL_CM = 1.0  # 高度容差（同样按每行上限应用；设 0 表示无容差）

# 长/宽外挑策略
ALLOW_LEN_OVERHANG_8FT = True  # 仅 8ft 板允许长度外挂
LEN_OVERHANG_MAX_CM = None  # 长度外挂上限；None 表示不设
ALLOW_WIDTH_OVERHANG = True  # 允许宽度外挂
WIDTH_OVERHANG_MAX_CM = None  # 宽度外挂上限；None 表示不设
FORCE_SINGLE_LAYER_IF_OVERHEIGHT = True  # 明显超高仍给建议（强制 1 层），并打标记

# 重量上限策略
PALLET_WEIGHT_CAP_KG = 1500.0  # 目标上限 1500 kg，仅通过调整 NZ(=HI) 实现

# 小货阈值
SMALL_TH_CM = 30.0

# ==============================
# 1) 常量与板型
# ==============================
FT_TO_IN = 12.0
CM_TO_IN = 1.0 / 2.54
IN_TO_CM = 2.54

H_TOL_IN = HEIGHT_TOL_CM * CM_TO_IN
LEN_OVER_MAX_IN = None if LEN_OVERHANG_MAX_CM is None else LEN_OVERHANG_MAX_CM * CM_TO_IN
WID_OVER_MAX_IN = None if WIDTH_OVERHANG_MAX_CM is None else WIDTH_OVERHANG_MAX_CM * CM_TO_IN
SMALL_TH_IN = SMALL_TH_CM * CM_TO_IN

# 名称为 宽×长 (W×L)，内部统一用 (PL, PW)=(长, 宽)
PALLETS = {
    "5x5": (5.0 * FT_TO_IN, 5.0 * FT_TO_IN),  # 60 x 60
    "5x7": (7.0 * FT_TO_IN, 5.0 * FT_TO_IN),  # 84 x 60
    "3.5x5": (5.0 * FT_TO_IN, 3.5 * FT_TO_IN),  # 60 x 42
    "3.5x7": (7.0 * FT_TO_IN, 3.5 * FT_TO_IN),  # 84 x 42
    "5x8": (8.0 * FT_TO_IN, 5.0 * FT_TO_IN),  # 96 x 60
    "3.5x8": (8.0 * FT_TO_IN, 3.5 * FT_TO_IN),  # 96 x 42
}

# ==============================
# 2) 读取数据
# ==============================
try:
    df = pd.read_excel(infile, sheet_name=sheet_name, engine="pyxlsb")
except Exception:
    df = pd.read_excel(infile, sheet_name=sheet_name)

missing = [c for c in REQUIRED_COLS if c not in df.columns]
if missing:
    raise ValueError(f"缺少必要列: {missing}")

for col in ["CRTLIN", "CRTWIN", "CRTHIN", "Unit_Weight(KG)", "SCOOP_Weight(KG)"]:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors="coerce")


# ==============================
# 3) 候选板（根据最大尺寸分类选择托盘）
# ==============================
def get_candidate_pallets(max_dim_in: float):
    """根据最大尺寸分类返回托盘候选"""
    if max_dim_in > 7 * FT_TO_IN:
        # 最大值 >= 7ft，只选择长为8ft的托盘
        candidates = ["3.5x8", "5x8"]
    elif max_dim_in > 5 * FT_TO_IN:
        # 最大值 > 5ft，只选择长为7ft的托盘
        candidates = ["3.5x7", "5x7"]
    else:
        # 最大值 <= 5ft，只选择长为5ft的托盘
        candidates = ["3.5x5", "5x5"]

    return candidates


# ==============================
# 4) 全方位评估单个托盘的所有摆放方案
# ==============================
def eval_all_orientations(L_in, W_in, H_in, pallet_name, max_h_in: float, h_tol_in: float):
    """
    评估货物在指定托盘上的所有可能摆放方案
    货物三个维度可以任意分配给托盘的长、宽、高方向
    """
    dims = [float(L_in), float(W_in), float(H_in)]
    PL, PW = PALLETS[pallet_name]

    # 所有可能的维度分配方案 (托盘长方向, 托盘宽方向, 高度方向)
    orientations = [
        (dims[0], dims[1], dims[2], "L->PL, W->PW, H->H"),
        (dims[0], dims[2], dims[1], "L->PL, H->PW, W->H"),
        (dims[1], dims[0], dims[2], "W->PL, L->PW, H->H"),
        (dims[1], dims[2], dims[0], "W->PL, H->PW, L->H"),
        (dims[2], dims[0], dims[1], "H->PL, L->PW, W->H"),
        (dims[2], dims[1], dims[0], "H->PL, W->PW, L->H"),
    ]

    best_plan = None

    for pallet_len_dim, pallet_wid_dim, height_dim, ori_desc in orientations:
        plan = eval_single_orientation(
            pallet_len_dim, pallet_wid_dim, height_dim,
            pallet_name, ori_desc, max_h_in, h_tol_in
        )

        # 选择最佳方案的逻辑：优先级为 relax_level -> VolumeUtil -> Total -> FootprintUtil
        if best_plan is None or is_better_plan(plan, best_plan):
            best_plan = plan

    return best_plan


def eval_single_orientation(pallet_len_dim, pallet_wid_dim, height_dim, pallet_name, ori_desc, max_h_in, h_tol_in):
    """评估单个摆放方向的方案"""
    PL, PW = PALLETS[pallet_name]

    flags = {"LEN_OVER": False, "WID_OVER": False, "H_TOL": False, "H_FORCE1": False}
    relax_level = 0

    # ---- 托盘长度方向 ----
    if pallet_len_dim <= PL:
        NX = int(PL // max(pallet_len_dim, 1e-9)) or 1
    else:
        # 检查是否允许长度外挂
        if ALLOW_LEN_OVERHANG_8FT and pallet_name in ("3.5x8", "5x8") and \
                (LEN_OVER_MAX_IN is None or (pallet_len_dim - PL) <= LEN_OVER_MAX_IN):
            NX = 1
            flags["LEN_OVER"] = True
            relax_level = max(relax_level, 2)
        else:
            NX = 1
            flags["LEN_OVER"] = True
            relax_level = max(relax_level, 2)

    # ---- 托盘宽度方向 ----
    if pallet_wid_dim <= PW:
        NY = int(PW // max(pallet_wid_dim, 1e-9)) or 1
    else:
        # 检查是否允许宽度外挂
        if ALLOW_WIDTH_OVERHANG and (WID_OVER_MAX_IN is None or (pallet_wid_dim - PW) <= WID_OVER_MAX_IN):
            NY = 1
            flags["WID_OVER"] = True
            relax_level = max(relax_level, 3)
        else:
            NY = 1
            flags["WID_OVER"] = True
            relax_level = max(relax_level, 3)

    TI = NX * NY

    # ---- 高度方向 ----
    if height_dim <= max_h_in:
        HI = max(1, int(max_h_in // max(height_dim, 1e-9)))
    elif height_dim <= max_h_in + h_tol_in:
        HI = 1
        flags["H_TOL"] = True
        relax_level = max(relax_level, 1)
    else:
        if FORCE_SINGLE_LAYER_IF_OVERHEIGHT:
            HI = 1
            flags["H_FORCE1"] = True
            relax_level = max(relax_level, 4)
        else:
            HI = 0  # 不可行

    # ---- 计算利用率（使用有效尺寸）----
    eff_L = min(pallet_len_dim, PL)
    eff_W = min(pallet_wid_dim, PW)
    eff_H = min(height_dim, max_h_in)

    PLPW = PL * PW
    footprint_util = (TI * eff_L * eff_W) / PLPW if PLPW > 0 else 0.0

    volume_denom = PLPW * max_h_in if PLPW > 0 else 1.0
    volume_util = (TI * HI * eff_L * eff_W * eff_H) / volume_denom

    return {
        "Pallet": pallet_name,
        "Ori": ori_desc,
        "NX": NX, "NY": NY, "TI": TI, "HI": HI, "Total": TI * HI,
        "FootprintUtil": footprint_util,
        "VolumeUtil": volume_util,
        "relax_level": relax_level,
        "flags": flags,
        "pallet_len_dim": pallet_len_dim,
        "pallet_wid_dim": pallet_wid_dim,
        "height_dim": height_dim,
        "eff_L": eff_L, "eff_W": eff_W, "eff_H": eff_H,
        "max_h_in": max_h_in,
        "over_len": max(0.0, pallet_len_dim - PL),
        "over_wid": max(0.0, pallet_wid_dim - PW),
        "over_hgt": max(0.0, height_dim - max_h_in)
    }


def is_better_plan(plan1, plan2):
    """判断plan1是否比plan2更好"""
    # 优先级：relax_level(越小越好) -> VolumeUtil(越大越好) -> Total(越大越好) -> FootprintUtil(越大越好)
    if plan1["relax_level"] != plan2["relax_level"]:
        return plan1["relax_level"] < plan2["relax_level"]

    if abs(plan1["VolumeUtil"] - plan2["VolumeUtil"]) > 1e-6:
        return plan1["VolumeUtil"] > plan2["VolumeUtil"]

    if plan1["Total"] != plan2["Total"]:
        return plan1["Total"] > plan2["Total"]

    return plan1["FootprintUtil"] > plan2["FootprintUtil"]


# ==============================
# 5) 跨板型择优
# ==============================
def pick_best_plan(L_in, W_in, H_in, max_h_in: float, h_tol_in: float):
    """在所有托盘类型中找到最佳方案"""
    max_dim = max(float(L_in), float(W_in), float(H_in))
    candidates = get_candidate_pallets(max_dim)

    best_plan = None

    for pallet_name in candidates:
        plan = eval_all_orientations(L_in, W_in, H_in, pallet_name, max_h_in, h_tol_in)

        if best_plan is None or is_better_plan(plan, best_plan):
            best_plan = plan

    return best_plan


# ==============================
# 6) 根据 1500 kg 限制调整 NZ（只减不加）
# ==============================
def adjust_height_by_weight(plan: dict, unit_weight_kg: float, target_kg: float):
    """
    给定已选计划（含 TI、HI、eff_*、max_h_in、Pallet 等），在 [1, HI] 范围内
    调整 HI，使 TI*HI*unit_weight_kg 最接近 target_kg。
    返回 (new_HI, new_Total, new_VolumeUtil, hit_cap_flag, orig_weight, new_weight)
    """
    TI = int(plan["TI"])
    HI = int(plan["HI"])
    if unit_weight_kg is None or unit_weight_kg <= 0 or TI <= 0 or HI <= 0:
        return HI, TI * HI, plan["VolumeUtil"], False, unit_weight_kg * TI * HI if unit_weight_kg else None, None

    orig_weight = unit_weight_kg * TI * HI
    if orig_weight <= target_kg:
        return HI, TI * HI, plan["VolumeUtil"], False, orig_weight, orig_weight

    # 计算理想层数（可小数），候选取 floor/ceil 后 clamp 至 [1, HI]
    ideal = target_kg / (unit_weight_kg * TI)
    cand1 = max(1, min(HI, int(floor(ideal))))
    cand2 = max(1, min(HI, int(ceil(ideal))))
    # 评估两个候选与目标的差距
    w1 = unit_weight_kg * TI * cand1
    w2 = unit_weight_kg * TI * cand2
    # 选择更接近的；若相同，优先不超标（倾向 cand1）
    if abs(w1 - target_kg) < abs(w2 - target_kg) or (abs(w1 - target_kg) == abs(w2 - target_kg) and w1 <= target_kg):
        new_HI, new_weight = cand1, w1
    else:
        new_HI, new_weight = cand2, w2

    # 重新计算 VolumeUtil（FU 不受 HI 影响）
    PL, PW = PALLETS[plan["Pallet"]]
    PLPW = PL * PW
    denom = PLPW * plan["max_h_in"]
    new_VU = (TI * new_HI * plan["eff_L"] * plan["eff_W"] * plan["eff_H"]) / denom if denom > 0 else 0.0

    return new_HI, TI * new_HI, new_VU, True, orig_weight, new_weight


# ==============================
# 7) 逐行计算 & 导出
# ==============================
rows = []
for _, r in df.iterrows():
    L, W, H = r["CRTLIN"], r["CRTWIN"], r["CRTHIN"]
    if pd.isna(L) or pd.isna(W) or pd.isna(H) or min(L, W, H) <= 0:
        rows.append({k: np.nan for k in [
            "Best_Pallet", "Best_Ori", "NX", "NY", "NZ", "TI", "HI", "Total",
            "FootprintUtil", "VolumeUtil", "SCOOP",
            "RelaxLevel", "Flag_LenOver", "Flag_WidOver", "Flag_HeightTol", "Flag_HeightForce1",
            "Overhang_L_in", "Overhang_W_in", "OverHeight_in",
            "HeightLimit_in", "HeightPolicy",
            "Unit_Weight(KG)", "SCOOPWeightKG_Orig", "SCOOPWeightKG_Final", "Flag_WeightCapped"
        ]})
        continue

    # —— 动态高度上限：RAILS 用 1.1 m，其余 1.7 m ——
    itmclsid = str(r.get("ITMCLSID", "")).strip().upper()
    max_h_cm = HEIGHT_LIMIT_CM_RAILS if itmclsid == "RAILS" else HEIGHT_LIMIT_CM_DEFAULT
    max_h_in = max_h_cm * CM_TO_IN

    plan = pick_best_plan(float(L), float(W), float(H), max_h_in, H_TOL_IN)

    # 取单件重量；优先用表里的 Unit_Weight(KG)
    unit_w = r.get("Unit_Weight(KG)", np.nan)
    unit_w = float(unit_w) if pd.notna(unit_w) else None

    # 计算原重量（若表里有 SCOOP_Weight(KG) 也保留对比）
    TI, HI = int(plan["TI"]), int(plan["HI"])
    scoop_orig = TI * HI
    weight_calc_orig = (unit_w * scoop_orig) if unit_w else None
    weight_col_orig = r.get("SCOOP_Weight(KG)", np.nan)
    weight_col_orig = float(weight_col_orig) if pd.notna(weight_col_orig) else None

    # 触发条件：若 任一 原重量 > 1500，则执行调整（只减不加）
    need_cap = False
    for v in (weight_calc_orig, weight_col_orig):
        if v is not None and v > PALLET_WEIGHT_CAP_KG:
            need_cap = True;
            break

    if need_cap:
        new_HI, new_Total, new_VU, hit_cap_flag, w_orig, w_final = \
            adjust_height_by_weight(plan, unit_w, PALLET_WEIGHT_CAP_KG)
        # 覆盖计划中的 HI/Total/VU
        plan["HI"] = new_HI
        plan["Total"] = new_Total
        plan["VolumeUtil"] = new_VU
        weight_final = w_final
    else:
        hit_cap_flag = False
        weight_final = weight_calc_orig

    f = plan["flags"]
    rows.append({
        "Best_Pallet": plan["Pallet"],
        "Best_Ori": plan["Ori"],
        "NX": int(plan["NX"]),
        "NY": int(plan["NY"]),
        "NZ": int(plan["HI"]),  # = HI (可能被调整过)
        "TI": int(plan["TI"]),
        "HI": int(plan["HI"]),
        "Total": int(plan["Total"]),
        "FootprintUtil": round(plan["FootprintUtil"], 4),
        "VolumeUtil": round(plan["VolumeUtil"], 4),
        "SCOOP": int(plan["Total"]),
        "RelaxLevel": int(plan["relax_level"]),
        "Flag_LenOver": "Y" if f["LEN_OVER"] else "",
        "Flag_WidOver": "Y" if f["WID_OVER"] else "",
        "Flag_HeightTol": "Y" if f["H_TOL"] else "",
        "Flag_HeightForce1": "Y" if f["H_FORCE1"] else "",
        "Overhang_L_in": round(plan["over_len"], 3),
        "Overhang_W_in": round(plan["over_wid"], 3),
        "OverHeight_in": round(plan["over_hgt"], 3),
        "HeightLimit_in": round(plan["max_h_in"], 3),
        "HeightPolicy": "RAILS(1.1m)" if itmclsid == "RAILS" else "Default(1.7m)",
        "Unit_Weight(KG)": unit_w if unit_w is not None else "",
        "SCOOPWeightKG_Orig": round(weight_calc_orig, 3) if weight_calc_orig is not None else (
            round(weight_col_orig, 3) if weight_col_orig is not None else ""),
        "SCOOPWeightKG_Final": round(weight_final, 3) if weight_final is not None else "",
        "Flag_WeightCapped": "Y" if hit_cap_flag else ""
    })

out_df = pd.concat([df, pd.DataFrame(rows)], axis=1)

# 小货标注
max_dim_in_all = out_df[["CRTLIN", "CRTWIN", "CRTHIN"]].max(axis=1)
out_df["小货_小于30cm"] = np.where(max_dim_in_all < SMALL_TH_IN, "Y", "")

# 导出
out_df.to_csv(outfile_csv, index=False, encoding="utf-8-sig")

# 小货另存
small_mask = max_dim_in_all < SMALL_TH_IN
small_df = df.loc[small_mask].copy()
small_df["MaxDim_cm"] = (max_dim_in_all[small_mask] * IN_TO_CM).round(2)
small_df.to_csv(outfile_small_csv, index=False, encoding="utf-8-sig")

print(f"已生成主结果: {outfile_csv}")
