use IBANK
go

create view Account_details
as 
select ACID, NAME, Address from AMASTER
go

select * from Account_details
go

create view Account_Txns
as
Select a.ACID, a.NAME, max(DOT) as Dateoflasttxn, count(*) as TotalNumTxns
from AMASTER a
join TMASTER t
on (a.ACID=t.ACID)
group by a.ACID, NAME
--order by a.ACID asc
go

select * from Account_Txns
go

create view Branchprodsumubal
as
select brid, pid, sum(ubal) as sumofubal
from AMASTER
group by brid, PID
go

select * from Branchprodsumubal
go

create view custaccountsheld
as
select Name, count(*) as noofaccheld
from AMASTER
where status in ('i','c')
group by NAME
go

select * from custaccountsheld
go

create view txndetails
as
select txn_type, acid, sum(txn_amount) as sumoftxnamount
from TMASTER
group by txn_type, acid
go

select * from txndetails
go


