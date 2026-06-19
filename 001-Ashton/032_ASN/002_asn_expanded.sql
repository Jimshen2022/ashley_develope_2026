SELECT * FROM t_asn WITH (NOLOCK)
    --WHERE
        -- expected_arrival >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
      -- status IN ('NEW', 'CHECKED IN', 'CLOSED')