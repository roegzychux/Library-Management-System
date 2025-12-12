# Library Management System Database

# Create Library Management System Database
create database Library_Management_P2;

use library_management_p2;

# Create branch table
drop table if exists branch;
create table branch (
	branch_id varchar(15) primary key,	
	manager_id varchar(15),
	branch_address varchar(55),
    contact_no varchar(15)
    );
    
# Create employees table
create table employees (
	emp_id varchar(15) primary key,
	emp_name varchar(55),
	position varchar(55),
	salary int,
	branch_id varchar(15)  # FK
    );
    
# Create employees table
create table books (
	isbn varchar(25) primary key,
	book_title varchar(55),
	category varchar(25),
	rental_price float,
	status varchar(15),
	author varchar(55),
	publisher varchar(55)
    );

# Create employees table
create table members (
	member_id varchar(15) primary key,
	member_name varchar(55),
	member_address varchar(55),
	reg_date date
    );
    
# Create employees table
create table issued_status (
	issued_id varchar(15) primary key,
	issued_member_id varchar(15),  # FK
	issued_book_name varchar(55),
	issued_date	date,
    issued_book_isbn varchar(25),  # FK
	issued_emp_id varchar(15)  # FK
    );
    
# Create employees table
create table return_status (
	return_id varchar(15),
	issued_id varchar(15),  # FK
	return_book_name varchar(55),
	return_date date,
	return_book_isbn varchar(55)  # FK
    );
    
    
show create table return_status; 

# FOREIGN KEYS
 
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_books_1
FOREIGN KEY (return_book_isbn)
REFERENCES books(isbn);







	



