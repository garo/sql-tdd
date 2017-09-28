require 'pg'
require 'pp'

RSpec.describe "schema" do
    before(:all) do
        @all_conn = PG.connect(dbname: "test_db", port: 5433, user: "tdd_all", password: "tdd_all")

        @conn = PG.connect(dbname: "test_db", port: 5433, user: "tdd_ro", password: "tdd_ro")
    end

    after(:all) do
        @all_conn.close
        @conn.close
    end

    it "can query" do
        rs = @conn.exec "SELECT 1 as a"
        expect(rs.getvalue(0, 0)).to eq("1")
        expect(rs[0]["a"]).to eq("1")
    end

    it "tables exists" do
        rs = @all_conn.exec "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"
        tables = rs.values.flatten
        expect(tables.include?("users")).to eq(true)
        expect(tables.include?("tweets")).to eq(true)
    end

    describe "users" do
        it "can have user entries" do
            ret = @all_conn.exec "INSERT INTO users(login, full_name) VALUES('unique-user', 'first') RETURNING id"
            expect(ret[0]["id"].to_i).to be > 0

            ret = @all_conn.exec "SELECT * FROM users WHERE id = #{ret[0]["id"]}"
            expect(ret[0]["login"]).to eq("unique-user")
            expect(ret[0]["full_name"]).to eq("first")
            
        end

        it "requires login names to be unique" do
            expect {
                ret = @all_conn.exec "INSERT INTO users(login, full_name) VALUES('unique-user', 'second') RETURNING id"
            }.to raise_error(PG::UniqueViolation)
        end
    end

    describe "tweets" do
        it "has foreign key on user_id to users(id)" do
            expect {
                ret = @all_conn.exec "INSERT INTO tweets(user_id, tweet) VALUES(0, 'test') RETURNING id"
            }.to raise_error(PG::ForeignKeyViolation)
        end
    end

end
