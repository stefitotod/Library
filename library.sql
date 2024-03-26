DROP DATABASE library;
CREATE DATABASE library;
USE library;

CREATE TABLE publishers(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL
);

INSERT INTO publishers (name, address) VALUES
    ('Penguin Random House', '123 Main St, New York, NY'),
    ('HarperCollins Publishers', '456 Elm St, Los Angeles, CA'),
    ('Pepelina Key', '345 Hopen St, New York, NY');
    
CREATE TABLE books(
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    publisher_id INT,
    CONSTRAINT FOREIGN KEY (publisher_id) REFERENCES publishers(id)
);

INSERT INTO books (title, description, publisher_id) VALUES 
    ('Harry Potter and the Sorcerer''s Stone', 'A young boy discovers he is a wizard and attends a magical school.', 1),
    ('Dune', 'In the distant future, a noble family battles for control over a desert planet.', 1),
    ('The Da Vinci Code', 'A symbologist and a cryptologist race to unravel a secret society''s ancient mystery.', 2),
    ('Gone Girl', 'A wife disappears on her fifth wedding anniversary, leaving her husband as the prime suspect.', NULL);

CREATE TABLE authors(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    info VARCHAR(255) NOT NULL
);

INSERT INTO authors (name, info) VALUES 
    ('J.K. Rowling', 'British author best known for the Harry Potter series.'),
    ('Frank Herbert', 'American author famous for the Dune series.'),
    ('Dan Brown', 'American author known for his thrillers, including The Da Vinci Code.'),
    ('Gillian Flynn', 'American author known for her psychological thrillers.');

CREATE TABLE geners(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

INSERT INTO geners (name) VALUES 
    ('Fantasy'),
    ('Science Fiction'),
    ('Mystery'),
    ('Thriller'),
    ('Romance'),
    ('Horror'),
    ('Adventure'),
    ('Biography/Autobiography'),
    ('Self-help'),
    ('Cookbooks');

CREATE TABLE userRole(
    id INT AUTO_INCREMENT PRIMARY KEY,
    roleName VARCHAR(255) NOT NULL
);

INSERT INTO userRole (roleName) VALUES 
('administrator'),
('librarian'),
('student'),
('teacher');

CREATE TABLE users(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    egn VARCHAR(10) UNIQUE NOT NULL,
    pass VARCHAR(15) UNIQUE NOT NULL,
    phone VARCHAR(13) UNIQUE NOT NULL,
    email VARCHAR(25) UNIQUE NOT NULL,
    userRole_id INT NOT NULL,
    CONSTRAINT FOREIGN KEY (userRole_id) REFERENCES userRole(id)
);

INSERT INTO users (name, egn, pass, phone, email, userRole_id) VALUES 
    ('John Doe', '1234567890', 'password123', '123-456-7890', 'john@example.com', 1),
    ('Jane Smith', '0987654321', 'secret321', '987-654-3210', 'jane@example.com', 2),
    ('Alice Johnson', '5678901234', 'alicepass', '567-890-1234', 'alice@example.com', 3),
    ('Bob Brown', '4321098765', 'bobbypass', '432-109-8765', 'bob@example.com', 4);

CREATE TABLE loanBooks(
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT FOREIGN KEY (book_id) REFERENCES books(id)
);

CREATE TABLE books_geners(
    gener_id INT NOT NULL,
    book_id INT NOT NULL,
    CONSTRAINT FOREIGN KEY (gener_id) REFERENCES geners(id),
    CONSTRAINT FOREIGN KEY (book_id) REFERENCES books(id),
    PRIMARY KEY(gener_id, book_id)
);

INSERT INTO books_geners (gener_id, book_id) VALUES 
    (1, 1), -- Fantasy
    (7, 1); -- Adventure

INSERT INTO loanBooks (date, user_id, book_id) VALUES 
    ('2024-03-26', 3, 1),
    ('2024-03-27', 4, 2),
    ('2024-03-28', 3, 3),
    ('2024-03-29', 2, 4);

CREATE TABLE books_authors(
    author_id INT NOT NULL,
    book_id INT NOT NULL,
    CONSTRAINT FOREIGN KEY (author_id) REFERENCES authors(id),
    CONSTRAINT FOREIGN KEY (book_id) REFERENCES books(id),
    PRIMARY KEY(author_id, book_id)
);

INSERT INTO books_authors (author_id, book_id) VALUES 
    (1, 1), -- J.K. Rowling for Harry Potter and the Sorcerer's Stone
    (2, 2), -- Frank Herbert for Dune
    (3, 3), -- Dan Brown for The Da Vinci Code
    (4, 4), -- Gillian Flynn for Gone Girl
    (2, 1), -- Just for the example
    (3, 2);


CREATE VIEW info_books
AS
SELECT books.title AS book_name, books.description AS book_des, GROUP_CONCAT(authors.name) AS author_name, GROUP_CONCAT(geners.name) AS gener, publishers.name AS publisher
FROM books 
LEFT JOIN publishers ON books.publisher_id = publishers.id
LEFT JOIN books_authors ON books.id = books_authors.book_id
LEFT JOIN authors ON books_authors.author_id = authors.id
LEFT JOIN books_geners ON books.id = books_geners.book_id
LEFT JOIN geners ON books_geners.gener_id = geners.id
GROUP BY 
    books.title,
	books.description, 
	publishers.name;
    
SELECT books.title AS book_title, publishers.name AS publisher_name
FROM books
LEFT JOIN publishers ON books.publisher_id = publishers.id
UNION
SELECT books.title AS book_title, publishers.name AS publisher_name
FROM publishers
LEFT JOIN books ON publishers.id = books.publisher_id
WHERE books.publisher_id IS NULL;

SELECT a1.name AS author1, a2.name AS author2, b.title AS name
FROM books AS b
JOIN books_authors AS ba1 ON b.id = ba1.book_id
JOIN authors AS a1 ON ba1.author_id = a1.id
JOIN books_authors AS ba2 ON b.id = ba2.book_id
JOIN authors AS a2 ON ba2.author_id = a2.id
WHERE a1.id > a2.id
ORDER BY name;

SELECT u.name AS student_name,
    u.phone AS student_number,
    u.email AS student_email,
    COUNT(l.id) AS number_of_taken_books
FROM users as u 
JOIN loanbooks AS l ON u.id = l.user_id
JOIN books AS b ON l.book_id = b.id
JOIN publishers AS p ON b.publisher_id = p.id
WHERE p.name = 'Pepelina Key' AND u.userRole_id = (SELECT id FROM userRole WHERE roleName = 'student')
GROUP BY u.name, u.phone, u.email
HAVING COUNT(l.id) > 5;
