# AQUERY Department Top 50 Core Reports

## Selection Rule

AQUERY objects with LAST_USED_TIMESTAMP >= CURRENT TIMESTAMP - 1 YEAR, sorted within department by OPEN_OPERATIONS DESC, DAYS_USED_COUNT DESC, LOGICAL_READS DESC, top 50 per department.

This layer groups recently used `AFIPROD.AQUERY` report objects by enterprise department function. It is a practical routing map for future AS400 / MAPICS work, not an audited user-by-user access log.

Recent-year AQUERY objects classified: 2,681.

Frequency proxy: `OPEN_OPERATIONS`, with `DAYS_USED_COUNT` and `LOGICAL_READS` as tie-breakers. `LAST_USED_TIMESTAMP` must be within the last year.

## Department Routing Rule

Prefer this reference when the user asks which AQUERY report to use for a department, business function, operational KPI, or repeated warehouse/AS400 analysis. Start with the department Top 50 before searching long-tail AQUERY workfiles.

Classification principle: table name and table text are primary; column descriptions are fallback for blank/cryptic workfiles. This avoids assigning WIP reports to Finance only because they contain amount fields, or transaction-history reports to Purchasing only because they contain vendor fields.

Departments:
- Distribution Transportation and Shipping: 469 recently used objects.
- Inventory Control and Materials: 410 recently used objects.
- Finance Costing and Accounting: 405 recently used objects.
- Product Engineering Item Master and BOM: 354 recently used objects.
- Manufacturing Production and Labor: 318 recently used objects.
- General Analyst Workfiles: 223 recently used objects.
- Warehouse Operations and WMS: 167 recently used objects.
- Purchasing Procurement and Vendor: 152 recently used objects.
- Supply Chain Planning and ATP: 110 recently used objects.
- Sales Customer Service and Orders: 67 recently used objects.
- Data Reference and Excel Automation: 6 recently used objects.

## Distribution Transportation and Shipping

Recently used objects in department: 469.

Most-used reports:

- 01. `DH_TFR1ALL`: opens 980, days 42, rows 342. signals: item, warehouse, quantity, trip_transfer, ship_invoice.
- 02. `DWTRPNOTIP`: opens 193, days 2117, rows 19529. Trps Not Invoice (Not In Tsinxna3); signals: item, quantity, order, trip_transfer, ship_invoice, vendor_customer.
- 03. `DWTRPNOTPP`: opens 156, days 2117, rows 100. Pennsylvannia - Trps Not Posted - Transfers; signals: item, trip_transfer.
- 04. `MB_SH0526`: opens 45, days 14, rows 1752425. SHIPPED HISTORY - MAY 2026; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 05. `UNINVOIC`: opens 37, days 1107, rows 54331. signals: item, warehouse, quantity, order, cost_price, vendor_customer.
- 06. `MB_SH0626`: opens 36, days 10, rows 2304453. SHIPPED HISTORY - JUN 2026; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 07. `MB_SH0426`: opens 23, days 11, rows 1712225. SHIPPED HISTORY - APR 2026; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 08. `MB_SH0915`: opens 11, days 1117, rows 2027346. shipped history - SEP 2015; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 09. `TS_SHP0520`: opens 10, days 974, rows 2597646. SHIPPED HISTORY - MAY 2020; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 10. `MB_SH0722`: opens 10, days 390, rows 2303667. shipped history - JUL 2022; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 11. `MB_RTS0722`: opens 10, days 390, rows 2245. RETURNS TO STOCK DATABASE; signals: item, warehouse, quantity.
- 12. `ARINVOICED`: opens 10, days 7, rows 50. signals: ship_invoice.
- 13. `MB_WVSHP`: opens 9, days 2, rows 2336164. WANVOG SHIPMENTS; signals: item, warehouse, order, trip_transfer, ship_invoice, cost_price, bom_component, vendor_customer.
- 14. `MB_SH0126`: opens 8, days 14, rows 1767700. SHIPPED HISTORY - JAN 2026; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 15. `TS_AFIRET1`: opens 8, days 1, rows 253019. signals: item, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 16. `MB_SH0326`: opens 7, days 7, rows 2363312. SHIPPED HISTORY - MAR 2026; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 17. `MB_SH0226`: opens 6, days 14, rows 1780687. SHIPPED HISTORY - FEB 2026; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 18. `MB_SH0726`: opens 6, days 2, rows 892749. SHIPPED HISTORY - JUL 2026; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 19. `TA_IMP`: opens 6, days 2, rows 433193. FREIGHT BY ITEM NUMBER BY ITEM CLASS; signals: item, quantity, cost_price.
- 20. `BG_TRNINVE`: opens 6, days 2, rows 7011. MISC INV ADJS - ADVANCE; signals: item, warehouse, quantity, trip_transfer, cost_price, vendor_customer.
- 21. `RK_FTWORTH`: opens 6, days 1, rows 45598. signals: item, order, trip_transfer, cost_price, vendor_customer.
- 22. `MB_MAPAUTO`: opens 6, days 1, rows 144988. MAPICS AUTOMATION; signals: item, warehouse, quantity, trip_transfer, cost_price.
- 23. `MAHOTLIST8`: opens 6, days 1, rows 999. DOM ECR Itms - Trps Not Invoice (Not In Tsinxna3); signals: item, quantity, ship_invoice.
- 24. `MAHOTLIST1`: opens 6, days 1, rows 999. DOMESTIC Itms - Trps Not Invoice (Not In Tsinxna3); signals: item, quantity, ship_invoice.
- 25. `LH_SLHOME2`: opens 6, days 1, rows 309. ASHLEY HOMESTORES; signals: item, quantity, order, ship_invoice, cost_price, vendor_customer.
- 26. `TA_IMPRAW`: opens 5, days 2, rows 744678. FREIGHT BY ITEM NUMBER BY ITEM CLASS; signals: item.
- 27. `MB_WVSHIP`: opens 5, days 2, rows 89252. WANVOG AND WANEK SHIPMENTS; signals: item, warehouse, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 28. `MB_WHSERW1`: opens 5, days 1, rows 159241. WHSE TRANSFER RECEIPTS; signals: item, warehouse, quantity, order, trip_transfer.
- 29. `MB_3PERROR`: opens 5, days 1, rows 96279. signals: order, trip_transfer, ship_invoice, cost_price, vendor_customer, location.
- 30. `MB_WVSHDOM`: opens 5, days 1, rows 40765. WANEK SHIPMENTS DOM; signals: item, warehouse, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 31. `MB_SHPUSA`: opens 5, days 1, rows 14593. USA SHIPMENTS; signals: item, warehouse, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 32. `AAALLOWS1`: opens 4, days 1023, rows 3222. Data range for finding allowances - Step one; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 33. `MB_SH0117`: opens 4, days 983, rows 1689344. shipped history - JAN 2017; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 34. `MB_SH0922`: opens 4, days 326, rows 2903563. shipped history - SEP 2022; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 35. `MB_SH1125`: opens 4, days 17, rows 1968174. SHIPPED HISTORY - NOV 2025; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 36. `RK_RKREP20`: opens 4, days 1, rows 102302. signals: item, quantity, order, trip_transfer, vendor_customer.
- 37. `RK25101601`: opens 4, days 1, rows 21300. Transfers; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, planning.
- 38. `RK_CAREP20`: opens 4, days 1, rows 8305. signals: item, quantity, order, trip_transfer, vendor_customer.
- 39. `JR_SA123TL`: opens 4, days 1, rows 8503. RETURNS TOTAL FROM SA123; signals: item, warehouse, quantity, ship_invoice, cost_price, vendor_customer, location.
- 40. `JR_RTSTK1`: opens 4, days 1, rows 2738. RETURNS TO STOCK; signals: item, warehouse, quantity, cost_price.
- 41. `RK_RKREP22`: opens 4, days 1, rows 4267. signals: item, quantity, order, trip_transfer.
- 42. `RK25101600`: opens 4, days 1, rows 891. signals: item, quantity, trip_transfer.
- 43. `TS_AFILEF1`: opens 3, days 2, rows 2304453. SHIPPED HISTORY - JUN 2026; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 44. `MK_CUSPRIC`: opens 3, days 2, rows 45956. signals: ship_invoice, cost_price, vendor_customer.
- 45. `BN_TRNINVE`: opens 3, days 2, rows 4790. MISC INV ADJS - ECRU; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer.
- 46. `MB_RTS0626`: opens 3, days 2, rows 2738. RETURNS TO STOCK DATABASE; signals: item, warehouse, quantity.
- 47. `WMV_RTRN1`: opens 3, days 2, rows 2859. signals: item, trip_transfer, vendor_customer.
- 48. `AH_TRNINVR`: opens 3, days 2, rows 1054. MISC INV ADJS - RIPLEY; signals: item, warehouse, quantity, trip_transfer.
- 49. `TW_DM_VR`: opens 3, days 2, rows 22. signals: item, warehouse, quantity, order, trip_transfer, cost_price, vendor_customer.
- 50. `TW_DM_VR1`: opens 3, days 2, rows 18. signals: item, warehouse, quantity, order, trip_transfer, cost_price, vendor_customer.

