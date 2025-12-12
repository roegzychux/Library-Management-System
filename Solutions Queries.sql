-- Project Tasks

-- Task 1: New Staff Onboarding
-- Objective: A new employee has joined the library. Insert a new record into the 'employees' table.

INSERT INTO employees(emp_id, emp_name, position, salary, branch_id)
VALUES
('E112', 'Samantha Fred', 'Clerk', 45000.00, 'B002');

-- Task 2: Inflation Adjustment
-- Objective: The library needs to increase revenue. Update the 'rental_price' of all books in the 'Classic' category, increasing them by 10%.
UPDATE books
SET rental_price = rental_price * 1.10
WHERE category = 'Classic';

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Check Availability
-- Objective: A customer is looking for a specific book. Select all books written by 'J.K. Rowling' (or another author in your DB) that currently have the status 'yes'.
SELECT * 
FROM books
WHERE author = 'E.B. White';


-- Task: Identify Authors with Multiple Published Books
/* Objective: Write a query to find authors who have written more than one book in the library. 
Display the author's name, the count of books they have written, and a comma-separated list of the book titles. */
SELECT
	group_concat(book_title) as books_list,
    author,
    COUNT(author)
FROM books
GROUP BY author
HAVING COUNT(author) > 1;

-- Task 5: Branch Performance Analysis
-- Objective: Find out how many employees work in each branch.
SELECT
	group_concat(emp_id),
	branch_id,
    COUNT(emp_id) as number_of_employees
FROM employees
GROUP BY branch_id;

-- Task 6: High-Value Inventory
-- Objective: Which book categories are the most expensive to stock? Calculate the average rental price for each category and the number of books in each category.
 SELECT
	category,
    COUNT(isbn) as Number_of_books,
    round(AVG(rental_price), 2) as average_rental_price,
    RANK() OVER (ORDER BY AVG(rental_price) desc) AS ranking
FROM books
GROUP BY category;

-- Task 7: Finding Active Readers
-- Objective: We want to reward our best customers. List the names of members who have issued at least 3 books.

SELECT 
	issued_member_id,
    COUNT(issued_member_id) as issued_times,
    RANK() OVER (ORDER BY COUNT(issued_member_id) desc) AS ranking
FROM issued_status
GROUP BY issued_member_id;
    
-- Task 8: Overdue Analysis (Date Differences)
/* Objective: Identify transactions where the book was held for a long time. 
Retrieve the 'issued_id', 'issued_book_name', and the number of days the book has been out. Assume current date to be 2024-05-05 */

SELECT
	issued_id,
    issued_book_name,
    issued_date,
    DATEDIFF('2024-05-05', issued_date) as days_held
FROM issued_status
ORDER BY days_held desc;
    
-- Task 9: Create a "Branch Stats" Table
/* Objective: Use CTAS to create a new table called 'branch_issued_totals'. This table should contain the 'branch_id', 
the total number of employees in that branch, and the total number of books issued by employees of that branch. */
CREATE TABLE branch_issued_totals
AS
SELECT
    b.branch_id,
    COUNT(DISTINCT e.emp_id) as total_employees,
    COUNT(ist.issued_id) as number_of_issued_books
FROM branch as b
JOIN employees as e
	ON b.branch_id = e.branch_id
JOIN issued_status as ist
	ON e.emp_id = ist.issued_emp_id
GROUP BY branch_id;

select * from branch_issued_totals;

-- Task 10: Unused Inventory
-- Objective: Which books have never been issued?
SELECT 
	b.book_title as book_title,
    COUNT(ist.issued_id) as issued_no_of_times
FROM books as b
LEFT JOIN issued_status as ist
	ON b.book_title = ist.issued_book_name
GROUP BY b.book_title
HAVING COUNT(ist.issued_id) = 0;

-- Task 11: Categorize Members by Activity
-- Objective: Select member names and create a new column called 'activity_level'. If they registered in the last 90 days, label them 'New'. Otherwise, label them 'Existing'.

ALTER TABLE members
ADD COLUMN activity_level varchar(15);

