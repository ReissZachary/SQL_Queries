
---------------------TABLE CREATION---------------------------------------------------------------------------------------------------------
CREATE TABLE [dbo].[zBidIncrement](
	[lowAmt] [money] NOT NULL,
	[highAmt] [money] NOT NULL,
	[increment] [money] NOT NULL
) ON [PRIMARY]
GO

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
GO

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
GO

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
GO

ALTER TABLE [dbo].[zBidLimits]  WITH CHECK ADD  CONSTRAINT [FK_zBidLimits_zAuction] FOREIGN KEY([Auction_ID])
REFERENCES [dbo].[zAuction] ([ID])
GO

ALTER TABLE [dbo].[zBidLimits] CHECK CONSTRAINT [FK_zBidLimits_zAuction]
GO

ALTER TABLE [dbo].[zBidLimits]  WITH CHECK ADD  CONSTRAINT [FK_zBidLimits_zUser] FOREIGN KEY([User_ID])
REFERENCES [dbo].[zUser] ([ID])
GO

ALTER TABLE [dbo].[zBidLimits] CHECK CONSTRAINT [FK_zBidLimits_zUser]
GO

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
GO

ALTER TABLE [dbo].[zEffectiveBidHistory]  WITH CHECK ADD  CONSTRAINT [FK_zEffectiveBidHistory_zAuction] FOREIGN KEY([Auction_ID])
REFERENCES [dbo].[zAuction] ([ID])
GO

ALTER TABLE [dbo].[zEffectiveBidHistory] CHECK CONSTRAINT [FK_zEffectiveBidHistory_zAuction]
GO

ALTER TABLE [dbo].[zEffectiveBidHistory]  WITH CHECK ADD  CONSTRAINT [FK_zEffectiveBidHistory_zUser] FOREIGN KEY([prevBidderID])
REFERENCES [dbo].[zUser] ([ID])
GO

ALTER TABLE [dbo].[zEffectiveBidHistory] CHECK CONSTRAINT [FK_zEffectiveBidHistory_zUser]
GO
------------------------------------------------END TABLE CREATION----------------------------------------------------------------------------

------------------------------------------------POPULATE TABLES-------------------------------------------------------------------------------
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
,(5000,999999999999.99,100)

insert into zAuction (id,description,title,startingBidAmt,effectiveBidAmt,effectiveBidderID) values
(1,'Antique oak sitting chair.  Dual rockers.  Excellent wear and comfort.','Wooden Chair',0.01,null,null),
(2,'Unwrapped.  Still new!  Blue color, original Tootsie roll pop.','Tootsie Roll Lollipop',0.25,null,null)

insert into zUser (id,name,phone,rating) values
(70,'Heber Allen','435-283-7532','A'),
(71,'Bob Alexander','435-435-4355','B'),
(72,'Sally Salamander','801-801-8011','A'),
(73,'Robert Romeo','408-408-4088','A')
----------------------------------------------END POPULATE TABLES---------------------------------------------------------------------------

select * from zUser
select * from zBidIncrement
go