Usage guidance:
- Use for transfers, trips, freight, shipped history, invoices, warehouse receipts, tracking, returns-to-stock, and not-posted/not-invoiced investigations.
- First-pass candidates: `DH_TFR1ALL`, `DWTRPNOTIP`, `DWTRPNOTPP`, `MB_SH0526`, `UNINVOIC`, `MB_SH0626`, `MB_SH0426`, `MB_SH0915`, `TS_SHP0520`, `MB_SH0722`, `MB_RTS0722`, `ARINVOICED`.

## Inventory Control and Materials

Recently used objects in department: 410.

Most-used reports:

- 01. `DWPENMAPIC`: opens 156, days 2117, rows 11839. DOMESTIC Itms - Tot Qty By Item Using MAPICS Files; signals: item, quantity.
- 02. `DWPENAUD5E`: opens 78, days 1375, rows 9553. signals: item, quantity.
- 03. `MB_IMH0526`: opens 74, days 15, rows 5929963. Transaction History Save - MAY 2026; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 04. `RK_WEIGHT`: opens 61, days 31, rows 58729. signals: item, cost_price.
- 05. `MB_IMH0626`: opens 55, days 10, rows 7186401. Transaction History Save - JUNE 2026; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 06. `MB_IMH0426`: opens 46, days 21, rows 5950438. Transaction History Save - APR 2026; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 07. `MB_IMH0326`: opens 38, days 26, rows 7777259. Transaction History Save - MAR 2026; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 08. `MB_IMH0126`: opens 33, days 31, rows 6182043. Transaction History Save - JAN 2026; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 09. `DH_IMHSTOB`: opens 30, days 2, rows 21202. signals: item, quantity.
- 10. `MB_IMH0226`: opens 27, days 26, rows 6098185. Transaction History Save - FEB 2026; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 11. `MB_IMH0726`: opens 26, days 4, rows 2813373. Transaction History Save - JULY 2026; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 12. `KAG_ITMASA`: opens 23, days 1050, rows 1089. active raw material items; signals: item.
- 13. `AK_CDSTAT`: opens 23, days 1049, rows 137031. signals: item, warehouse.
- 14. `MB_IMH0123`: opens 17, days 184, rows 7083749. Transaction History Save - JAN 2023; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 15. `MB_IMHYE26`: opens 16, days 1, rows 26007925. IMHIST WITH ALL MONTHS; signals: item, warehouse, quantity, order, trip_transfer, cost_price.
- 16. `MB_IMH1219`: opens 12, days 1124, rows 9541464. Transaction History Save - DEC 2019; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 17. `LD_CUBE`: opens 12, days 2, rows 406746. signals: item.
- 18. `JB_IAADJ`: opens 10, days 2, rows 1749. signals: item, warehouse, quantity.
- 19. `MB_IMH0219`: opens 8, days 1018, rows 8553436. Transaction History Save - FEB 2019; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 20. `MK_RM`: opens 8, days 2, rows 27019. signals: item, quantity.
- 21. `MK_IMHMOYR`: opens 8, days 1, rows 239528. signals: item, quantity.
- 22. `RK_ONHTOT`: opens 7, days 1, rows 8028. signals: item, warehouse, quantity.
- 23. `RK_TAONH`: opens 6, days 1, rows 62643. signals: item, warehouse, quantity.
- 24. `RK_RECTSTK`: opens 6, days 1, rows 36354. MONTHLY INVENTORY ISSUES FILE; signals: warehouse, quantity, order.
- 25. `RK_MAT0603`: opens 6, days 1, rows 195. signals: item, warehouse.
- 26. `CS_CDSTAT`: opens 5, days 477, rows 2600858. signals: item, warehouse.
- 27. `MB_IMH2025`: opens 5, days 5, rows 85326649. Transaction History Save - 2025; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 28. `TA_CLASSUP`: opens 5, days 2, rows 1222. LIST OF ITEM CLASSES IN IFM OPTION; signals: item.
- 29. `RK_TAONHP`: opens 5, days 1, rows 102018. signals: item, warehouse, quantity.
- 30. `SCH_STATUS`: opens 5, days 1, rows 240731. signals: item.
- 31. `MB_RPCUBE`: opens 5, days 1, rows 194350. signals: item, cost_price, vendor_customer.
- 32. `MB_IMH0420`: opens 4, days 1013, rows 3023907. Transaction History Save - APR 2020; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 33. `MB_IMH1119`: opens 4, days 1000, rows 8844768. Transaction History Save - NOV 2019; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 34. `MB_IMH0121`: opens 4, days 923, rows 7072469. Transaction History Save - JAN 2021; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 35. `MB_ITCLCTL`: opens 4, days 4, rows 400. Download of file ITCLCTL; signals: item.
- 36. `MB_IMH2026`: opens 4, days 1, rows 25999960. Transaction History Save - YTD 2026; signals: item, warehouse, quantity, order, trip_transfer, vendor_customer, location.
- 37. `RK_MENARDS`: opens 4, days 1, rows 23. signals: item, warehouse, quantity.
- 38. `AFIINVUN`: opens 3, days 1023, rows 775255. signals: item.
- 39. `MB_ITEMBL`: opens 3, days 2, rows 3420852. ITEM BALANCE SAVE WITH SITE ID; signals: item, warehouse, quantity, order.
- 40. `MK_ITEMBAL`: opens 3, days 2, rows 74449. signals: item, warehouse, quantity.
- 41. `MB_AITMCLS`: opens 3, days 2, rows 1222. signals: item.
- 42. `MK_ITMDESC`: opens 3, days 1, rows 573452. signals: item.
- 43. `RK_ITEMASA`: opens 3, days 1, rows 229495. signals: item, quantity.
- 44. `MK_MOLOTSZ`: opens 3, days 1, rows 53880. signals: item, quantity, order.
- 45. `MB_IMHAUD1`: opens 3, days 1, rows 51895. signals: item, warehouse, quantity.
- 46. `KM_RKD904`: opens 3, days 1, rows 31119. signals: item, quantity.
- 47. `RK_RKREP23`: opens 3, days 1, rows 23525. signals: item.
- 48. `RK_REDFC`: opens 3, days 1, rows 13066. signals: item.
- 49. `RK_ECR`: opens 3, days 1, rows 11842. signals: item, warehouse, quantity.
- 50. `RK_1`: opens 3, days 1, rows 11662. signals: item, warehouse, quantity.

Usage guidance:
- Use for item balance, on-hand, IMHIST movement history, inventory issues, serial/status, material quantities, and inventory variance triage.
- First-pass candidates: `DWPENMAPIC`, `DWPENAUD5E`, `MB_IMH0526`, `RK_WEIGHT`, `MB_IMH0626`, `MB_IMH0426`, `MB_IMH0326`, `MB_IMH0126`, `DH_IMHSTOB`, `MB_IMH0226`, `MB_IMH0726`, `KAG_ITMASA`.

## Finance Costing and Accounting

Recently used objects in department: 405.

Most-used reports:

