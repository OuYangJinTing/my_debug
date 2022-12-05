require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org/"

  gem "pry"
  gem "activerecord"
  gem "mysql2"
end

require "pry"
require "mysql2"
require "active_support/all"
require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: "mysql2",
  host: "mysql5.6",
  username: "root",
  database: ENV["MYSQL_DATABASE"]
)

ActiveRecord::Schema.define do
  create_table :test_performances, if_not_exists: true do |t|
    t.integer :user_id, null: false
    t.text :read_ids_str, null: false
    t.text :unread_ids_str, null: false
    t.index :user_id, unique: true
  end
end

class TestPerformance < ActiveRecord::Base; end

# 插入一千万条样本数据
user_id = 0
attributes = []
100.times do |i|
  100_000.times do
    user_id = user_id + 1
    attributes << {
      user_id: user_id,
      read_ids_str: ",#{rand(10_000)}",
      unread_ids_str: ",#{rand(10_000)}"
    }
  end
  measure = Benchmark.measure { TestPerformance.insert_all(attributes) }
  attributes.clear
  puts "Sample Data Insertion ProgressBar: #{i + 1}/100, measure: #{measure}"
end

ActiveRecord::Base.logger = Logger.new(STDOUT)

def test_update_performances(count)
  user_ids = []
  count.times { user_ids << rand(10_000) }
  sql = <<-SQL.strip_heredoc
    UPDATE test_performances
    SET unread_ids_str = CONCAT(unread_ids_str, ",#{rand(10_000)}")
    WHERE user_id IN (#{user_ids.join(', ')})
  SQL
  TestPerformance.connection.execute(sql)
end
test_update_performances(1_000)
test_update_performances(10_000)

binding.pry
