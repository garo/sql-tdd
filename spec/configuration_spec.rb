
RSpec.configure do |config|
    config.before(:suite) do
        @admin_conn = PG.connect(dbname: "postgres", port: 5432, user: "postgres")
        @admin_conn.exec "DROP DATABASE IF EXISTS test_db"
        @admin_conn.exec "DROP ROLE tdd_ro"
        @admin_conn.exec "DROP ROLE tdd_all"
        @admin_conn.exec "CREATE DATABASE test_db"
        @admin_conn.exec "CREATE ROLE tdd_ro WITH PASSWORD 'tdd_ro' LOGIN"
        @admin_conn.exec "CREATE ROLE tdd_all WITH PASSWORD 'tdd_all' LOGIN INHERIT CREATEROLE"
        @admin_conn.exec "GRANT ALL PRIVILEGES ON DATABASE test_db TO tdd_all WITH GRANT OPTION"

        
        @all_conn = PG.connect(dbname: "test_db", port: 5432, user: "tdd_all", password: "tdd_all")

        # load schema
        schema = File.read("./schema.sql")
        @all_conn.exec(schema)

        # load data
        data = File.read("./data.sql")
        @all_conn.exec(data)
        
        @all_conn.close
        @admin_conn.close

    end
end
