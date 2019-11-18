--Find bid Increment--
CREATE FUNCTION fBidIncrement (@bid money)
returns money as
begin
	declare @myAnswer money
	select @myAnswer =  increment
	from zBidIncrement 
	where @bid >= lowAmt and @bid <= highAmt;
	return @myAnswer;
end

declare @value money
set @value = 5

select dbo.fBidIncrement(5.00) Increment
select dbo.fBidIncrement(10.00) Increment
select dbo.fBidIncrement(25.00) Increment

--Who is winning bidder
--Given: bidA, bidB (money)
--Use bid Increment, dont go over bidA or BidB limit

create function fCompareBid (@bidA money, @bidB money)
returns money as
begin
	declare @bid money, @inc money, @myAns money;
	set @bid = iif(@bidA > @bidB, @bidB, @bidA)
	set @inc =dbo.fCalcBidIncrement(@bid);

	--Keep increment from going beyond max bid
	declare @maxBid money, @pos money
	set @maxBid = iif(@bidA >= @bidB, @bidA, @bidB)
	set @pos = @bid + @inc

	set @myAns = iif(@maxBid > @pos, @pos, @maxBid);
	return @myAns	
end

select dbo.fCompareBid(5.00,5.30) WinningBid
select dbo.fCompareBid(5.00,5.05) WinningBid
select dbo.fCompareBid(5.00,6.00) WinningBid

create procedure dbo.insertEffectiveBidHistory
@auction int, @prevID int, @prevBid money, @newID int, @newBid money, @effID int, @effectiveBid money
as
begin
	declare @comment varchar(10)
	declare @increment money
	declare @someID int
	declare @result money
	set @increment = dbo.fBidIncrement(@effectiveBid)
	set @result = dbo.fCompareBid(@effectiveBid, @newBid)
	if @result > @effectiveBid
	begin
		set @comment = 'VALID'
		set @effectiveBid = @newBid + @increment
	end
else
	begin
		set @comment = 'INVALID'
	end
insert into zEffectiveBidHistory (ID,Auction_ID,bidTime,prevBidderID,prevBidderLimit,newBidderID,newBidderLimit,Increment,newEffectiveBidderID,newEffectiveBidAmt, comment)
			select @someID, @auction, SYSDATETIME(),@prevID, @prevBid, @newID, @newBid, @increment, @effID, @effectiveBid, @comment
end

exec dbo.insertEffectiveBidHistory

--------------------------------------------MARCELO CODE--------------------------------------------------------------------

CREATE SEQUENCE newID
    START WITH 1
    INCREMENT BY 1;
GO

CREATE PROC insertEffectiveBidHistory
@aucID int, @bidTime datetime, @prevID int, @prevLimit money, @newID int, @newLimit money, @effBid int, @effBidAmt money
AS
    BEGIN
    declare @zAucEffAmt money
    set @zAucEffAmt = (select [effectiveBidAmt] from zAuction where ID = @aucID)
        IF(@newLimit < @zAucEffAmt)
            BEGIN
                INSERT INTO zEffectiveBidHistory VALUES (
                    NEXT VALUE FOR newID,
                    @aucID,
                    GETDATE(),
                    @prevID,
                    @prevLimit,
                    @newID,
                    @newLimit,
                    dbo.fBidIncrement(@effBidAmt),
                    @effBid,
                    @effBidAmt,
                    'Invalid'
                );
            END
        ELSE
            BEGIN
                INSERT INTO zEffectiveBidHistory VALUES (
                NEXT VALUE FOR newID,
                @aucID,
                GETDATE(),
                @prevID,
                @prevLimit,
                @newID,
                @newLimit,
                dbo.fBidIncrement(@effBidAmt),
                IIF(@newLimit > @prevLimit, @newID, @prevID),    
                @effBidAmt,
                'Valid'
            );
            END            
    END



drop procedure dbo.insertEffectiveBidHistory

CREATE PROC UpdateAuctionDetails
@bid money, @bidderID int, @aucID int
AS
    BEGIN
        UPDATE zAuction
        SET effectiveBidAmt = @bid, effectiveBidderID = @bidderID
        WHERE ID = @aucID;
    END
go

