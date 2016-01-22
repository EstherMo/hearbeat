DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS topics;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS comments;


CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR,
  password VARCHAR,
  image VARCHAR
);

CREATE TABLE topics (
  id SERIAL PRIMARY KEY,
  name VARCHAR,
  description VARCHAR
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR,
  message VARCHAR,
  today_date VARCHAR,
  likes INTEGER,
 	user_id INTEGER,
 	topic_id INTEGER
);



CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  title VARCHAR,
  message VARCHAR,
  today_date VARCHAR,
  likes INTEGER,
  user_id INTEGER,
  post_id INTEGER
);

insert into topics(name,description) values ('General', 'this is for general topics');
insert into topics(name,description) values ('Announcements', 'this is for forum Announcements');
insert into topics(name,description) values ('Questions', 'this is for questions');
insert into posts(title,message,today_date,topic_id) values ('first post','this is a test','march 20',1);
insert into posts(title,message,today_date,topic_id) values ('second post','this is a test as well','march 20',2);
insert into posts(title,message,today_date,topic_id) values ('third post','this is a question post','march 20',3);
insert into posts(title,message,today_date,topic_id) values ('another post','this is the second question post','march 20',3);
insert into posts(title,message,today_date,topic_id) values ('another post','this is the third question post','march 20',3);
insert into comments(message,post_id) values ('reply to post 1', 1);
insert into comments(message,post_id) values ('reply to post 3', 3);
insert into comments(message,post_id) values ('reply to post 4', 4);
insert into comments(title,message,post_id) values ('re:first post','second reply to post 1', 1);




-- CREATE TABLE likes (
--   id SERIAL PRIMARY KEY,
--   post_id VARCHAR,
--   comment_id VARCHAR
-- );