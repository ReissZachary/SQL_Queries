create table Auciton(
	id int,
	effectiveBid money,
	effectiveBuyer int
)

insert into Auciton values (1,9,.00,111)

select
increment
from 
bidIncrementk 
where effectiveBid >= lowAmt and effectiveBid <= highAmt

select effectiveBid from Auciton where id = 1;

-------------------LOGIC----------------------
--if bid < startingBid || bid <= effectiveBid{
--	reject bid
--if only 1 bid{
--	effectiveBid = startingBid
--}
--else if{
--	newBid < oldBid

