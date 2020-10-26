create database ShopDB;
use ShopDB;
-- use master;
-- drop database ShopDB;

create table Employee(
    e_id int primary key,
    e_name varchar(20) not null,
    contact_number int not null,
    e_email varchar(30) not null,
    joining_date date not null,
    e_role varchar(10) not null,
    e_gender varchar(10) not null,
    e_salary decimal(10) not null,
    e_address varchar(100)
)
select * from Employee

create table Customer(
    c_id int primary key,
    c_name varchar(15) not null,
    contact_number int not null,
    c_email varchar(30) not null,
    c_gender varchar(10) not null,
    c_address varchar(100)
)
select * from Customer

create table Products(
    p_id int primary key,
    p_name varchar(20) not null,
    p_price decimal(10) not null,
    p_description varchar(100),
    p_stock int,
    p_expiry_date date
)
select * from Products

create table OrderDetails(
    o_id int primary key,
    c_id int foreign key references Customer(c_id),
    products_name nchar(100) not null,
    order_date date not null,
    sales_person int foreign key references Employee(e_id),
    total_bill decimal(8) not null
)
select * from OrderDetails

create table MonthlySales(
    sale_month int not null check(sale_month between 1 and 12),
    sale_year int not null check(sale_year between 2019 and 2050),
    c_id int foreign key references Customer(c_id),
    total decimal(10) not null,
    primary key(sale_month, sale_year, c_id)
)
select * from MonthlySales

create table MonthlySalesByAllCustomer(
    sale_month int not null check(sale_month between 1 and 12),
    sale_year int not null check(sale_year between 2019 and 2050),
    total decimal(10) not null,
    primary key(sale_month, sale_year)
)
select * from MonthlySalesByAllCustomer
go


-- truncate table Products
-- truncate table OrderDetails
-- truncate table MonthlySales
-- truncate table MonthlySalesByAllCustomer
-- ON DELETE CASCADE

-- truncate table Employee
-- delete from Employee 
-- select * from Employee
-- truncate table Customer
-- delete from Customer

-- select * from Employee;

create or alter function dbo.getTotalSale()
    returns decimal(10)
    as
    begin
        return (select sum(total) from MonthlySalesByAllCustomer)
    end
go

create or alter function dbo.getEmployeeDetails(@employee_id as int)
    returns table
    as
    return (select * from Employee where e_id=@employee_id)
go

create or alter function dbo.getProductsDetails(@product_id as int)
    returns table
    as
    return (select * from Products where p_id=@product_id)
go

create or alter function dbo.getCustomerDetails(@customer_id as int)
    returns table
    as
    return (select * from Customer where c_id=@customer_id)
go

create or alter function dbo.getOrderDetails(@order_id as int)
    returns table
    as
    return ( select * from OrderDetails where o_id=@order_id)
go

create or alter procedure showAllCustomer
    as 
    select * from Customer
go

create or alter procedure showEmployees
    as 
    select * from Employee
go

create or alter procedure showAllProducts
    as 
    select * from Products
go

create or alter procedure employeeGender @gender varchar(10)
    as 
    select * from Employee where e_gender=@gender
go

create or alter procedure customerGender @gender varchar(10)
    as 
    select * from Customer where c_gender=@gender
go

create or alter procedure showAllOrder
    as 
    select * from OrderDetails
go

create or alter procedure showMonthlySaleByEachCustomer
    as
    begin
        select * from MonthlySales
    end
go

create or alter procedure showMonthlySaleByAllCustomer
    as
    begin
        select * from MonthlySalesByAllCustomer
    end
go


create or alter procedure makeOrder 
    @customer_id int,
    @total decimal(10),
    @products varchar(100),
    @salesManId int = 103,
    @maxId int = 1
    as
    begin
    if (select count(*) from OrderDetails) > 0
    begin
       set @maxId = (select max(o_id)+1 from OrderDetails)  
    end
    insert into OrderDetails values (
        @maxId,
        @customer_id,
        @products,
        getdate(),
        @salesManId,
        @total )
    end
