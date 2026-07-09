# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class QueueSchemaCheckTest < ActiveSupport::TestCase
        test 'passes when queue schema exists' do
          result = QueueSchemaCheck.call

          assert_predicate result, :pass?
        end

        test 'passes when solid queue tables exist only in structure.sql' do
          Dir.mktmpdir do |dir|
            root = Pathname(dir)
            structure = root.join('db/structure.sql')
            structure.dirname.mkpath
            Schema::SolidQueueTables.required_tables.each do |table|
              structure.write("CREATE TABLE public.#{table} (id bigint);\n", mode: 'a')
            end

            QueueSchemaCheck.any_instance.stubs(:rails_root).returns(root)

            result = QueueSchemaCheck.call

            assert_predicate result, :pass?
            assert_includes result.message, 'db/structure.sql'
          ensure
            QueueSchemaCheck.any_instance.unstub(:rails_root)
          end
        end

        test 'warns when solid queue tables are partially present' do
          Dir.mktmpdir do |dir|
            root = Pathname(dir)
            structure = root.join('db/structure.sql')
            structure.dirname.mkpath
            structure.write('CREATE TABLE public.solid_queue_jobs (id bigint);')

            QueueSchemaCheck.any_instance.stubs(:rails_root).returns(root)
            Schema::SolidQueueTables.stubs(:tables_in_queue_database).returns([])

            result = QueueSchemaCheck.call

            assert_predicate result, :warn?
            assert_includes result.message, 'Missing Solid Queue tables'
          ensure
            QueueSchemaCheck.any_instance.unstub(:rails_root)
            Schema::SolidQueueTables.unstub(:tables_in_queue_database)
          end
        end

        test 'fails when no solid queue schema is present' do
          Dir.mktmpdir do |dir|
            root = Pathname(dir)
            QueueSchemaCheck.any_instance.stubs(:rails_root).returns(root)
            Schema::SolidQueueTables.stubs(:tables_in_queue_database).returns([])

            result = QueueSchemaCheck.call

            assert_predicate result, :fail?
            assert_includes result.message, 'No Solid Queue schema tables found'
          ensure
            QueueSchemaCheck.any_instance.unstub(:rails_root)
            Schema::SolidQueueTables.unstub(:tables_in_queue_database)
          end
        end
      end
    end
  end
end