UPDATE members
SET activity_level = CASE
	WHEN DATEDIFF('2024-06-25', reg_date) <= 90 THEN 'New'
    ELSE 'Existing'
END;

SELECT * FROM members;

-- Task 12: Employee vs. Manager Check
-- Objective: List the names of employees who have processed more book issues than their own manager.

WITH issue_counts AS (
    SELECT 
        issued_emp_id, 
        COUNT(issued_id) as total_issues
    FROM issued_status
    GROUP BY issued_emp_id
)
SELECT 
    e.emp_name as employee_name,
    ec.total_issues as employee_issues,
    m.emp_name as manager_name,
    mc.total_issues as manager_issues
FROM employees as e
JOIN issue_counts as ec 
    ON e.emp_id = ec.issued_emp_id  -- Connect employee to their score
JOIN branch as b 
    ON e.branch_id = b.branch_id    -- Find the branch to get the manager ID
JOIN employees as m 
    ON b.manager_id = m.emp_id      -- Connect branch to the manager's details
JOIN issue_counts as mc 
    ON m.emp_id = mc.issued_emp_id  -- Connect manager to THEIR score
WHERE ec.total_issues > mc.total_issues; -- The final check


-- Task 13: Identify Members with Overdue Books
-- Objective: Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    (DATEDIFF('2024-05-20', ist.issued_date ) - 30) as days_overdue     -- Calculate overdue days. 
FROM issued_status as ist
JOIN members as m 
    ON m.member_id = ist.issued_member_id
JOIN books as bk 
    ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rs 
    ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND DATEDIFF('2024-05-20', ist.issued_date) > 30
ORDER BY days_overdue DESC;


-- Task 14: Update Book Status on Return
-- Objective: Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

UPDATE books
SET status = 'yes'
WHERE isbn IN (
    SELECT issued_book_isbn 
    FROM issued_status 
    WHERE issued_id IN (SELECT issued_id FROM return_status)
);


-- Task 15: Branch Performance Report
-- Objective: Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

CREATE TABLE performance_report
AS
SELECT
	b.branch_id,
	COUNT(ist.issued_id) AS number_of_issued_books,
	COUNT(rs.issued_id) AS number_of_returned_books,
    SUM(bK.rental_price) AS revenue
FROM issued_status AS ist
LEFT JOIN return_status AS rs
	ON ist.issued_id = rs.issued_id
JOIN books as bk
	ON ist.issued_book_isbn = bk.isbn
JOIN employees as e
	ON ist.issued_emp_id = e.emp_id
JOIN branch as b
	ON b.branch_id = e.branch_id
GROUP BY b.branch_id;

SELECT * FROM performance_report;


-- Task 16: CTAS: Create a Table of Active Members
-- Objective: Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
CREATE TABLE active_members
AS
SELECT
	member_id,
    member_name
FROM members as m
WHERE member_id IN (SELECT DISTINCT
						issued_member_id
                        FROM issued_status
                        WHERE DATEDIFF('2024-05-20', issued_date) < 60);

SELECT * FROM active_members;


-- Task 17: Find Employees with the Most Book Issues Processed
-- Objective: Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

WITH ranked_employees AS (
SELECT 
	e.emp_id,
    e.emp_name,
    b.branch_id,
    COUNT(ist.issued_emp_id) as number_of_processed_books,
    RANK() OVER (ORDER BY COUNT(ist.issued_emp_id) desc) AS ranking
FROM employees AS e
JOIN issued_status as ist
	ON e.emp_id = ist.issued_emp_id
JOIN branch as b
	ON e.branch_id = b.branch_id
GROUP BY emp_id, emp_name, branch_id
ORDER BY number_of_processed_books)
SELECT * FROM ranked_employees 
WHERE ranking <=3;

-- Task 18: Identify Members Who Have Never Borrowed a Book
-- Objective: Find the list of members who have registered but not yet issued a book.
SELECT * FROM members
WHERE member_id NOT IN (
    SELECT DISTINCT issued_member_id 
    FROM issued_status
);