CREATE PROCEDURE NoMoreScrolling
AS
    BEGIN
        
        DROP TABLE zBidIncrement;
        DROP TABLE zBidLimits;
        DROP TABLE zEffectiveBidHistory;
        DROP TABLE zUser;
        DROP TABLE zAuction;
        CREATE TABLE [dbo].[zBidIncrement](
            [lowAmt] [money] NOT NULL,
            [highAmt] [money] NOT NULL,
            [increment] [money] NOT NULL
        ) ON [PRIMARY]
        
        CREATE TABLE [dbo].[zAuction](
            [ID] [int] NOT NULL,
            [description] [varchar](8000) NULL,
            [title] [varchar](200) NOT NULL,
            [startingBidAmt] [money] NOT NULL,
            [effectiveBidAmt] [money] NULL,
            [effectiveBidderID] [int] NULL,
            CONSTRAINT [PK_zAuction] PRIMARY KEY CLUSTERED 
        (
            [ID] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
        ) ON [PRIMARY]
        
        CREATE TABLE [dbo].[zUser](
            [ID] [int] NOT NULL,
            [name] [varchar](80) NULL,
            [phone] [varchar](15) NULL,
            [rating] [char](1) NULL,
            CONSTRAINT [PK_zUser] PRIMARY KEY CLUSTERED 
        (
            [ID] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
        ) ON [PRIMARY]
        
        CREATE TABLE [dbo].[zBidLimits](
            [ID] [int] NOT NULL,
            [Auction_ID] [int] NOT NULL,
            [User_ID] [int] NOT NULL,
            [bidTime] [datetime] NOT NULL,
            [bidLimit] [money] NOT NULL,
            CONSTRAINT [PK_zBidLimits] PRIMARY KEY CLUSTERED 
        (
            [ID] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
        ) ON [PRIMARY]
        
        ALTER TABLE [dbo].[zBidLimits]  WITH CHECK ADD  CONSTRAINT [FK_zBidLimits_zAuction] FOREIGN KEY([Auction_ID])
        REFERENCES [dbo].[zAuction] ([ID])
        
        ALTER TABLE [dbo].[zBidLimits] CHECK CONSTRAINT [FK_zBidLimits_zAuction]
        
        ALTER TABLE [dbo].[zBidLimits]  WITH CHECK ADD  CONSTRAINT [FK_zBidLimits_zUser] FOREIGN KEY([User_ID])
        REFERENCES [dbo].[zUser] ([ID])
        
        ALTER TABLE [dbo].[zBidLimits] CHECK CONSTRAINT [FK_zBidLimits_zUser]
        
        CREATE TABLE [dbo].[zEffectiveBidHistory](
            [ID] [int] NOT NULL,
            [Auction_ID] [int] NOT NULL,
            [bidTime] [datetime] NOT NULL,
            [prevBidderID] [int] NULL,
            [prevBidderLimit] [money] NULL,
            [newBidderID] [int] NOT NULL,
            [newBidderLimit] [money] NOT NULL,
            [Increment] [money] NULL,
            [newEffectiveBidderID] [int] NOT NULL,
            [newEffectiveBidAmt] [money] NOT NULL,
            [comment] [varchar](100) NULL,
            CONSTRAINT [PK_zEffectiveBidHistory] PRIMARY KEY CLUSTERED 
        (
            [ID] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
        ) ON [PRIMARY]
        
        ALTER TABLE [dbo].[zEffectiveBidHistory]  WITH CHECK ADD  CONSTRAINT [FK_zEffectiveBidHistory_zAuction] FOREIGN KEY([Auction_ID])
        REFERENCES [dbo].[zAuction] ([ID])
        
        ALTER TABLE [dbo].[zEffectiveBidHistory] CHECK CONSTRAINT [FK_zEffectiveBidHistory_zAuction]
        
        ALTER TABLE [dbo].[zEffectiveBidHistory]  WITH CHECK ADD  CONSTRAINT [FK_zEffectiveBidHistory_zUser] FOREIGN KEY([prevBidderID])
        REFERENCES [dbo].[zUser] ([ID])
        
        ALTER TABLE [dbo].[zEffectiveBidHistory] CHECK CONSTRAINT [FK_zEffectiveBidHistory_zUser]
        
        insert into zBidIncrement (
        lowAmt,highAmt,increment )
        values 
        (0.01,0.99,0.05)
        ,(1,4.99,0.25)
        ,(5,24.99,0.5)
        ,(25,99.99,1)
        ,(100,249.99,2.5)
        ,(250,499.99,5)
        ,(500,999.99,10)
        ,(1000,2499.99,25)
        ,(2500,4999.99,50)
        ,(5000,999999999999.99,100);
        insert into zAuction (id,description,title,startingBidAmt,effectiveBidAmt,effectiveBidderID) values
        (1,'Antique oak sitting chair.  Dual rockers.  Excellent wear and comfort.','Wooden Chair',0.01,null,null),
        (2,'Unwrapped.  Still new!  Blue color, original Tootsie roll pop.','Tootsie Roll Lollipop',0.25,null,null);
        insert into zUser (id,name,phone,rating) values
        (70,'Heber Allen','435-283-7532','A'),
        (71,'Bob Alexander','435-435-4355','B'),
        (72,'Sally Salamander','801-801-8011','A'),
        (73,'Robert Romeo','408-408-4088','A');
    END