# HJ WMS Slotting Report Logic

> **Note:** HJ already has replenishment logic. This report **does not replace replenishment**; it is only responsible for "Location Strategy Adjustment Recommendations (re-slotting)."

## 1. Main Objectives (Redefined)
The primary purpose of this report is not replenishment, but rather:
1.  **Analyze the distribution** of "Fast Items" in the storage zones (A/B/C areas).
2.  Move the Forward Picking (FWP) Location of **Fast Items** from Zones C/B to **Zone A (Priority)**.
3.  Move the FWP Location of **Normal Items** from **Zone A** to Zones B/C.
4.  For **Slow Moving Items** with no demand, recommend **canceling their ground FWP locations** and moving them to Zone C or upper shelf levels.

---

## 2. Boundaries with HJ WMS (Critical)
**Current HJ WMS Logic:**
- Each item is bound to 1 FWP location.
- FWP locations are always on the ground level.
- When the FWP location inventory is `< setup qty`, the system automatically generates a replenishment WKQS task, sent to Reach Truck employees via handheld scanners.

**Therefore, the responsibility of this report is:**
- **Only output "Move Recommendations" (re-slotting)**;
- Do not interfere with HJ's replenishment trigger and execution mechanism;
- The output results can be converted by IT into "Master Data Adjustment Tasks."

---

## 3. Stratification & Zoning Strategy

### 3.1 SKU Demand Stratification (Recommended)
- **Fast Item:** High-frequency demand (e.g., high frequency of Open CO/Trip in the last 14 days).
- **Normal Item:** Medium demand.
- **Slow Moving:** No demand (demand is 0 in the last 14 days).

### 3.2 Zoning Policy (Area Policy)

1) **Fast Item**
- **Goal:** Place in Zone A ground FWP as much as possible.
- Currently in Zone B/C ground FWP: Mark for "Move to Zone A".
- If no positions are available in Zone A, enter the waiting queue.

2) **Normal Item**
- **Goal:** Evacuate from Zone A, move to Zone B/C ground FWP.
- Release Zone A space for Fast Items.

3) **Slow Moving Item**
- **Goal:** Cancel its ground FWP location.
- Move to Zone C or upper-level storage, no longer occupying ground-level FWP space.

---

## 4. Rule Engine

### Rule-F1 (Fast Move Up)
`IF 'item_type = FAST' AND 'current_fwp_area IN ('C', 'B')'`  
`THEN 'action = MOVE_FWP_TO_A'`

### Rule-N1 (Normal Move Down)
`IF 'item_type = NORMAL' AND 'current_fwp_area = 'A''`  
`THEN 'action = MOVE_FWP_TO_B' OR 'action = MOVE_FWP_TO_C'`

### Rule-S1 (Slow Moving - Cancel FWP)
`IF 'item_type IN ('NO_DEMAND')'`  
`THEN 'action = REMOVE_FWP_AND_MOVE_UPPER'`

### Rule-C1 (Capacity/Availability Check)
`IF target area has no available ground FWP location for slotting`  
`THEN 'action_status = PENDING_CAPACITY'`

---

## 5. Output Result Structure for IT / WMS
Three suggested output result sets:

1.  **`slotting_fast_to_a_task`**
    - `item_id`, `current_fwp_loc`, `current_area`, `target_area='A'`, `suggested_target_loc`, `reason='FAST_ITEM_PRIORITY'`

2.  **`slotting_normal_to_b_task` or `slotting_normal_to_c_task`**
    - `item_id`, `current_fwp_loc`, `current_area='A'`, `target_area in ('B', 'C')`, `suggested_target_loc`, `reason='RELEASE_A_FOR_FAST'`

3.  **`slotting_slow_remove_fwp_task`**
    - `item_id`, `current_fwp_loc`, `action='REMOVE_FWP'`, `suggested_upper_loc`, `reason='NO_DEMAND'`

---

## 6. Key KPIs (for Acceptance)
1.  **Coverage Rate of Fast Items in Zone A** (Goal: Increase);
2.  **Occupancy Ratio of Zone A by Normal Items** (Goal: Decrease);
3.  **Ground FWP Ratio for Slow Moving Items** (Goal: Decrease);
4.  **Execution Success Rate of HJ Auto-Replenishment WKQS** (Goal: No decrease);
5.  **Change in Picking Efficiency** 2-4 weeks after migration (Travel distance / Picking frequency).