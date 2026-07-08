SELECT *
FROM t_load_master
WHERE TRY_CONVERT(
          INT,
          LEFT(load_id, CHARINDEX('-', load_id + '-') - 1)
      ) IN (
          65331,
          65805,
          66399,
          67262,
          64748,
          64475,
          68294,
          65444,
          69570,
          69489,
          66540,
          65367,
          67863,
          66628,
          62918,
          62919,
          65469
      );