CREATE TRIGGER zBidTrigger
ON zBidLimits
FOR INSERT
AS 
BEGIN
    --Need to add functionality to be able to bid for a different item. ID should be Auction_ID
    --Check if bid is the first one and if the bid is invalid
    declare @iid int, @iAuction int, @iUser int, @iTime datetime, @iBidLimit money, @startingAmt money, @effecBid money,@maxID int,  @maxLimit money, @incAmt money
    set @iid = (select [ID] from inserted)
    set @iAuction = (select [Auction_ID] from inserted)
    set @iUser = (select [User_ID] from inserted)
    set @iTime = (select [bidTime] from inserted)
    set @iBidLimit = (select [bidLimit] from inserted)
    set @startingAmt = (select [startingBidAmt] from zAuction where ID = @iAuction)
    set @effecBid = (select [effectiveBidAmt] from zAuction WHERE ID = @iAuction)
    set @maxLimit = (select max(newBidderLimit) from zEffectiveBidHistory where Auction_ID = @iAuction)
    set @incAmt = (select dbo.fBidIncrement(@maxLimit)) --this should be from effective bid, not the max limit
    set @maxID = (select newBidderID from zEffectiveBidHistory where newBidderLimit = (select max(newBidderLimit) from zEffectiveBidHistory where Auction_ID = @iAuction)) 
    
    --If effective bid is null (first one) and bidLimit is less than starting amount (invalid)
    --  delete from zbidLimit
    --  insert into zeffectiveBidHistory
    IF ((@effecBid is null) AND (@iBidLimit < @startingAmt))
        BEGIN
            --Inserting into bid history
            exec dbo.insertEffectiveBidHistory
            @aucID = @iAuction, @bidTime = @iTime,  @prevID = @iUser, @prevLimit=@iBidLimit, @newID = @iUser, @newLimit = @iBidLimit, @effBid = @iUser, @effBidAmt = @startingAmt
            
            --Deleting from zBidLimits
            delete from zBidLimits
            where zBidLimits.ID = (select [ID] from inserted)   
        END
    ----Checks if bid is first and is valid
    --  Insert into zBidHistory
    --  Update Auction
    ELSE IF ((@effecBid is null) AND (@iBidLimit >= @startingAmt))
    
        BEGIN
            --Inserting into bid history
            exec dbo.insertEffectiveBidHistory
            @aucID = @iAuction, @bidTime = @iTime,  @prevID = @iUser, @prevLimit=@iBidLimit, @newID = @iUser, @newLimit = @iBidLimit, @effBid = @iUser, @effBidAmt = @startingAmt
            
            --Updating zAuction
            exec dbo.UpdateAuctionDetails
            @bid = @startingAmt, @bidderID = @iUser, @aucID = @iAuction
        END
    --Check if the bid is > than BidLimit
    --  Insert into zBidHistory
    --  Update Auction
    /**********HEBER**********/
    ElSE IF (@iBidLimit > (select max(newBidderLimit) from zEffectiveBidHistory WHERE Auction_ID = @iAuction))
        BEGIN
            DECLARE @newEffBidAmt money, @theRealDeal money
            --debug line
            --   insert into debugTable values ('maxID='+convert(varchar(5),@maxID);  
            set @newEffBidAmt = @maxLimit + @incAmt --it should be with effective amt or ibidlimit, not max limit
            set @theRealDeal = iif(@newEffBidAmt < @iBidLimit, @newEffBidAmt, @iBidLimit)
            
            --Inserting into bid history
            exec dbo.insertEffectiveBidHistory
            @aucID = @iAuction, @bidTime = @iTime,  
            @prevID = @maxID, 
            @prevLimit=@maxLimit, @newID = @iUser, @newLimit = @iBidLimit, @effBid = @iUser, @effBidAmt = @theRealDeal
            IF (@iBidLimit <= @effecBid)
                BEGIN
                    --Deleting from zBidLimits
                    delete from zBidLimits
                    where zBidLimits.ID = (select [ID] from inserted)
                END
            ELSE
                BEGIN       
                    --Updating zAuction
                    exec dbo.UpdateAuctionDetails
                    @bid = @theRealDeal, @bidderID = @iUser, @aucID = @iAuction
                END              
        END
        --Check if bid is > effectiveBidAmt but < limit
        --insert into zEffectiveBidHistory
        --updating zAuction
    ElSE IF (@iBidLimit > @effecBid AND @iBidLimit <  (select max(newBidderLimit) from zEffectiveBidHistory WHERE Auction_ID = @iAuction))
        BEGIN
            declare @betweenfoo money
            --the incamt should be from effective bid.
            set @betweenfoo = (@iBidLimit + @incAmt);
            exec dbo.insertEffectiveBidHistory
            @aucID = @iAuction, @bidTime = @iTime,  
            @prevID = @maxID, 
            @prevLimit=@maxLimit, @newID = @iUser, @newLimit = @iBidLimit, @effBid = @maxID, @effBidAmt =@betweenfoo
           
            IF (@iBidLimit <= @effecBid)
                BEGIN
                    --Deleting from zBidLimits
                    delete from zBidLimits
                    where zBidLimits.ID = (select [ID] from inserted)
                END
            ELSE
                BEGIN
                    --Updating zAuction
                    exec dbo.UpdateAuctionDetails
                    @bid = @betweenfoo, @bidderID = @maxID, @aucID = @iAuction          
                END         
        END
    ELSE IF (@iBidLimit < @effecBid)
        BEGIN
            --Inserting into bid history
            exec dbo.insertEffectiveBidHistory
            @aucID = @iAuction, @bidTime = @iTime,  @prevID = @maxID, @prevLimit=@maxLimit, @newID = @iUser, @newLimit = @iBidLimit, @effBid = @maxID, @effBidAmt = @effecBid
            
            --Deleting from zBidLimits
            delete from zBidLimits
            where zBidLimits.ID = @iid  
        END
END

drop trigger zBidTrigger
drop table zEffectiveBidHistory
drop table zBidLimits
drop table zAuction
drop table zBidIncrement
drop table zUser

EXEC dbo.NoMoreScrolling

go

insert into zBidLimits (id,Auction_ID,User_ID,bidTime,bidLimit) values
(2,2,72,SYSDATETIME(),9.00);
select * from zAuction
select * from zEffectiveBidHistory
select * from zBidLimits
go
insert into zBidLimits (id,Auction_ID,User_ID,bidTime,bidLimit) values
(3,2,73,SYSDATETIME(),15.00);
select * from zAuction
select * from zEffectiveBidHistory
select * from zBidLimits
go
insert into zBidLimits (id,Auction_ID,User_ID,bidTime,bidLimit) values
(4,2,70,SYSDATETIME(),12.00);
select * from zAuction
select * from zEffectiveBidHistory
select * from zBidLimits
go
insert into zBidLimits (id,Auction_ID,User_ID,bidTime,bidLimit) values
(1,2,70,SYSDATETIME(),0.10);
select * from zAuction
select * from zEffectiveBidHistory
select * from zBidLimits
go


select * from zAuction
select * from zEffectiveBidHistory
select * from zBidLimits
select * from zUser