go

create or alter procedure fillMonthlySalesByAllCustomer
    as
    begin
    truncate table MonthlySalesByAllCustomer
    insert into MonthlySalesByAllCustomer 
    (total, sale_month, sale_year)
    select sum(total), 
    sale_month, 
    sale_year 
    from MonthlySales
    group by sale_month, sale_year
    end
go

create or alter procedure fillMonthlySealsOfIndividualCustomer
    as
    begin
    insert into MonthlySales 
    (
        total,
        sale_month,
        sale_year,
        c_id
    )
    (select  sum(total_bill),
            month(order_date),
            year(order_date),
            c_id from OrderDetails 
        group by month(order_date),
            year(order_date),
            c_id
    )
    end
go

create or alter procedure addEmployee 
    @emp_name varchar(20),
    @contact_number int,
    @email varchar(30),
    @gender varchar(10),
    @role varchar(10)='sales',
    @salary int = 10000,
    @emp_address varchar(100)= null,
    @maxId int = 101
    as
    begin
    if (select count(*) from Employee) > 0
    begin
       set @maxId = (select max(e_id)+1 from Employee)  
    end
    insert into Employee values (
        @maxId,
        @emp_name,
        @contact_number,
        @email,
        getdate(),
        @role,
        @gender,
        @salary,
        @emp_address)
    end
go

create or alter procedure addCustomer
    @c_name varchar(20),
    @contact_number int,
    @email varchar(30),
    @gender varchar(10),
    @c_address varchar(100)= null,
    @maxId int = 201
    as
    begin
    if (select count(*) from Customer) > 0
    begin
       set @maxId = (select max(c_id)+1 from Customer)  
    end
    insert into Customer values (
        @maxId,
        @c_name,
        @contact_number,
        @email,
        @gender,
        @c_address)
    end
go

create or alter procedure addProduct
    @p_name varchar(20),
    @p_price decimal(10),
    @p_stock varchar(100)= 100,
    @expir_in_years int = 5,
    @p_description varchar(10)=null,
    @maxId int = 301
    as
    begin
    if (select count(*) from Products) > 0
    begin
       set @maxId = (select max(p_id)+1 from Products)  
    end
    insert into Products values (
        @maxId,
        @p_name,
        @p_price,
        @p_description,
        @p_stock,
        dateadd(year, @expir_in_years, getdate()))
    end
go



-- adding employee to Shop
-- name, contact, email, gender, role,salary, address
exec addEmployee 'divya',
    7864, 'divy@7.com',
    'Female', 'HR',
    1100000, 'Place Road, Sirohi, Rajasthan'
go
exec addEmployee 'sonu',
    7896, 'sonu@4.com',
    'Male', 'Sales',
    700000, 'Mount-Abu, Sirohi, Rajasthan'
go

exec addEmployee 'annya',
    7584, 'ani@77.com',
    'Female', 'Sales',
    810000, 'Temple Road, Sirohi, Rajasthan'
go

exec addEmployee 'pradeep',
    7742, 'pradeep@7.com',
    'Male','CEO',100000000,
    '29 police line, Sirohi, Rajasthan'
go

exec showEmployees

-- adding product
-- name, price, stock, _exp_yaer, descp
exec addProduct 'Arial 5-kg', 250, 5, 4,
    'Arial Wasing Powder'
go
exec addProduct 'Rin 15-kg', 450, 51, 4,
    'Detergent Powder, Chamakte Rhahena'
go
exec addProduct 'Tide Plus+ 10-kg', 250, 5, 5,
    'Tide Plus + jasmine & Rose'
go
exec addProduct 'Nirma Advance 2-kg', 505,1000, 7, 
    'Nirma Advance Washing Powder, free one nirma sope'
