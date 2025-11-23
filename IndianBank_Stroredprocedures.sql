use IBANK
go

/***************************************************************************************
SP Name: PreviousMonthBankStatement
Author: Prem Kommu
Date of creation: 21st Oct 2022
DB Name: Ibank

Purpose: This procedure will get the previous month transactions done by customer

History:
--------------------------------------------------------------------------------------
Sno        Done By             Date of change                Remarks
1.         Prem Kommu          21st oct-2022                New SP
2.         Yashwanth           27th Dec-2022                Modified and added tax calculation
3.         Sada                20th Feb-2023                Modified tax calculation
****************************************************************************************/

Alter procedure usp_PreviousMonthBankStatement
(
@acid int
)
as
begin
declare @pid char(2)
declare @custName varchar(100)
declare @brid char(3)
declare @cbal money

declare @lastmonth varchar(40)
declare @todaydate datetime
set @todaydate=getdate()

-- Automation of time period in the header
select @lastmonth = substring(datename(mm,dateadd(MM,-1,@todaydate)),1,3)

declare @lastmonthenddate datetime
select @lastmonthenddate=EOMONTH(dateadd(MM,-1,@todaydate))

Print '-------------------------------------------------------------------------------------------'
Print '                               INDIAN BANK                                                 '
Print '         	List of Transactions from '+@lastmonth+' 1st to '+ convert(varchar,@lastmonthenddate,107)+' Report'
Print '-------------------------------------------------------------------------------------------'

--1 Customer info 
select @custName = NAME,
		@pid = PID,
		@brid = BRID,
		@cbal = CBAL
from AMASTER
where ACID = @acid

Print 'Product Name : '+@pid
Print 'Account No : '+cast(@acid as varchar)+ space(33)+'Branch: '+@brid
Print 'Customer Name: '+@custName+ space(21)+'Cleared Balance : '+cast(@cbal as varchar)

Print '-------------------------------------------------------------------------------------------'
print 'SL.NO    DATE            TXN TYPE      CHEQUE NO         AMOUNT        RUNNINGBALANCE         '
Print '-------------------------------------------------------------------------------------------'

select ROW_NUMBER() over (order by dot asc) as RNO,
		ACID,
		DOT,
		TXN_TYPE,
		CHQNO,
		TXN_AMOUNT
into  #temp from TMASTER
where ACID = @acid and datediff(yy,dot,getdate()) in (0,1,2)

-- select * from #temp

--1 Transaction info 
declare @rno int
declare @dot datetime
declare @txn_type char(3)
declare @chqno int
declare @txn_amount money

declare @cnt int
select @cnt = count(*) from #temp

declare @x int
set @x=1

while (@x <= @cnt)
begin
	select 
		@rno = RNO,
		@dot = DOT,
		@txn_type = txn_type,
		@chqno = CHQNO,
		@txn_amount = txn_amount
	from #temp
		where RNO=@x

	print cast(@rno as varchar)+space(7)+
		convert(varchar,@dot,107)+space(5)+
		@txn_type+space(12)+cast(isnull(@chqno,0) as varchar)+
		space(10)+cast(@txn_amount as varchar)
set @x=@x+1
end
Print '-------------------------------------------------------------------------------------------'

declare @notxns int
select @notxns = count(*) from #temp
print 'Total Number of Transactions    : ' + cast(@notxns as varchar)

declare @cds int
select @cds = count(*) from #temp where TXN_TYPE = 'CD'
print 'Total Number of Cash Deposits   : '+ cast(@cds as varchar)

declare @cws int
select @cws = count(*) from #temp where TXN_TYPE = 'CW'
print 'Total Number of Cash Withdrawals: '+ cast(@cws as varchar)

declare @cqds int
select @cqds = count(*) from #temp where TXN_TYPE = 'CQD'
print 'Total Number of Cheque Deposits : '+ cast(@cqds as varchar)

----------------------------------------------------------------------------------
print 'Dates when the Balance dropped below the Minimum Balance for the Product:'

declare @dateslessthancbal as datetime

select ROW_NUMBER() over (order by dot asc) as RNO2, convert(varchar,DOT,107) as dateslessthancbal
into #temp2 
from #temp t1 
join 
AMASTER a1
on t1.acid = a1.ACID
where (a1.cbal-TXN_AMOUNT) < 300000

declare @cnt2 tinyint
select @cnt2=count(*) from #temp2

declare @y int
set @y = 1

while (@y <= @cnt2)
begin
	select 
		@dateslessthancbal=dateslessthancbal
	from #temp2
		where RNO2=@y
	print @dateslessthancbal
	set @y=@y+1
end

Print '-------------------------------------------------------------------------------------------'
Print 'Thank you for banking with us. For more help, please call our customer care 1800 000 000'
Print '-------------------------------------------------------------------------------------------'

end
go


exec usp_PreviousMonthBankStatement 131
