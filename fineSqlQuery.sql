declare @pending as int
declare @new  as int
declare @success  as int
declare @error as int
declare @delete as int
declare @frozen as int

declare @tempUserEmailTable table (emailTempCol nvarchar(max), arrayIndex int identity(1, 1))
declare @tempStatusTicketTable table (statusTempCol nvarchar(100), arrayIndex int identity(1, 1))

declare @indexval as int
declare @totalcount as int
declare @currentIndexEmail as nvarchar(max)

insert into @tempUserEmailTable(emailTempCol) select [Email] from Users

set @indexval = 0
set @totalcount = (select count(*) from @tempUserEmailTable)

while @indexval < @totalcount
begin
	select @indexval = @indexval + 1
	delete from @tempStatusTicketTable
	select @currentIndexEmail = emailTempCol from @tempUserEmailTable where arrayIndex = @indexval

	begin
		insert into @tempStatusTicketTable(statusTempCol) select [Status] from Tickets where [UserEmail] = @currentIndexEmail

		set @pending = (select count (*) from @tempStatusTicketTable where statusTempCol = 'pending')
		set @new = (select count (*) from @tempStatusTicketTable where statusTempCol = 'new')
		set @success = (select count (*) from @tempStatusTicketTable where statusTempCol = 'success')
		set @error = (select count (*) from @tempStatusTicketTable where statusTempCol = 'error')
		set @delete = (select count (*) from @tempStatusTicketTable where statusTempCol = 'delete')
		set @frozen = (select count (*) from @tempStatusTicketTable where statusTempCol = 'frozen')

		update Users
		set [PendingTicketCount] = @pending, 
		[NewTicketCount] = @new,
		[SuccessTicketCount] = @success,
		[ErrorTicketCount] = @error,
		[DeleteTicketCount] = @delete,
		[FrozenTicketCount] = @frozen
		where Email = @currentIndexEmail
	end
end