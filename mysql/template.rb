# Specify gems versions you want to test
gem 'activerecord', "4.2.10"
gem "mysql2", "0.4.10"

require 'active_record'
require 'mysql2'
require 'logger'
require 'uri'

if ARGV[0] == '--debug'
  class Logger
    alias :original_debug :debug
    def debug(*args, &block)
      original_debug(*args, &block)

      caller_line = caller.detect do |caller_line|
        # Change logic in here if you want to try match on lines that aren't in
        # this file.
        caller_line.match(/template/)
      end

      self.original_debug("\t↳ #{File.basename(caller_line)}") if caller_line
    end
  end

  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

mysql = URI(ENV['MYSQL_URL'])
database = mysql.path.sub(%r(^/), "")

# set up database
MYSQL_SPEC = {
  adapter:  'mysql2',
  database: 'database_name',
  'username' => mysql.user,
  'host' => mysql.host,
  'port' => mysql.port,
  'password' => mysql.password
}

ActiveRecord::Base.establish_connection(
  MYSQL_SPEC.merge('database' => database)
)

# Drop and create the database. The drop can fail if the database doesn't exist,
# for example when this is first ran. Just ignore it. Using `force: true` on the
# `create_table` method will also force a drop first.
ActiveRecord::Base.connection.drop_database(MYSQL_SPEC[:database]) rescue nil
ActiveRecord::Base.connection.create_database(MYSQL_SPEC[:database])

ActiveRecord::Base.establish_connection(MYSQL_SPEC)

# Set the AR logger to STDOUT. Optional but often useful to see what is going on
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Create migrations
class CreateModels < ActiveRecord::Migration
  def self.change
    create_table :examples do |t|
    end
  end
end

# run migrations
CreateModels.change

# define models and populate db
class Example < ActiveRecord::Base
end

# Repro issue
Example.create!