- 01. `KM_RPLIST`: opens 96, days 1027, rows 41764. Ecru exception i-classes,BP, cost, and e-class; signals: item, cost_price.
- 02. `KM_RPDATA`: opens 96, days 65, rows 88236. Ecru exception i-classes,BP, cost, and e-class; signals: item, cost_price.
- 03. `MB_FOB0526`: opens 82, days 29, rows 625649. MBBZRES1 File - MAY 2026; signals: item, cost_price.
- 04. `MB_FOB0426`: opens 78, days 26, rows 620096. MBBZRES1 File - APR 2026; signals: item, cost_price.
- 05. `RK_PRICE`: opens 40, days 199, rows 46. signals: item, cost_price.
- 06. `DPH_BLOPEN`: opens 38, days 1303, rows 651. signals: item, warehouse, quantity, cost_price.
- 07. `MB_FOB0626`: opens 35, days 14, rows 632580. MBBZRES1 File - JUN 2026; signals: item, cost_price.
- 08. `MB_ITEMASB`: opens 27, days 3, rows 233770. ITEM MASTER CURRENT COST - FINISHED GOODS; signals: item, quantity, cost_price, labor_wip, vendor_customer.
- 09. `DPH_ITMASB`: opens 25, days 1055, rows 32510. ITEM MASTER CURRENT COST - FINISHED GOODS; signals: item, quantity, cost_price, labor_wip, vendor_customer.
- 10. `MB_ITRVALL`: opens 23, days 3, rows 433392. ITEM MASTER CURRENT COST - FINISHED GOODS; signals: item, quantity, cost_price, labor_wip, vendor_customer.
- 11. `MB_FOB1119`: opens 22, days 1162, rows 388060. MBBZRES1 File - NOVEMBER 2019; signals: item, cost_price.
- 12. `RK_FOBARC`: opens 18, days 21, rows 183535. signals: item, cost_price.
- 13. `MB_CRD0526`: opens 12, days 4, rows 4. DATABASE OF CREDITS AND REBILLS; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice.
- 14. `TS_FOBVALU`: opens 11, days 1115, rows 114. FOB VALUE OF ITEM BALANCE FILE ALL Z CLASS ITEMS; signals: item, quantity, cost_price.
- 15. `MB_IMOCT13`: opens 11, days 1113, rows 1549914. MONTH END ITEM MASTER AT CURRENT COST; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 16. `VA_WKUPHFB`: opens 11, days 1096, rows 6. signals: warehouse, quantity, cost_price.
- 17. `VA_WKUPH5A`: opens 11, days 1093, rows 20. signals: item, quantity, cost_price.
- 18. `VA_WKUPHLT`: opens 11, days 1090, rows 6. signals: warehouse, quantity, cost_price.
- 19. `RK_STDUC1`: opens 11, days 41, rows 53269. signals: item, quantity, cost_price.
- 20. `MB_FOB`: opens 9, days 1, rows 240765. FOB DOWNLOAD; signals: item, cost_price.
- 21. `MB_CRD0626`: opens 8, days 3, rows 269. DATABASE OF CREDITS AND REBILLS; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice.
- 22. `TS_AFIRET3`: opens 8, days 1, rows 48329. SPECIAL CHARGES - HOMESTORES; signals: order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 23. `TA_MEREBIL`: opens 8, days 1, rows 8. AFI3031 MONTHEND REBILL; signals: warehouse, cost_price.
- 24. `MK_SPCLCHG`: opens 7, days 1, rows 391005. MONTHLY SPECIAL CHARGES; signals: warehouse, ship_invoice, vendor_customer.
- 25. `MB_FOB1025`: opens 6, days 35, rows 606777. MBBZRES1 File - OCT 2025; signals: item, cost_price.
- 26. `PI_ORDAFT`: opens 6, days 1, rows 994978. Comast after price increase; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 27. `MB_FOB0825`: opens 5, days 39, rows 599473. MBBZRES1 File - AUG 2025; signals: item, cost_price.
- 28. `MB_CRD0426`: opens 5, days 4, rows 46. DATABASE OF CREDITS AND REBILLS; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice.
- 29. `LD_PRICE`: opens 5, days 2, rows 14272670. signals: item, cost_price.
- 30. `KM_ARPDETL`: opens 4, days 1016, rows 253981. RP DETAIL BY CUSNO AND ITNBR; signals: item, quantity, order, ship_invoice, cost_price, vendor_customer.
- 31. `MB_FOB0925`: opens 4, days 42, rows 603045. MBBZRES1 File - SEP 2025; signals: item, cost_price.
- 32. `MB_FOB0326`: opens 4, days 26, rows 616812. MBBZRES1 File - MAR 2026; signals: item, cost_price.
- 33. `SN_ALLSCR1`: opens 4, days 2, rows 5721. SM SCRAP TRANSACTIONS FOR ADVANCE; signals: item, warehouse, quantity, order.
- 34. `MACREDIT`: opens 3, days 1014, rows 18391. Allowance files; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 35. `MB_FOB1225`: opens 3, days 37, rows 613975. MBBZRES1 File - DEC 2025; signals: item, cost_price.
- 36. `MB_FOB0625`: opens 3, days 31, rows 590990. MBBZRES1 File - JUN 2025; signals: item, cost_price.
- 37. `BG_COSTU`: opens 3, days 2, rows 2364510. Balance Summary by unit; signals: cost_price.
- 38. `YS_ITEMASB`: opens 3, days 2, rows 69204. ITEM MASTER CURRENT COST - FINISHED GOODS; signals: item, quantity, cost_price, labor_wip, vendor_customer.
- 39. `MK_PRICE4`: opens 3, days 1, rows 662844. signals: item, cost_price.
- 40. `LD_PRICE14`: opens 3, days 1, rows 506645. signals: item, warehouse, cost_price.
- 41. `MK_FOBHIST`: opens 3, days 1, rows 227022. signals: item, cost_price.
- 42. `BW_COSTU`: opens 3, days 1, rows 9066. Balance Summary by unit; signals: cost_price.
- 43. `LD_BUYGRPC`: opens 3, days 1, rows 8849. Container price file; signals: item, warehouse, cost_price.
- 44. `RK_PICNIC`: opens 3, days 1, rows 3441. signals: item, warehouse, quantity, cost_price.
- 45. `MB_SPCHF`: opens 3, days 1, rows 485. SPECIAL CHARGES; signals: warehouse, order, ship_invoice.
- 46. `SCH_HW$2`: opens 3, days 1, rows 2. signals: item, order, cost_price.
- 47. `MB_FGMISC`: opens 2, days 1038, rows 708666. Monthend Scrap Transactions; signals: item, warehouse, quantity, order, trip_transfer, cost_price, labor_wip.
- 48. `MB_FOB0924`: opens 2, days 45, rows 547754. MBBZRES1 File - SEP 2024; signals: item, cost_price.
- 49. `MB_FOB0425`: opens 2, days 43, rows 579411. MBBZRES1 File - APR 2025; signals: item, cost_price.
- 50. `MB_FOB0325`: opens 2, days 41, rows 574109. MBBZRES1 File - MAR 2025; signals: item, cost_price.

Usage guidance:
- Use for cost, price, FOB, GL, commission, credit/rebill, scrap, margin, value, and amount-driven analysis.
- First-pass candidates: `KM_RPLIST`, `KM_RPDATA`, `MB_FOB0526`, `MB_FOB0426`, `RK_PRICE`, `DPH_BLOPEN`, `MB_FOB0626`, `MB_ITEMASB`, `DPH_ITMASB`, `MB_ITRVALL`, `MB_FOB1119`, `RK_FOBARC`.

## Product Engineering Item Master and BOM

Recently used objects in department: 354.

Most-used reports:

- 01. `MB_IMMAY26`: opens 296, days 29, rows 2860142. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 02. `MB_IMJUN26`: opens 256, days 15, rows 2886605. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 03. `MB_IMAPR26`: opens 213, days 37, rows 2839394. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 04. `RK_ITMPRC1`: opens 110, days 1787, rows 1427. signals: item, warehouse, quantity, cost_price, labor_wip, bom_component, vendor_customer, location.
- 05. `MB_IMJUL26`: opens 96, days 6, rows 2894164. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 06. `JP_PKGOUT`: opens 78, days 2118, rows 580. signals: item, quantity, order, bom_component, vendor_customer.
- 07. `MB_IMMAR26`: opens 68, days 41, rows 2822544. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 08. `TO_PSSIZE`: opens 60, days 21, rows 8501. PANEL SAW CUT SIZES; signals: item, quantity, labor_wip, bom_component.
- 09. `TO_RTUPLOD`: opens 47, days 1, rows 157439. routing info download in upload format; signals: quantity, trip_transfer, labor_wip, bom_component.
- 10. `MB_IMDEC19`: opens 37, days 1197, rows 1854013. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 11. `MB_IMJAN26`: opens 37, days 55, rows 2815592. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 12. `MB_IMFEB26`: opens 35, days 42, rows 2829624. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 13. `MB_ISS0426`: opens 35, days 6, rows 339066. Product Structure Explosion File Save; signals: item, warehouse, quantity, cost_price, bom_component.
- 14. `MB_IMJUL22`: opens 30, days 395, rows 2285859. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 15. `MB_ISS0526`: opens 28, days 3, rows 339225. Product Structure Explosion File Save; signals: item, warehouse, quantity, cost_price, bom_component.
- 16. `MB_ISS0626`: opens 25, days 3, rows 338480. Product Structure Explosion File Save; signals: item, warehouse, quantity, cost_price, bom_component.
- 17. `MB_IMMAY25`: opens 21, days 107, rows 2695929. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 18. `MB_IMJAN23`: opens 17, days 197, rows 2289358. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 19. `MB_IMFEB19`: opens 14, days 1028, rows 1719294. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 20. `RK_PSTRUCK`: opens 14, days 982, rows 3719. signals: item, quantity, bom_component.
- 21. `RK_RKDKIT3`: opens 14, days 12, rows 17430. Trps Not Invoice (Not In Tsinxna3); signals: item, quantity, order, trip_transfer, ship_invoice, bom_component, vendor_customer.
- 22. `FS_PSOPS`: opens 12, days 1154, rows 8867. signals: labor_wip, bom_component.
- 23. `FEB2020LAB`: opens 12, days 1053, rows 554055. signals: item, warehouse, quantity, cost_price, labor_wip, bom_component.
- 24. `MB_IMMAY20`: opens 12, days 999, rows 1839886. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 25. `MB_IMJUL21`: opens 12, days 863, rows 2038876. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 26. `MB_IMSEP15`: opens 11, days 1115, rows 1645949. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 27. `FEB2020BO1`: opens 10, days 1053, rows 486501. signals: item, warehouse, cost_price, bom_component.
- 28. `MAR2020BOM`: opens 10, days 1048, rows 482635. signals: item, warehouse, cost_price, bom_component.
- 29. `MB_IMAPR21`: opens 10, days 848, rows 1937884. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 30. `MB_QTYPRAC`: opens 10, days 7, rows 2192. QTY PER ACCESSORIES; signals: item, quantity, bom_component.
- 31. `DH_ALLOCWK`: opens 9, days 2, rows 20127. signals: item, bom_component.
- 32. `MB_IMAPR25`: opens 8, days 54, rows 2668002. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 33. `MAR2020LAB`: opens 7, days 1, rows 1095708. signals: item, warehouse, quantity, cost_price, labor_wip, bom_component.
- 34. `TSLABBOM`: opens 7, days 1, rows 1631701. signals: item, warehouse, quantity, cost_price, labor_wip, bom_component.
- 35. `MAHOTLIS10`: opens 6, days 1, rows 3529. signals: item, bom_component.
- 36. `TSMONTHBOM`: opens 6, days 1, rows 19138. signals: item, warehouse, quantity, cost_price, bom_component.
- 37. `TO_RINCMS`: opens 5, days 1, rows 222703. clean version of p1 standards; signals: warehouse, labor_wip, bom_component.
- 38. `MB_ISSUPRD`: opens 5, days 1, rows 25017. Ripley Upholstery Issues; signals: item, warehouse, quantity, cost_price, bom_component.
- 39. `RK_RPSHPHD`: opens 5, days 1, rows 825. signals: warehouse, order, trip_transfer, ship_invoice, cost_price, vendor_customer, location.
- 40. `MB_IMJAN19`: opens 4, days 1002, rows 1702717. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 41. `MB_IMMAR20`: opens 4, days 1000, rows 1810462. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 42. `MB_IMNOV20`: opens 4, days 957, rows 1912784. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 43. `MB_IMAUG21`: opens 4, days 734, rows 2077513. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 44. `MB_IMMAR24`: opens 4, days 71, rows 2415953. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 45. `MB_PST0626`: opens 4, days 4, rows 2456987. PRODUCT STRUCTURE SAVE - JUN 2026; signals: item, quantity, cost_price, bom_component.
- 46. `MB_MOD0526`: opens 4, days 3, rows 1244294. MODATA FILE - MAY 2026; signals: item, warehouse, quantity, order, cost_price, bom_component, vendor_customer, location.
- 47. `RK_RIPKIT5`: opens 4, days 1, rows 0. Pennsylvannia - Items On NEEDLIST/FILL Trucks; signals: item, bom_component, planning.
- 48. `MB_IMJAN25`: opens 3, days 67, rows 2592298. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 49. `MB_IMFEB25`: opens 3, days 64, rows 2614911. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.
- 50. `MB_IMJUL25`: opens 3, days 54, rows 2750853. MONTH END ITEM REVISION; signals: item, quantity, cost_price, labor_wip, bom_component, vendor_customer.

