INSERT INTO users(id, login, full_name) VALUES
    (1, 'example', 'Example User');

-- Because the users table has a SERIAL sequence and we manually force user.id entries
-- in our default database data we need to adjust the sequence so that subsequent inserts
-- will get correct sequence.
SELECT setval('users_id_seq', (select max(id) from users));

INSERT INTO tweets(user_id, tweet) VALUES
    (1, 'Hello, World!');
