use IBANK
go

select * into HMASTER from TMASTER where 1=0
GO

Alter trigger tr_hightm
on TMaster
instead of insert,update,delete
as
begin

declare @TNO INTEGER
declare @DOT DATETIME
declare @ACID INTEGER
declare @BRID CHAR(3)
declare @TXN_TYPE CHAR(3)
declare @CHQNO INTEGER
declare @CHQDATE DATETIME
declare @TXN_AMOUNT MONEY
declare @USERID INTEGER
declare @CBAL Money

select
	@TNO = TNO,
	@DOT = DOT,
	@ACID = ACID,
	@BRID = BRID,
	@TXN_TYPE = TXN_TYPE,
	@CHQNO = CHQNO,
	@CHQDATE = CHQDATE,
	@TXN_AMOUNT = TXN_AMOUNT,
	@USERID = USERID
from inserted

if (@TXN_AMOUNT > 50000)
	Insert into HTMASTER values(@TNO,@DOT,@ACID,@BRID,@TXN_TYPE,@CHQNO,@CHQDATE,@TXN_AMOUNT,@USERID)
else
	Insert into TMASTER values(@TNO,@DOT,@ACID,@BRID,@TXN_TYPE,@CHQNO,@CHQDATE,@TXN_AMOUNT,@USERID)

declare @status char(3)
select @status = status from AMASTER where acid=@ACID

if (@status = 'O')
	begin
		if (@txn_type = 'CD')
			begin
			update AMASTER set cbal = cbal + @txn_amount where acid=@acid
			end
		else
			begin
			select @cbal = cbal from AMASTER where acid=@acid
			if (@txn_amount <= @cbal)
				begin
					update AMASTER set cbal = cbal - @txn_amount where acid=@acid
				end
			else
				begin
				print 'Insufficient funds'
				end
			end
	end
	else
		begin
		print 'Your account is closed, please contact customercare for more details'
		rollback
		end
end

go

select * from TMASTER where tno > 1000
select * from HTMASTER
select * from AMASTER where acid=600

insert into TMASTER values(1006,GETDATE(),600,'BR9','CD',NULL,NULL,65000,9)

insert into TMASTER values(1007,GETDATE(),600,'BR9','CD',NULL,NULL,55000,9)