Usage guidance:
- Use for item revision snapshots, product structure, BOM explosion, components, kits, package requirements, routing versions, and engineering attributes.
- First-pass candidates: `MB_IMMAY26`, `MB_IMJUN26`, `MB_IMAPR26`, `RK_ITMPRC1`, `MB_IMJUL26`, `JP_PKGOUT`, `MB_IMMAR26`, `TO_PSSIZE`, `TO_RTUPLOD`, `MB_IMDEC19`, `MB_IMJAN26`, `MB_IMFEB26`.

## Manufacturing Production and Labor

Recently used objects in department: 318.

Most-used reports:

- 01. `PICWIP005`: opens 110, days 1786, rows 10390452. Colton daily WIP; signals: item, warehouse, quantity, cost_price, labor_wip.
- 02. `PICWIP013`: opens 110, days 1786, rows 28720502. Ecru daily WIP; signals: item, warehouse, quantity, cost_price, labor_wip.
- 03. `PICWIP001`: opens 110, days 1786, rows 43231700. Arcadia daily WIP; signals: item, warehouse, quantity, cost_price, labor_wip.
- 04. `PICWIP012`: opens 110, days 1786, rows 9885982. Ripley daily WIP; signals: item, warehouse, quantity, cost_price, labor_wip.
- 05. `PICWIP015`: opens 109, days 1786, rows 14902725. LPT daily WIP; signals: item, warehouse, quantity, cost_price, labor_wip.
- 06. `R59@MICHAE`: opens 37, days 936, rows 91. Labor Analysis Download File; signals: cost_price, labor_wip.
- 07. `BH_CGM0626`: opens 35, days 7, rows 991416. Production RM's - JUN 2026; signals: item, warehouse, quantity, order.
- 08. `BH_CGM0526`: opens 34, days 11, rows 804026. Production RM's - MAY 2026; signals: item, warehouse, quantity, order.
- 09. `VA_WKUPH4`: opens 33, days 1096, rows 11568. signals: item, warehouse, quantity, order, cost_price, labor_wip.
- 10. `MB_LAB0626`: opens 25, days 2, rows 372832. Labor by Work Center - JUN 2026; signals: item, warehouse, quantity, cost_price, labor_wip, bom_component.
- 11. `R59@BRANDO`: opens 24, days 613, rows 0. Labor Analysis Download File; signals: cost_price, labor_wip.
- 12. `VA_WKUPH5`: opens 22, days 1192, rows 61. signals: item, warehouse, quantity, cost_price, labor_wip.
- 13. `BH_CGM0213`: opens 22, days 1177, rows 1023218. Production RM's - Feb 2013; signals: item, warehouse, quantity, order.
- 14. `MB_LAB0526`: opens 21, days 2, rows 367079. Labor by Work Center - MAY 2026; signals: item, warehouse, quantity, cost_price, labor_wip, bom_component.
- 15. `BH_CGM0426`: opens 20, days 13, rows 823369. Production RM's - APR 2026; signals: item, warehouse, quantity, order.
- 16. `MB_LAB0426`: opens 17, days 6, rows 372315. Labor by Work Center - APR 2026; signals: item, warehouse, quantity, cost_price, labor_wip, bom_component.
- 17. `MJ_WKUPH3`: opens 16, days 4, rows 12301. signals: item, warehouse, quantity, order, cost_price, labor_wip.
- 18. `BH_CGM1013`: opens 11, days 1177, rows 1007075. Production RM's - Oct 2013; signals: item, warehouse, quantity, order.
- 19. `MB_WKBEDPR`: opens 11, days 1109, rows 3302. signals: item, warehouse, quantity, order, cost_price, labor_wip.
- 20. `BH_CGM0721`: opens 11, days 895, rows 731589. Production RM's - JULY 2021; signals: item, warehouse, quantity, order.
- 21. `VA_WKCHRRM`: opens 11, days 302, rows 0. signals: item, warehouse, quantity, order, cost_price, labor_wip.
- 22. `BH_CGM0726`: opens 9, days 2, rows 348335. Production RM's - JUL 2026; signals: item, warehouse, quantity, order.
- 23. `BH_CGM0326`: opens 8, days 17, rows 1099446. Production RM's - MAR 2026; signals: item, warehouse, quantity, order.
- 24. `BH_CGM1120`: opens 7, days 1017, rows 809133. Production RM's - NOV 2020; signals: item, warehouse, quantity, order.
- 25. `MB_MO0526`: opens 6, days 2, rows 271225. SAVED MOMAST FILE - MAY 2026; signals: item, warehouse, quantity, order, cost_price, labor_wip, bom_component, vendor_customer.
- 26. `MB_MOWIP`: opens 6, days 1, rows 1856. signals: item, quantity, labor_wip.
- 27. `MB_MO0626`: opens 5, days 2, rows 264443. SAVED MOMAST FILE - JUN 2026; signals: item, warehouse, quantity, order, cost_price, labor_wip, bom_component, vendor_customer.
- 28. `MB_WC0626`: opens 5, days 2, rows 5210. MONTHLY WORK CENTER FILE SAVE - JUN 2026; signals: quantity, trip_transfer, cost_price, labor_wip, bom_component, location.
- 29. `BA_INDVDT`: opens 5, days 1, rows 7308. INDIVIDUAL DOWNTIME.
- 30. `MB_MOYE2`: opens 5, days 1, rows 1442. OPEN MO WIP YEAREND; signals: item, quantity, order, trip_transfer, labor_wip, bom_component.
- 31. `SCH_RM0220`: opens 5, days 1, rows 0. Production RM's - November 2010; signals: item, warehouse, quantity.
- 32. `MB_MO0426`: opens 4, days 2, rows 272112. SAVED MOMAST FILE - APR 2026; signals: item, warehouse, quantity, order, cost_price, labor_wip, bom_component, vendor_customer.
- 33. `MB_LABUPRD`: opens 4, days 1, rows 7151. Ripley Upholstery Labor by Work Center; signals: item, quantity, cost_price, labor_wip, bom_component.
- 34. `AD_INDVDT`: opens 4, days 1, rows 357. INDIVIDUAL DOWNTIME.
- 35. `WB_6000000`: opens 4, days 1, rows 317. signals: item, quantity, order, trip_transfer, ship_invoice, cost_price, labor_wip, vendor_customer.
- 36. `BH_CGM0219`: opens 3, days 1056, rows 1147587. Production RM's - FEB 2019; signals: item, warehouse, quantity, order.
- 37. `KM_CODESRP`: opens 3, days 1015, rows 5339. History of Transaction codes; signals: item, warehouse, quantity, order, trip_transfer, cost_price, labor_wip, vendor_customer.
- 38. `BH_CGM0126`: opens 3, days 13, rows 875913. Production RM's - JAN 2026; signals: item, warehouse, quantity, order.
- 39. `KM_OPSTABL`: opens 3, days 2, rows 16896. signals: labor_wip.
- 40. `MJ_WKUPH1`: opens 3, days 2, rows 12301. signals: item, warehouse, quantity, order, cost_price, labor_wip.
- 41. `BN_GMRIP`: opens 3, days 2, rows 1724. signals: item, quantity, cost_price, labor_wip.
- 42. `MK_PRIMNST`: opens 3, days 1, rows 452328. signals: item, cost_price, labor_wip, vendor_customer.
- 43. `MK_RPTCRD1`: opens 3, days 1, rows 108698. signals: item, quantity, order, cost_price, labor_wip, bom_component.
- 44. `KM_RPTADV1`: opens 3, days 1, rows 39700. signals: item, quantity, order, cost_price, labor_wip, bom_component.
- 45. `BN_LPTSTD1`: opens 3, days 1, rows 12625. LEESPORT LABOR STANDARDS; signals: item, warehouse, quantity, labor_wip.
- 46. `NC_INDVDT`: opens 3, days 1, rows 3784. INDIVIDUAL DOWNTIME.
- 47. `AS_INDVDT`: opens 3, days 1, rows 3050. INDIVIDUAL DOWNTIME.
- 48. `MD_QRYDRDW`: opens 3, days 1, rows 742. signals: labor_wip.
- 49. `EC_INDVDT`: opens 3, days 1, rows 1477. INDIVIDUAL DOWNTIME.
- 50. `PA_INDVDT`: opens 3, days 1, rows 1302. INDIVIDUAL DOWNTIME.

