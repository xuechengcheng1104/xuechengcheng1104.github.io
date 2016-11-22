
--#-------------------------------------------------
--#    Recurse query the info in different levels
--#-------------------------------------------------
;WITH CTE01 AS
(
	SELECT VGUID,
		OGUID AS [PGUID],
		PDESCCHS AS [ODESCCHS]
	FROM CSPOSI_1
	WHERE VGUID='403DC96F-DB21-44D7-8300-00F3E30AC9CA'
	UNION ALL
	SELECT A.VGUID,
		A.PGUID,
		A.ODESCCHS
	FROM CSORGA_1 AS A
	INNER JOIN CTE01 AS B
		ON A.VGUID=B.PGUID
)
SELECT * FROM CTE01
--#-------------------------------------------------
--#    check database process
--#-------------------------------------------------
SELECT *
FROM SYS.SYSPROCESSES
WHERE DBID=DB_ID('LandaV9')
DBCC INPUTBUFFER(51)
--#-------------------------------------------------
--#    landa报表打开字段乱序问题
--#-------------------------------------------------
delete from csreportfield where RPTid in (select rptid from csrpt_1 where rptdatasource='USP_Emplyee_Class')
delete  from csreportsetup where reportid in (select rptid from csrpt_1 where rptdatasource='USP_Emplyee_Class')

--#-------------------------------------------------
--#    Change the status of a database
--#-------------------------------------------------
ALTER DATABASE DB20160312 SET READ_WRITE
RESTORE DATABASE DB20160312 WITH RECOVERY

--#-------------------------------------------------
--#    添加本地计算机用户为数据库管理员
--#-------------------------------------------------
sp_addsrvrolemember 'LANDASOFT-AP\Tiny.Cui', 'sysadmin'
SELECT *
FROM SYS.SERVER_PRINCIPALS
--#-------------------------------------------------
--#    CREATE FUNCTION
--#-------------------------------------------------
IF OBJECT_ID('getonlydate', 'FN') IS NOT NULL DROP FUNCTION getonlydate
GO
CREATE FUNCTION getonlydate ()
RETURNS datetime
AS
BEGIN
	RETURN (select convert(datetime, convert(date, getdate())))
END
GO
--#-------------------------------------------------
--#    UNPIVOT
--#-------------------------------------------------
SELECT * FROM CSEMPL_12
SELECT DAYNUM,
	DAYVALUE
FROM CSEMPL_12
UNPIVOT
(
	DAYVALUE FOR DAYNUM IN
	(
		D1,
		D2,
		D3,
		D4,
		D5,
		D6,
		D7,
		D8,
		D9,
		D10,
		D11,
		D12,
		D13,
		D14,
		D15,
		D16,
		D17,
		D18,
		D19,
		D20,
		D21,
		D22,
		D23,
		D24,
		D25,
		D26,
		D27,
		D28,
		D29,
		D30,
		D31
	)
)T
WHERE YEARMONTH='1605'

