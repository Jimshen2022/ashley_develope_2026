# 仓库库位编码生成规则（Warehouse Location Code Generation Rules）

本文档描述如何根据通道（Aisle）、货架排（Bay）规则，自动生成仓库库位编码（Location Code）及相关字段。适用于批量生成库位主数据。

## 1. 总体结构

每条库位记录包含以下字段：

| 字段 | 说明 | 示例 |
|---|---|---|
| Location | 完整库位编码 | A3036CA1 |
| Building | 建筑编号（固定值） | A3 |
| Aisle | 通道号（3位数字字符串） | 036 |
| Bay_Number | 货架排号（整数） | 1 |
| Section | 货架区位编码（2个字母） | CA |
| Level | 层数（1~4） | 1 |
| Side | 通道侧（C 或 D） | C |
| Picking_Sequence | 拣货顺序号 | 10360000001 |

**Location 编码组成方式：**

```
Location = "A3" + Aisle(3位) + Section(2个字母) + Level(1位数字)
```

例如：`A3` + `036` + `CA` + `1` = `A3036CA1`

## 2. 通道（Aisle）配置

每个通道需要配置：
- **通道号**（aisle）：3位数字字符串，如 `036`、`037`
- **Bay范围**：固定为 1~53（每个通道共 53 个 Bay）
- **方向（direction）**：
  - `forward`：Bay从 1 递增到 53
  - `backward`：Bay从 53 递减到 1

**方向交替规则**：相邻通道方向相反，依次交替。
例如从通道36到50：36=forward, 37=backward, 38=forward, 39=backward ... 以此类推（奇偶交替）。

## 3. Section（货架区位）编码规则 —— 核心规则

Section 由两个字母组成：**第一个字母** + **第二个字母**。

### 3.1 第一个字母（决定大区位，随 Bay 分组变化）

- **每 6 个 Bay 换一次**第一个字母
- Side C（C侧）使用字母序列（按顺序循环）：
  ```
  C, E, G, J, L, N, Q, S, U, W, Y
  ```
- Side D（D侧）使用字母序列（按顺序循环）：
  ```
  D, F, H, K, M, P, R, T, V, X, Z
  ```
- 计算方式：
  ```
  group_index = (bay - 1) // 6
  第一个字母 = 字母序列[group_index % 字母序列长度]
  ```
- 共11个字母可用，每个字母覆盖6个Bay，11×6=66，足够覆盖53个Bay，不会循环重复。

### 3.2 第二个字母（决定Bay内的4个子位置，随Bay内位置变化）

- 使用以下 **24个字母**（跳过 I 和 O，避免与数字1、0混淆）：
  ```
  A, B, C, D, E, F, G, H, J, K, L, M, N, P, Q, R, S, T, U, V, W, X, Y, Z
  ```
- 每个 Bay 占用其中**连续的4个字母**
- 计算方式：
  ```
  position_in_group = (bay - 1) % 6      # 在当前6-Bay组内的位置，0~5
  second_letters_start = position_in_group * 4
  该Bay的4个第二字母 = 24字母序列[second_letters_start : second_letters_start + 4]
  ```
- 每用完一组24个字母（即6个Bay后），下一个Bay会随第一个字母推进，重新从24字母序列开头取值。

### 3.3 示例对照表（通道036，Side C）

| Bay | 第一个字母 | 第二个字母（4个） | 对应Section |
|---|---|---|---|
| 1 | C | A,B,C,D | CA, CB, CC, CD |
| 2 | C | E,F,G,H | CE, CF, CG, CH |
| 3 | C | J,K,L,M | CJ, CK, CL, CM |
| 4 | C | N,P,Q,R | CN, CP, CQ, CR |
| 5 | C | S,T,U,V | CS, CT, CU, CV |
| 6 | C | W,X,Y,Z | CW, CX, CY, CZ |
| 7 | E（换字母） | A,B,C,D | EA, EB, EC, ED |
| 8 | E | E,F,G,H | EE, EF, EG, EH |
| ... | ... | ... | ... |

Side D 的逻辑完全相同，只是第一个字母用 D,F,H,K,M,P,R,T,V,X,Z 序列。

## 4. 每个 Bay 生成的 Location 数量

每个 Bay：
- 4个Section（第二字母）
- × 4层（Level：1,2,3,4）
- × 2个Side（C、D）
- = **32个 Location**

公式：
```
每个通道总Location数 = 53(Bay数) × 32 = 1696
```

## 5. 遍历顺序（生成顺序）

对每个通道，按以下嵌套顺序遍历生成：

```
for bay in (1→53 或 53→1，取决于direction):
    确定该bay的第一个字母（C侧、D侧各一个）
    确定该bay的4个第二字母
    for side in [C, D]:
        for 第二字母 in 该bay的4个第二字母:
            section = 第一个字母 + 第二字母
            for level in [1, 2, 3, 4]:
                生成一条Location记录
```

（实际实现中，先遍历完Side C的全部4×4=16条，再遍历Side D的16条）

## 6. Picking_Sequence（拣货顺序号）规则

- 格式：`"1" + Aisle(3位) + 序号(7位，左侧补0)`
- 例如：通道036的第1条记录 → `10360000001`
- **序号在每个通道内重新从1开始计数**，按生成顺序（即上面第5节的遍历顺序）递增
- 整个通道生成完毕后，序号最大值 = 该通道总Location数（即1696）

## 7. 唯一性保证

只要严格按照以上规则：
- 第一个字母每6个Bay变化一次，11个字母可覆盖66个Bay（实际只用53个，不会用尽）
- 第二个字母24个一组，与Bay内位置一一对应
- 这样组合出的 Section（2字母）在整个通道内**绝对不会重复**
- 最终生成的 Location 编码（Building+Aisle+Section+Level）在全部数据中**完全唯一**

## 8. 完整示例（通道036，Bay 1，Side C，全部4层）

| Location | Bay_Number | Section | Level | Side | Picking_Sequence |
|---|---|---|---|---|---|
| A3036CA1 | 1 | CA | 1 | C | 10360000001 |
| A3036CA2 | 1 | CA | 2 | C | 10360000002 |
| A3036CA3 | 1 | CA | 3 | C | 10360000003 |
| A3036CA4 | 1 | CA | 4 | C | 10360000004 |
| A3036CB1 | 1 | CB | 1 | C | 10360000005 |
| ... | ... | ... | ... | ... | ... |