Usage guidance:
- Use for daily WIP, production raw material consumption, labor by work center, labor standards, routing/work-center, and downtime analysis.
- First-pass candidates: `PICWIP005`, `PICWIP013`, `PICWIP001`, `PICWIP012`, `PICWIP015`, `R59@MICHAE`, `BH_CGM0626`, `BH_CGM0526`, `VA_WKUPH4`, `MB_LAB0626`, `R59@BRANDO`, `VA_WKUPH5`.

## General Analyst Workfiles

Recently used objects in department: 223.

Most-used reports:

- 01. `BFT@CHRIST`: opens 184, days 1320, rows 3107. Board Footage Report Download File; signals: warehouse.
- 02. `TA_SERNO`: opens 67, days 1070, rows 148. SERNO.
- 03. `BB_WHSDTL1`: opens 18, days 6, rows 63. no catalog description.
- 04. `BB_GLDTL`: opens 16, days 1084, rows 51354. no catalog description.
- 05. `TA_MERTRNS`: opens 15, days 1, rows 52. AFI3031 DAMAGED RETURNS; signals: warehouse, cost_price.
- 06. `WMV_COLRC1`: opens 14, days 63, rows 9. no catalog description.
- 07. `BB_WHSDTL`: opens 13, days 7, rows 3190. no catalog description.
- 08. `BB_WHSDTL2`: opens 13, days 6, rows 6. no catalog description.
- 09. `TA_MERTSTK`: opens 7, days 1, rows 37. AFI3031 RETURN TO STOCK; signals: warehouse, quantity, cost_price.
- 10. `MK_SUPMAS`: opens 5, days 3, rows 1581. no catalog description.
- 11. `ML_GLDTL`: opens 5, days 1, rows 10213. no catalog description.
- 12. `RET_WAGE`: opens 4, days 560, rows 7225. no catalog description.
- 13. `DSG_WAGE`: opens 4, days 11, rows 5227. no catalog description.
- 14. `WMV_RCODE1`: opens 4, days 7, rows 111. Return Codes.
- 15. `RK_AL3`: opens 4, days 2, rows 5877. signals: order.
- 16. `SCH_APDTL1`: opens 4, days 2, rows 6. no catalog description.
- 17. `AP_GLDTL`: opens 4, days 1, rows 367. no catalog description.
- 18. `ML_GLPUB`: opens 4, days 1, rows 37. no catalog description.
- 19. `TW_ADSFRT`: opens 3, days 2, rows 227292. signals: order.
- 20. `MB_GLDTLIV`: opens 3, days 2, rows 1553. no catalog description.
- 21. `KM_DTCODES`: opens 3, days 2, rows 184. no catalog description.
- 22. `SP_UNITNAT`: opens 3, days 1, rows 29257. no catalog description.
- 23. `RK_EMPHOUR`: opens 3, days 1, rows 163. no catalog description.
- 24. `ML_GLDTLAD`: opens 3, days 1, rows 91. no catalog description.
- 25. `MB_15791SS`: opens 3, days 1, rows 13. AFI 15791 SS Transactions.
- 26. `ML_VENDADS`: opens 3, days 1, rows 0. no catalog description.
- 27. `SR_GLDTLVP`: opens 2, days 2, rows 328. no catalog description.
- 28. `ARINVF1`: opens 2, days 1, rows 636095. no catalog description.
- 29. `EB_GLQUERY`: opens 2, days 1, rows 298912. no catalog description.
- 30. `JB_EMPLOYE`: opens 2, days 1, rows 113226. no catalog description.
- 31. `SR_GLDTLRT`: opens 2, days 1, rows 58826. no catalog description.
- 32. `BP_PRTALEG`: opens 2, days 1, rows 39535. no catalog description.
- 33. `ML_UNINTRV`: opens 2, days 1, rows 34832. no catalog description.
- 34. `ARINVF11`: opens 2, days 1, rows 30710. no catalog description.
- 35. `ML_APCKOUT`: opens 2, days 1, rows 15293. AP Check's Outstanding.
- 36. `TN_GLDTLIV`: opens 2, days 1, rows 11976. no catalog description.
- 37. `NW_CARREXP`: opens 2, days 1, rows 11266. no catalog description.
- 38. `ML_GLQUERY`: opens 2, days 1, rows 7766. no catalog description.
- 39. `AS_ALLDEAD`: opens 2, days 1, rows 6058. no catalog description.
- 40. `RK_CONTMST`: opens 2, days 1, rows 4606. no catalog description.
- 41. `RK_ONHECR`: opens 2, days 1, rows 4263. no catalog description.
- 42. `RK_ONH1`: opens 2, days 1, rows 4212. no catalog description.
- 43. `ARSUMM2F`: opens 2, days 1, rows 4058. no catalog description.
- 44. `ML_VEND`: opens 2, days 1, rows 4056. no catalog description.
- 45. `ARSUMM1F`: opens 2, days 1, rows 4054. no catalog description.
- 46. `TN_GLDTLI2`: opens 2, days 1, rows 3848. no catalog description.
- 47. `ARINVF1D`: opens 2, days 1, rows 3800. no catalog description.
- 48. `ML_GLDTLIT`: opens 2, days 1, rows 2489. no catalog description.
- 49. `KM_VAR2`: opens 2, days 1, rows 1577. no catalog description.
- 50. `RC_GLDTLIV`: opens 2, days 1, rows 1489. no catalog description.

Usage guidance:
- Use cautiously as analyst workfiles; inspect metadata, lineage, and row counts before relying on them.
- First-pass candidates: `BFT@CHRIST`, `TA_SERNO`, `BB_WHSDTL1`, `BB_GLDTL`, `TA_MERTRNS`, `WMV_COLRC1`, `BB_WHSDTL`, `BB_WHSDTL2`, `TA_MERTSTK`, `MK_SUPMAS`, `ML_GLDTL`, `RET_WAGE`.

## Warehouse Operations and WMS

Recently used objects in department: 167.

Most-used reports:

