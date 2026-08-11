use library_db;

select * from books;
select * from borrow;
select*from members;
select*from staff;
select * from fines;

-- questions on library database

-- 1) Write a query to display each member’s name and the total number of books they have borrowed.

select m.member_id,concat(m.first_name,'',m.last_name) as name, count(b.book_id) as no_of_books_borrowed
from members m join borrow b on m.member_id = b.member_id
group by m.member_id;

-- 2) Find the members who returned their books late and have unpaid fines. Show member name, book title, and fine amount.

select m.member_id,concat(m.first_name,'',m.last_name) as name,bk.title,f.amount
from members m join borrow b on m.member_id = b.member_id join books bk on b.book_id = bk.book_id
join fines f on b.borrow_id = f.borrow_id
where f.paid_status='unpaid' and due_date<return_date;

-- 3) List all books that have not been returned (return_date IS NULL) with member name and borrow date.

select m.member_id,concat(m.first_name,'',m.last_name) as name, bk.title,b.borrow_date,b.return_date
from members m join borrow b on m.member_id = b.member_id join books bk on bk.book_id = b.book_id
where b.return_date is null;

-- 4) Find the book that has been borrowed the maximum number of times.

select bk.book_id,bk.title,count(b.borrow_id) as no_of_borrowed
from books bk join borrow b on bk.book_id = b.book_id
group by bk.title ,bk.book_id
having no_of_borrowed>1;

-- 5) Write a query to calculate the total fines collected (sum of all paid fines).

select sum(amount) as total_fine 
from fines
where paid_status = 'paid';

-- 6) Find which staff member has issued the highest number of books.

select s.staff_id,concat(first_name,'',last_name) as name,count(b.borrow_id) as books_issued
from staff s join borrow b on s.staff_id = b.staff_id
group by s.staff_id
order by books_issued desc 
limit 1;

-- 7) Display members who have borrowed more than one book (use GROUP BY and HAVING).

select m.member_id,concat(m.first_name,'',m.last_name)as name,count(b.borrow_id) as book_borrow
from members m join borrow b on m.member_id=b.member_id
group by m.member_id
having book_borrow>1;

-- 8) Show each category of books with total copies and available copies.

select category,sum(total_copies)as total_copies,sum(available_copies) as available_copies
from books
group by category;

-- 9) Find members who have never paid any fines (amount = 0).

select m.member_id,concat(m.first_name,'',m.last_name)as name ,f.amount 
from members m join borrow b on m.member_id = b.member_id
join fines f on f.borrow_id = b.borrow_id
where f.amount=0;

-- 10) Calculate the average number of days each member takes to return a book (use DATEDIFF(return_date, borrow_date)).

select m.member_id,concat(m.first_name,'',m.last_name) as name,avg(datediff(b.return_date,b.borrow_date))as avg_days_to_return
from members m join borrow b on m.member_id = b.member_id
where b.return_date is not null
group by m.member_id;
