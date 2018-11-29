gem 'activerecord', '4.2.10'
gem 'pg'

require 'active_record'
require 'pg'

if ARGV[0] == '--debug'
  class Logger
    alias :original_debug :debug
    def debug(*args, &block)
      original_debug(*args, &block)

      basename = File.basename(__FILE__)

      # Change this to get different stacktrace output.
      caller_line = caller.detect { |line| line.match(Regexp.escape(basename)) }

      self.original_debug("\t↳ #{caller_line}") if caller_line
    end
  end

  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

# set up database and establish connection
PG_SPEC = {
  adapter:  'postgresql',
  database: 'database_name'
}
ActiveRecord::Base.establish_connection(PG_SPEC.merge('database' => 'postgres'))

# Drop and create the database. The drop can fail if the database doesn't exist,
# for example when this is first ran. Just ignore it. Using `force: true` on the
# `create_table` method will also force a drop first.
ActiveRecord::Base.connection.drop_database(PG_SPEC[:database]) rescue nil
ActiveRecord::Base.connection.create_database(PG_SPEC[:database])

# Establish connection to new database
ActiveRecord::Base.establish_connection(PG_SPEC)

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