- 01. `DWPENLOCSY`: opens 156, days 2117, rows 28566. DOMESTIC Itms -  Tot By Item Using LOCINV File; signals: item, quantity, location.
- 02. `RK_SCANC1`: opens 55, days 1777, rows 5681. signals: item, quantity.
- 03. `RK_PRIMCOL`: opens 55, days 1777, rows 3947. signals: item, warehouse, quantity, location.
- 04. `RK_SCANR1`: opens 55, days 1777, rows 1790. signals: item, quantity.
- 05. `IG_ITMAST1`: opens 25, days 38, rows 11562. signals: item, quantity, order.
- 06. `IG_ITMASTX`: opens 24, days 37, rows 390. signals: item, quantity, order.
- 07. `TA_MESHSHP`: opens 24, days 1, rows 95. AFI3033 SHORT SHIP; signals: warehouse, ship_invoice, cost_price.
- 08. `ST_ITEMASA`: opens 22, days 3, rows 12292. signals: item, quantity, order.
- 09. `MB_SCANRM5`: opens 11, days 1111, rows 223118454. signals: item, labor_wip.
- 10. `RK_SCPWITH`: opens 10, days 5, rows 12098. signals: item, quantity.
- 11. `MAHOTLIST2`: opens 6, days 1, rows 46977. signals: item, quantity.
- 12. `MAHOTLIST9`: opens 6, days 1, rows 36932. signals: item, quantity.
- 13. `MAHOTLIST3`: opens 6, days 1, rows 4143. signals: item, bom_component.
- 14. `RKHOTLIST4`: opens 6, days 1, rows 528. signals: item, warehouse, quantity, order, bom_component, planning, vendor_customer.
- 15. `KM_RPSHIP`: opens 5, days 3, rows 219427. RP DETAIL BY CUSNO,item, address; signals: item, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 16. `FS_SKIDMV`: opens 3, days 2, rows 7187. signals: item, quantity, order, labor_wip, bom_component.
- 17. `KM_RKD902`: opens 3, days 1, rows 16863. signals: item, warehouse, quantity, location.
- 18. `RK_ONHECR3`: opens 3, days 1, rows 11792. signals: item, warehouse, quantity, order.
- 19. `RK_ONH12`: opens 3, days 1, rows 11657. signals: item, warehouse, quantity, order.
- 20. `RPC_OPEN2`: opens 3, days 1, rows 7641. signals: item, warehouse, quantity, order, ship_invoice, vendor_customer, location.
- 21. `DH_WHSE2`: opens 3, days 1, rows 786. signals: item, warehouse, quantity, vendor_customer, location.
- 22. `MB_SLQNTY`: opens 2, days 1, rows 167492. SAVED LOCATION FILE; signals: item, warehouse, quantity, order, cost_price, location.
- 23. `RK_OMK0000`: opens 2, days 1, rows 72906. signals: item, warehouse, quantity.
- 24. `RK_SLQTA`: opens 2, days 1, rows 70825. signals: item, warehouse, quantity, order, location.
- 25. `KM_RKD901`: opens 2, days 1, rows 39632. NEW LIST FOR B2 B4; signals: location.
- 26. `RK_SCOOPM1`: opens 2, days 1, rows 37530. signals: item, warehouse, quantity.
- 27. `MB_SLQNT12`: opens 2, days 1, rows 26525. summary by whse and item number; signals: item, warehouse, quantity, location.
- 28. `RK_ONHECR1`: opens 2, days 1, rows 11786. signals: item, warehouse, quantity, cost_price.
- 29. `RK_ONH11`: opens 2, days 1, rows 11654. signals: item, warehouse, quantity, cost_price.
- 30. `AAHOTLIST4`: opens 2, days 1, rows 18720. signals: item.
- 31. `PA_CONSOL`: opens 2, days 1, rows 18713. DOMESTIC Itms -  Tot By Item Using LOCINV File; signals: item, warehouse, quantity, location.
- 32. `MB_RAWLOCD`: opens 2, days 1, rows 14095. RAW INVENTORY LOCATIONS; signals: item, warehouse, quantity, trip_transfer, cost_price, labor_wip, location.
- 33. `AAHOTLIST1`: opens 2, days 1, rows 8156. signals: item, quantity, order, trip_transfer, vendor_customer.
- 34. `RK_ITBMAX`: opens 2, days 1, rows 5517. signals: item, quantity.
- 35. `MB_RAWCCAR`: opens 2, days 1, rows 3427. RAW CYCLE COUNT DATA - NEW AUDIT ARCHIVE FILE; signals: item, warehouse, quantity, location.
- 36. `MB_RAWLOCS`: opens 2, days 1, rows 3330. RAW INVENTORY LOCATIONS; signals: warehouse, cost_price, location.
- 37. `AAHOTLIST8`: opens 2, days 1, rows 2725. signals: item, warehouse, quantity, order, bom_component, vendor_customer.
- 38. `RPC_SHIP2`: opens 2, days 1, rows 2443. signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 39. `JM_PEINV2`: opens 2, days 1, rows 1660. signals: item, warehouse, quantity, cost_price, location.
- 40. `MAHOTLIST4`: opens 2, days 1, rows 1271. signals: item.
- 41. `MB_NEGLOC1`: opens 2, days 1, rows 916. NEGATIVE RAW LOCATIONS; signals: item, warehouse, quantity, cost_price, location.
- 42. `AAHOTLIST3`: opens 2, days 1, rows 824. signals: item, quantity, order, trip_transfer.
- 43. `SR_IA`: opens 2, days 1, rows 666. signals: item, warehouse, quantity, order, cost_price, location.
- 44. `AAHOTLIST6`: opens 2, days 1, rows 628. signals: item, quantity.
- 45. `RK_TAGS`: opens 2, days 1, rows 458. signals: item, warehouse, order, vendor_customer, location.
- 46. `SP_ADSYARD`: opens 2, days 1, rows 427. signals: location.
- 47. `SR_IAREPOR`: opens 2, days 1, rows 371. signals: item, warehouse, quantity, order, cost_price, location.
- 48. `JM_ECRINV2`: opens 2, days 1, rows 303. signals: item, warehouse, quantity, cost_price, location.
- 49. `AAHOTLIST2`: opens 2, days 1, rows 134. signals: trip_transfer.
- 50. `JCT_DCSCAN`: opens 2, days 1, rows 97. DATA COLLECTION SCAN HISTORY (PYREXPD); signals: item, quantity, order, labor_wip, bom_component.

Usage guidance:
- Use for location, LOCINV, ASRS/rack, yard/shuttle, hotlist, scan, short-ship, and warehouse execution questions.
- First-pass candidates: `DWPENLOCSY`, `RK_SCANC1`, `RK_PRIMCOL`, `RK_SCANR1`, `IG_ITMAST1`, `IG_ITMASTX`, `TA_MESHSHP`, `ST_ITEMASA`, `MB_SCANRM5`, `RK_SCPWITH`, `MAHOTLIST2`, `MAHOTLIST9`.

## Purchasing Procurement and Vendor

Recently used objects in department: 152.

Most-used reports:

- 01. `VENNAM`: opens 29, days 925, rows 64831. signals: vendor_customer.
- 02. `MK_UUQANOW`: opens 8, days 1, rows 223993. signals: item, quantity, cost_price, vendor_customer.
- 03. `PI_ORDB4`: opens 6, days 1, rows 994978. Comast before; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 04. `MK_UUQA12`: opens 6, days 1, rows 286568. signals: item, quantity, cost_price, vendor_customer.
- 05. `MK_VNDNR`: opens 5, days 2, rows 87038. signals: cost_price, vendor_customer.
- 06. `#WOUSEAGES`: opens 4, days 1023, rows 2768. signals: item, warehouse, quantity, cost_price, vendor_customer.
- 07. `PD_ITEM`: opens 4, days 2, rows 503322. signals: item, cost_price, vendor_customer.
- 08. `MK_COMODTY`: opens 4, days 1, rows 20326. signals: item, vendor_customer.
- 09. `MK_PODB`: opens 3, days 1, rows 761481. signals: item, quantity, order, vendor_customer.
- 10. `LD_NFMOP5`: opens 3, days 1, rows 687143. signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 11. `TW_POITEM`: opens 3, days 1, rows 1282218. signals: item, warehouse, quantity, order, cost_price, vendor_customer.
- 12. `PD_REPLPRT`: opens 3, days 1, rows 163866. signals: item, cost_price, vendor_customer.
- 13. `MK_VENNAM`: opens 3, days 1, rows 87038. signals: vendor_customer.
- 14. `MK_PPV`: opens 3, days 1, rows 11817. PPV SAVE IFM; signals: item, warehouse, quantity, order, ship_invoice, cost_price.
- 15. `SCH_GREEN1`: opens 3, days 1, rows 5. signals: item, order, cost_price, vendor_customer.
- 16. `MB_PPV0520`: opens 2, days 981, rows 63603. PPV SAVE IFM - 2020  MB_PPVMMYY; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 17. `PPVINT0220`: opens 2, days 979, rows 58953. PPV INTERNATIONAL ITEMS FROM ASHLEY SUPPLIER; signals: item, quantity, order, ship_invoice, cost_price, vendor_customer.
- 18. `PD_UUQA12`: opens 2, days 2, rows 286571. signals: item, quantity, cost_price, vendor_customer.
- 19. `PD_COO`: opens 2, days 2, rows 87038. signals: vendor_customer.
- 20. `LD_NFMOP8`: opens 2, days 1, rows 994978. signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 21. `LD_OPENORD`: opens 2, days 1, rows 935245. signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 22. `LD_NFMOP05`: opens 2, days 1, rows 687143. signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 23. `MK_ITMRVA`: opens 2, days 1, rows 609018. signals: item, vendor_customer.
- 24. `MK_ITEM`: opens 2, days 1, rows 503322. signals: item, cost_price, vendor_customer.
- 25. `MK_UUQ12`: opens 2, days 1, rows 232858. signals: item, quantity, cost_price, vendor_customer.
- 26. `PD_UUQ12`: opens 2, days 1, rows 232858. signals: item, quantity, cost_price, vendor_customer.
- 27. `MK_REPLPRT`: opens 2, days 1, rows 163866. signals: item, cost_price, vendor_customer.
- 28. `LD_NFMOP07`: opens 2, days 1, rows 113988. signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 29. `LD_NFMOP7`: opens 2, days 1, rows 113988. signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 30. `MB_PPV0626`: opens 2, days 1, rows 107463. PPV SAVE IFM - 2020  MB_PPVMMYY; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 31. `PPVINT0626`: opens 2, days 1, rows 90922. PPV INTERNATIONAL ITEMS FROM ASHLEY SUPPLIER; signals: item, quantity, order, ship_invoice, cost_price, vendor_customer.
- 32. `MB_PPV0526`: opens 2, days 1, rows 94953. PPV SAVE IFM - 2020  MB_PPVMMYY; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 33. `LD_VNDNR`: opens 2, days 1, rows 87048. signals: cost_price, vendor_customer.
- 34. `DH_VENNAM`: opens 2, days 1, rows 86991. signals: vendor_customer.
- 35. `PD_VNDNR`: opens 2, days 1, rows 86960. signals: cost_price, vendor_customer.
- 36. `MK_COO`: opens 2, days 1, rows 86863. signals: vendor_customer.
- 37. `PPVINT0526`: opens 2, days 1, rows 76216. PPV INTERNATIONAL ITEMS FROM ASHLEY SUPPLIER; signals: item, quantity, order, ship_invoice, cost_price, vendor_customer.
- 38. `BP_VNDXREF`: opens 2, days 1, rows 65471. Vendor Master extended Reference file; signals: vendor_customer.
- 39. `SCH_PPVINT`: opens 2, days 1, rows 49451. signals: item, quantity, order, ship_invoice, cost_price, vendor_customer.
- 40. `MB_INVPUR`: opens 2, days 1, rows 47781. INVENTORY BALANCES - PURCHASED ITEMS; signals: item, quantity.
- 41. `DH_POITEMP`: opens 2, days 1, rows 29736. signals: item, warehouse, quantity, order, cost_price, vendor_customer.
- 42. `TJ_POITEM`: opens 2, days 1, rows 28188. signals: item, warehouse, quantity, order, cost_price, vendor_customer.
- 43. `PPVINT0726`: opens 2, days 1, rows 20595. PPV INTERNATIONAL ITEMS FROM ASHLEY SUPPLIER; signals: item, quantity, order, ship_invoice, cost_price, vendor_customer.
- 44. `MB_PPV0726`: opens 2, days 1, rows 19657. PPV SAVE IFM - 2020  MB_PPVMMYY; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 45. `MK_PPVINT`: opens 2, days 1, rows 19427. signals: item, quantity, order, ship_invoice, cost_price.
- 46. `SCH_PPV`: opens 2, days 1, rows 1227. PPV SAVE IFM; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer.
- 47. `MK_ORSAVE`: opens 2, days 1, rows 1204. Open Receiver File for current month; signals: item, warehouse, quantity, order, cost_price, vendor_customer.
- 48. `JZ_IMMONYR`: opens 2, days 1, rows 1193. signals: item, quantity, cost_price, vendor_customer.
- 49. `DH_LETTERA`: opens 2, days 1, rows 632. signals: item, warehouse, quantity.
- 50. `MK_BUYER`: opens 2, days 1, rows 616. no catalog description.

