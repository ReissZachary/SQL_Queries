--PART 1--
--SQL CODE--
CREATE SEQUENCE seqCounter
START WITH 1
INCREMENT BY 1

declare @flag int
set @flag = 0

while (@flag < 10)
	BEGIN
		set @flag = @flag + 1
		SELECT NEXT VALUE for seqCounter as Number
	END

drop SEQUENCE seqCounter

--Part 2--
 CREATE SEQUENCE seqGap
 START WITH 0
 INCREMENT BY 5

 declare @seqGapFlag int
set @seqGapFlag = 0

while (@seqGapFlag <= 10)
	BEGIN
		set @seqGapFlag = @seqGapFlag + 1
		SELECT NEXT VALUE for seqGap as Number
	END

DROP SEQUENCE seqGap

--Part 3--
SELECT	lowAmt,
		highAmt,
		increment,
		CASE
			WHEN increment < 1.01 THEN 'LITTLE INCREMENT'
			WHEN increment >= 1.01 THEN 'BIG INCREMENT'
			END 
		AS Answer
FROM zBidIncrement