go
exec addProduct 'Surf-excel 13-kg', 760, 200, 10,
    'Detergent Powder, Quick Wash'
go
exec addProduct 'Wheel 7-kg', 250, 2000, 12,
    'Super Hero Wasing Powder'
go

exec showAllProducts

-- adding customer
-- name, contact, email, gender, address
exec addCustomer 'Harsh',7655,
    'hashu@21.com','Male',
    'mount-vally, Rajasthan'
go
exec addCustomer 'divu',7645,
    'divu@3.com','female',
    'mount-vally, Rajasthan'
go
exec addCustomer 'djkastra',7635,
    'dj4u@life.com','Male',
    'mount-vally, Rajasthan'
go
exec addCustomer 'kurshkal',7625,
    'kursh@11.com','Male',
    'mount-abu, Rajasthan'
go

exec showAllCustomer

-- taking order in shops
--  customerid, total bill, products name(row-text)
exec makeOrder 203,500,'soap and washing power'
go
exec makeOrder 203,560,'washing power'
go
exec makeOrder 202,570,'soap, cloths'
go
exec makeOrder 202,502,'soap and washing power'
go
exec makeOrder 204,500,'washing power'
go
exec makeOrder 201,790,'soap, cloths'
go

exec showAllOrder

exec fillMonthlySealsOfIndividualCustomer
go

exec showMonthlySaleByEachCustomer 
go

exec fillMonthlySalesByAllCustomer
go

exec showMonthlySaleByAllCustomer
go

select dbo.getTotalSale() 'Total Sale Over All Time'
go

select * from dbo.getEmployeeDetails(101)
go
select * from dbo.getProductsDetails(304)
go
select * from dbo.getOrderDetails(4)
go
select * from dbo.getCustomerDetails(201)
go

exec showMonthlySaleByAllCustomer
select * from MonthlySalesByAllCustomer order by
        sale_year asc, sale_month asc;
go

create or alter procedure IncreaseInSales
    @month1 as int,
    @year1 as int,
    @month2 as int,
    @year2 as int,
    @ans as int=1     
    as
    begin
        set @ans =
        (select sum(total) from MonthlySalesByAllCustomer 
            where sale_month=@month2 and sale_year=@year2)
        -(select sum(total) from MonthlySalesByAllCustomer 
            where sale_month=@month1 and sale_year=@year1)  
        if(@ans>0)
            begin
                select @ans 'Insercese in Sales'
            end
        if(@ans<0)
            begin
                select -1*@ans 'Decrese in Sales'
            end
        if(@ans=0)
            begin
                select @ans 'Constant Sales'
            end      
    end
go

exec IncreaseInSales 7, 2020, 9, 2020
exec IncreaseInSales 9, 2020, 8, 2020
exec IncreaseInSales 7, 2020, 7, 2020
go

create or alter procedure IncreaseInSales
    @month1 as int,
    @year1 as int,
    @month2 as int,
    @year2 as int,
    @ans as int=1     
    as
    begin
        set @ans =
        (select sum(total) from MonthlySalesByAllCustomer 
            where sale_month=@month2 and sale_year=@year2)
        -(select sum(total) from MonthlySalesByAllCustomer 
            where sale_month=@month1 and sale_year=@year1)  
        if(@ans>0)
            begin
                select @ans 'Insercese in Sales'
            end
        if(@ans<0)
            begin
                select -1*@ans 'Decrese in Sales'
            end
        if(@ans=0)
            begin
                select @ans 'Constant Sales'
            end      
    end
go

create or alter procedure TotalSaleToCustomer
    @customerId as int=201
    as
    begin
       select( select c_name 
        from Customer 
        where c_id=@customerId) as 'Customer Name',
            ( select sum(total)
        from MonthlySales 
        where c_id=@customerId
       ) as 'Total Sale'
    end
go

exec TotalSaleToCustomer 201


