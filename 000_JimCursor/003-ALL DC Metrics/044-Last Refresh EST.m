let
    UTC_DateTimeZone = DateTimeZone.UtcNow(),
    UTC_DATE = Date.From( UTC_DateTimeZone),
    StartofSummertime = Date.StartOfWeek(#date(Date.Year( UTC_DATE),3,31), Day.Sunday),
    StartofWintertime = Date.StartOfWeek(#date(Date.Year( UTC_DATE),10,31), Day.Sunday),
    Offset = if UTC_DATE >= StartofSummertime and UTC_DATE<= StartofWintertime then -4 else -5,
    Custom1 = DateTimeZone.SwitchZone(UTC_DateTimeZone, Offset)
in
    Custom1