Usage guidance:
- Use for vendor, supplier, purchase order, receiving, PPV, buyer, and vendor lead-time analysis.
- First-pass candidates: `VENNAM`, `MK_UUQANOW`, `PI_ORDB4`, `MK_UUQA12`, `MK_VNDNR`, `#WOUSEAGES`, `PD_ITEM`, `MK_COMODTY`, `MK_PODB`, `LD_NFMOP5`, `TW_POITEM`, `PD_REPLPRT`.

## Supply Chain Planning and ATP

Recently used objects in department: 110.

Most-used reports:

- 01. `RK_MULCOD5`: opens 496, days 2116, rows 56. signals: item, planning.
- 02. `DWNEEDFILP`: opens 156, days 2117, rows 293. Pennsylvannia - Items On NEEDLIST/FILL Trucks; signals: item, planning.
- 03. `DH_LEADTA`: opens 53, days 33, rows 562065. signals: item, warehouse, quantity, vendor_customer.
- 04. `DPH_BLDATA`: opens 35, days 1310, rows 9067. BACKLOG; signals: item, warehouse, quantity, cost_price, planning.
- 05. `MB_BL0526`: opens 13, days 8, rows 3411535. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 06. `MB_BL0725`: opens 12, days 56, rows 3285970. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 07. `MB_BL0626`: opens 12, days 6, rows 3433758. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 08. `RK_ALLPRNT`: opens 9, days 49, rows 3698. x; signals: item, quantity, order, planning, vendor_customer.
- 09. `MB_BL0421`: opens 8, days 858, rows 2323803. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 10. `MB_BL0326`: opens 5, days 9, rows 3369928. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 11. `MB_BL0426`: opens 5, days 5, rows 3395946. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 12. `RK_2002`: opens 5, days 1, rows 133. signals: item, quantity, order, planning, vendor_customer.
- 13. `RK_NEGATPZ`: opens 4, days 913, rows 1193. signals: item, warehouse, quantity, planning.
- 14. `MB_BL0821`: opens 4, days 742, rows 2446007. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 15. `GLW_ATPZER`: opens 3, days 1021, rows 4041. signals: item, warehouse, quantity, planning.
- 16. `MB_BL0324`: opens 3, days 37, rows 2848019. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 17. `MB_BL0226`: opens 3, days 8, rows 3392030. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 18. `MB_BL0126`: opens 3, days 7, rows 3384454. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 19. `KM_RKD903`: opens 3, days 1, rows 16466. ATPSUM FOR WHSE 1; signals: item, warehouse, planning.
- 20. `RK_RED0001`: opens 3, days 1, rows 12975. signals: item, planning.
- 21. `RK_OMK0002`: opens 3, days 1, rows 12252. signals: item, warehouse, quantity, order, planning.
- 22. `RK_RED0007`: opens 3, days 1, rows 9574. signals: item, quantity, order, planning.
- 23. `RK_MULCOD1`: opens 3, days 1, rows 33. signals: item, quantity, trip_transfer, planning.
- 24. `GLW_ATPOVR`: opens 2, days 1021, rows 6547. signals: item, warehouse, quantity, planning.
- 25. `HS_ATPSUM`: opens 2, days 360, rows 10239. signals: item, planning.
- 26. `MB_BL1222`: opens 2, days 218, rows 2687869. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 27. `YS_OPENORD`: opens 2, days 1, rows 446788. signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 28. `RK_ONHAND`: opens 2, days 1, rows 71571. signals: item, warehouse, quantity, order, planning.
- 29. `RK_SLOTECR`: opens 2, days 1, rows 12284. signals: item, warehouse, quantity, order, planning.
- 30. `RK_SLOTRKD`: opens 2, days 1, rows 12076. signals: item, warehouse, quantity, order, planning.
- 31. `RK_RED0006`: opens 2, days 1, rows 18768. signals: item, quantity, order, planning.
- 32. `RK_RKDFCSD`: opens 2, days 1, rows 17592. signals: item, warehouse, quantity, order, planning, vendor_customer.
- 33. `RK_ECRFCSD`: opens 2, days 1, rows 16724. signals: item, warehouse, quantity, order, planning, vendor_customer.
- 34. `RK_RED0004`: opens 2, days 1, rows 8295. signals: item, quantity, planning.
- 35. `WMV_ATPFI1`: opens 2, days 1, rows 12962. signals: item, quantity, ship_invoice, planning.
- 36. `RK_RED0005`: opens 2, days 1, rows 12700. signals: item, quantity, order, planning.
- 37. `RK_RED0002`: opens 2, days 1, rows 2250. signals: item, quantity, planning.
- 38. `RK_ECRFCST`: opens 2, days 1, rows 4731. no catalog description.
- 39. `RK_RKDFCST`: opens 2, days 1, rows 4715. no catalog description.
- 40. `RK_2006101`: opens 2, days 1, rows 64. signals: item, quantity, order, planning, vendor_customer.
- 41. `RK_200620`: opens 2, days 1, rows 3. signals: item, quantity, order, planning, vendor_customer.
- 42. `AFDLOGFCST`: opens 1, days 1022, rows 12609. signals: item, warehouse.
- 43. `DPH_INVLVL`: opens 1, days 1020, rows 44206. signals: item, warehouse, quantity, planning.
- 44. `GLW_ATPDOS`: opens 1, days 1020, rows 56504. signals: item, warehouse, planning.
- 45. `LD_ATP6WK`: opens 1, days 1015, rows 9103. ATPSUM FOR WHSE 1; signals: item, warehouse, planning.
- 46. `AC_BACKLOG`: opens 1, days 862, rows 7. signals: item, quantity, order, planning, vendor_customer.
- 47. `MB_BL1223`: opens 1, days 13, rows 2798122. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 48. `MB_BL1224`: opens 1, days 8, rows 3102576. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 49. `MB_BL1225`: opens 1, days 5, rows 3371328. TAKES COMPUTER IB SAVE AND SAVE UNDER MONTHLY NAME; signals: item, warehouse, quantity, order, ship_invoice, cost_price, vendor_customer, location.
- 50. `RK_NEGATP`: opens 1, days 2, rows 111. signals: item, warehouse, quantity, order, planning.