-- nt highest salary
-- 1
select e_salary from Employee order by e_salary;
go

create or alter proc nthHighestSalaryOfEmployee
    @n as int
    as
    begin
        print(cast(@n AS VARCHAR(10)))
        select concat(@n,'th hightest Salary is -->') ' ',min(e_salary) ' '
        from Employee where e_salary in
        (select top(@n) e_salary from
        Employee order by e_salary desc)
    end
go

exec nthHighestSalaryOfEmployee 1
go
exec nthHighestSalaryOfEmployee 2
go
exec nthHighestSalaryOfEmployee 3
go
exec nthHighestSalaryOfEmployee 4
go

-- 2


WITH RESULT AS
(
    SELECT e_SALARY,
           DENSE_RANK() OVER (ORDER BY e_SALARY DESC) AS DENSERANK
    FROM EMPLOYEE
)
SELECT TOP 1 e_SALARY
FROM RESULT
WHERE DENSERANK = 3
go

-- trigger
-- dml trigger
-- inserted  & deleted table is special table that only can be accessed inside a trigger defination

create or alter trigger insertTringgerOnOrderder
on OrderDetails
for insert
as
begin
   print('thank you for having us, come again') 
   select * from inserted;
end
go

create or alter trigger insertTringgerOnEmployee
on Employee
for insert
as
begin
   print('Welcome to Our Shop family') 
   select * from inserted;
end
go

create or alter trigger insertTringgerOnCustomer
on Customer
for insert
as
begin
   print('Welcome to Our Shop, your satisfaction is our goal') 
   select * from inserted;
end
go


create or alter trigger deleteTringgerOnOrderder
on OrderDetails
for delete
as
begin
   print('nil') 
   select * from deleted;
end
go

create or alter trigger deleteTringgerOnEmployee
on Employee
for delete
as
begin
   print('thanks for be with our shop') 
   select * from deleted;
end
go

create or alter trigger deleteTringgerOnCustomer
on Customer
for delete
as
begin
   print('we hope you are happy, to be with us') 
   select * from deleted;
end
go



create or alter trigger updateTringgerOnOrderder
on OrderDetails
for update
as
begin
   print('order updated') 
   select * from inserted;
   select * from deleted;
end
go

create or alter trigger updateTringgerOnEmployee
on Employee
for update
as
begin
   print('Emplyee Details updated') 
   select * from inserted;
   select * from deleted;
end
go

create or alter trigger updateTringgerOnCustomer
on Customer
for update
as
begin
   print('Customer Details updated') 
   select * from inserted;
   select * from deleted;
end
go



-- cte
-- with cte_name(column1, column2, ..)
-- as
-- (CTE_query)

-- comman table expression
---
with employeeCount
as
(
    select e_role, count(*) as total_employees
    from Employee group by e_role
)
---
select e_role, total_employees from employeeCount
---

-- pivot operator

-- select SalesCountry,SalesAgent,Sum(SalesAmount) as Total
-- from tblProductSales
-- group by SalesCountry,SalesAgent
-- order by SalesCountry,SalesAgent

-- select SalesAgent, India, US, UK
-- from tblProductSales
-- pivot(
--     sum(SalesAmount)
--     for SalesCountry
--     in ([India],[US],[UK])
-- )
-- as PivotTable

-- create  index index_name on table onwhich (column with prefercnce)
-- select * from sys.indexes where name like 'idx%'
use ShopDB

select * from Employee
create index idxEmployee on Employee (e_id asc);
go
sp_Helpindex Employee
go

-- create clustered index idxEmployeeSal on Employee (e_salary asc,e_id desc );
-- go
sp_Helpindex Employee

EXEC sp_rename 
        N'Employee.PK__Employee__3E2ED64A3668FA9D',
        N'Employee.idxEmployeeSalary' ,
        N'INDEX';
go
-- drop index Employee.idxEmployeeSalary
