create database Facebook
use Facebook

create table FacebookUser(
	Id int identity primary key,
	Name nvarchar(200),
	Surname nvarchar(200),
	ProfilePhoto nvarchar(500),
	Biography nvarchar(1000),
	PostCount int,
)

create table Posts(
	Id int identity primary key,
	Image nvarchar(1000),
	Text nvarchar(1000)
)

create table Comment(
	Id int identity primary key,
	Text nvarchar(1000)
)

alter table Posts add UserId int references FacebookUser(Id)

alter table Comment add PostId int references Posts(Id)
alter table Comment add UserId int references FacebookUser(Id)

create view PostsUsers as
Select Posts.Text 'Posts', FacebookUser.Name 'User Name', FacebookUser.Surname 'User Surname' from Posts
join FacebookUser
on Posts.UserId= FacebookUser.Id

drop view PostsUsers


create function GetCommentsCount (@UserId int)
returns int
as
begin
	declare @CommentCount int
	select @CommentCount= Count(*)  from Comment join Posts on Comment.PostId= (select top 1 Posts.Id where Posts.UserId= @UserId)
	return @CommentCount
end

select dbo.GetCommentsCount(1)

alter table FacebookUser drop column PostCount
alter table FacebookUser add PostsCount int default 0

select * from FacebookUser

create trigger PostAdded
on Posts
after insert
as
begin
	update FacebookUser set PostsCount= PostsCount+1 where Id=(select UserId from inserted Posts)
end

insert into Posts (Image, Text, UserId)
values ('three', 'lorem ipsum', 1)