Usage guidance:
- Use for ATP, forecast, demand, backlog/backorder, lead-time, needlist/fill-truck, and supply-demand planning questions.
- First-pass candidates: `RK_MULCOD5`, `DWNEEDFILP`, `DH_LEADTA`, `DPH_BLDATA`, `MB_BL0526`, `MB_BL0725`, `MB_BL0626`, `RK_ALLPRNT`, `MB_BL0421`, `MB_BL0326`, `MB_BL0426`, `RK_2002`.

## Sales Customer Service and Orders

Recently used objects in department: 67.

Most-used reports:

- 01. `JJ_FGPRTY1`: opens 78, days 2118, rows 2600911. Finished Goods Morning SnapShot Order Priority; signals: item, warehouse, quantity, order, vendor_customer.
- 02. `DH_TERMS`: opens 20, days 20, rows 79074. signals: cost_price, vendor_customer.
- 03. `ADDRTERMS`: opens 18, days 5, rows 35721. no catalog description.
- 04. `J1_ORDRKD`: opens 3, days 2, rows 1040. signals: item, quantity, order, vendor_customer.
- 05. `RK_MAT0600`: opens 3, days 1, rows 2251. signals: item, warehouse, quantity, order, ship_invoice, vendor_customer.
- 06. `RK_AGRRKD0`: opens 3, days 1, rows 451. signals: item, warehouse, quantity, order, ship_invoice, vendor_customer.
- 07. `RK_MENARD5`: opens 2, days 2, rows 273. signals: item, warehouse.
- 08. `MB_GENDES1`: opens 2, days 1, rows 335517. general description code; signals: item.
- 09. `SR_BUSTYPE`: opens 2, days 1, rows 128121. signals: ship_invoice, vendor_customer.
- 10. `PD_IMPSA`: opens 2, days 1, rows 127608. Sales Volume on items not sourced in USA/CAN; signals: item, warehouse.
- 11. `MK_CUSTMAS`: opens 2, days 1, rows 35710. signals: vendor_customer.
- 12. `LD_DISCODE`: opens 2, days 1, rows 23306. signals: ship_invoice, vendor_customer.
- 13. `CC_OPN_PLY`: opens 2, days 1, rows 22887. Courtney Chunn - open poly orders; signals: item, warehouse, quantity, order, vendor_customer.
- 14. `JM_OPENMO`: opens 2, days 1, rows 8032. signals: item, warehouse, quantity, order, vendor_customer.
- 15. `SR_COMASNA`: opens 2, days 1, rows 5142. signals: vendor_customer.
- 16. `SR_COMASND`: opens 2, days 1, rows 5142. signals: vendor_customer.
- 17. `RK_MAT0104`: opens 2, days 1, rows 4359. signals: item, warehouse, quantity, order, ship_invoice, vendor_customer.
- 18. `ADDRTERMSD`: opens 2, days 1, rows 2087. no catalog description.
- 19. `DH_BRUCE`: opens 2, days 1, rows 1416. signals: item, quantity, order, vendor_customer.
- 20. `BJ_RIP2`: opens 2, days 1, rows 692. signals: item, warehouse, quantity, order, vendor_customer.
- 21. `SB_SCHED2`: opens 2, days 1, rows 412. signals: quantity, order, vendor_customer.
- 22. `SN_SCHED`: opens 2, days 1, rows 346. signals: quantity, order, vendor_customer.
- 23. `DH_CARBCO2`: opens 2, days 1, rows 0. signals: item, quantity, order, vendor_customer.
- 24. `AH_BCKLOG1`: opens 1, days 1021, rows 195. signals: warehouse, quantity, vendor_customer.
- 25. `AH_BCKLOG`: opens 1, days 1021, rows 2. signals: warehouse, quantity, vendor_customer.
- 26. `AB_ASSPRTY`: opens 1, days 1021, rows 2. signals: item, quantity, order, vendor_customer.
- 27. `KT_CUSTSER`: opens 1, days 1014, rows 39. signals: labor_wip.
- 28. `RK_MAT0103`: opens 1, days 1, rows 4359. signals: item, warehouse, quantity, order, ship_invoice, vendor_customer.
- 29. `RK_MAT0102`: opens 1, days 1, rows 4359. signals: item, warehouse, quantity, order, ship_invoice, vendor_customer.
- 30. `RK_CODERRR`: opens 1, days 1, rows 0. signals: item, warehouse, quantity, order, ship_invoice, vendor_customer.
- 31. `RK_MAT0606`: opens 1, days 1, rows 2251. signals: item, warehouse, quantity, order, ship_invoice, vendor_customer.
- 32. `RK_CODATAN`: opens 1, days 1, rows 9243. signals: item, warehouse, quantity, order, ship_invoice, vendor_customer.
- 33. `TD_BUSTYPE`: opens 1, days 1, rows 128001. customer business types by ship to; signals: ship_invoice, vendor_customer.
- 34. `MB_NETSL`: opens 1, days 1, rows 39829. NET SALES; signals: item, warehouse, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 35. `MAE_TEMP`: opens 1, days 1, rows 14. signals: item, quantity, order, vendor_customer.
- 36. `AM_NETSLAS`: opens 0, days 1021, rows 7742. NET SALES - ASHLEY SLEEP; signals: item, warehouse, quantity, trip_transfer, ship_invoice, cost_price.
- 37. `AM_NETSL`: opens 0, days 1021, rows 671. NET SALES; signals: item, quantity, order, trip_transfer, ship_invoice, cost_price, vendor_customer.
- 38. `BP_TERMSF`: opens 0, days 1020, rows 131. signals: quantity, ship_invoice.
- 39. `JB_NETSALE`: opens 0, days 1016, rows 10. NET SALES; signals: item, vendor_customer.
- 40. `MACUSTNAME`: opens 0, days 1015, rows 25924. Customer listing w/number; signals: item, quantity, order, ship_invoice, cost_price, planning, vendor_customer, location.
- 41. `MB_CSMNQTY`: opens 0, days 1005, rows 489497. Net Qty by customer, by item; signals: item, quantity, vendor_customer.
- 42. `MB_CUSMAS`: opens 0, days 1004, rows 29743. signals: vendor_customer.
- 43. `BG_SALES`: opens 0, days 929, rows 3019048. MISC INV ADJS - RIPLEY; signals: item, warehouse, quantity.
- 44. `CS_COMASNA`: opens 0, days 496, rows 6027. signals: vendor_customer.
- 45. `CS_COMASND`: opens 0, days 496, rows 6027. signals: vendor_customer.
- 46. `CSSREPBYWI`: opens 0, days 2, rows 0. DJJ file by customer service and warehouse; signals: warehouse, vendor_customer.
- 47. `KM_CUST`: opens 0, days 2, rows 35497. customer number and name; signals: vendor_customer.
- 48. `RK_RP00051`: opens 0, days 1, rows 629. signals: item, quantity, order, ship_invoice, vendor_customer.
- 49. `VP_SCHED`: opens 0, days 1, rows 357. signals: quantity, order, vendor_customer.
- 50. `MK_ITMEXT`: opens 0, days 1, rows 1430. signals: item.

Usage guidance:
- Use for customer, open-order, sales, promo, terms/dealer, customer-request-date, and order-service questions.
- First-pass candidates: `JJ_FGPRTY1`, `DH_TERMS`, `ADDRTERMS`, `J1_ORDRKD`, `RK_MAT0600`, `RK_AGRRKD0`, `RK_MENARD5`, `MB_GENDES1`, `SR_BUSTYPE`, `PD_IMPSA`, `MK_CUSTMAS`, `LD_DISCODE`.

## Data Reference and Excel Automation

Recently used objects in department: 6.

Most-used reports:

- 01. `QRYPARMS`: opens 110, days 1226, rows 1. Generic Query Paramters file for Excel.
- 02. `WHSMST`: opens 60, days 1318, rows 45. signals: item, warehouse, order, ship_invoice, planning, vendor_customer, location.
- 03. `RK_GENDESC`: opens 18, days 18, rows 234. no catalog description.
- 04. `RK_DATEFIL`: opens 17, days 6, rows 14245. no catalog description.
- 05. `MB_WHSMST`: opens 4, days 3, rows 97. WHSE MASTER/SITE ID; signals: warehouse.
- 06. `RK_WHSMST`: opens 0, days 941, rows 9148. signals: item, warehouse, location.

Usage guidance:
- Use for query parameters, warehouse/vendor dimensions, date helpers, code descriptions, and Excel-driven automation support.
- First-pass candidates: `QRYPARMS`, `WHSMST`, `RK_GENDESC`, `RK_DATEFIL`, `MB_WHSMST`, `RK_WHSMST`.

## Reuse Pattern

1. Identify the business department or action owner from the user request.
2. Read that department section and start from its highest-frequency reports.
3. Confirm columns from live `QSYS2.SYSCOLUMNS` before writing production SQL.
4. Prefer analyst-ready AQUERY objects for established reporting logic; prefer base MAPICS tables for source-of-record extraction.
5. Treat mixed reports by their action owner: for example, a shipped-history file with customer fields routes to Distribution/Shipping unless the task is explicitly sales analysis.