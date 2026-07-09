# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Schema
    class SolidQueueTablesTest < ActiveSupport::TestCase
      test 'required tables come from installed solid_queue gem template' do
        tables = SolidQueueTables.required_tables

        assert_includes tables, 'solid_queue_jobs'
        assert_includes tables, 'solid_queue_processes'
        assert tables.size >= 10
      end

      test 'parses ruby schema files' do
        Dir.mktmpdir do |dir|
          path = Pathname(dir).join('schema.rb')
          path.write(<<~RUBY)
            create_table "solid_queue_jobs", force: :cascade do |t|
            end
            create_table :solid_queue_processes do |t|
            end
          RUBY

          tables = SolidQueueTables.send(:parse_file, path)

          assert_equal %w[solid_queue_jobs solid_queue_processes], tables.sort
        end
      end

      test 'parses sql structure files' do
        Dir.mktmpdir do |dir|
          path = Pathname(dir).join('structure.sql')
          path.write(<<~SQL.squish)
            CREATE TABLE public.solid_queue_jobs (
              id bigint NOT NULL
            );
            CREATE TABLE "solid_queue_processes" (
              id bigint NOT NULL
            );
          SQL

          tables = SolidQueueTables.send(:parse_file, path)

          assert_equal %w[solid_queue_jobs solid_queue_processes], tables.sort
        end
      end

      test 'detects tables from structure.sql' do
        Dir.mktmpdir do |dir|
          root = Pathname(dir)
          sql = root.join('db/structure.sql')
          sql.dirname.mkpath
          sql.write('CREATE TABLE public.solid_queue_jobs (id bigint);')

          detection = SolidQueueTables.detected_tables(rails_root: root)

          assert_includes detection[:tables], 'solid_queue_jobs'
          assert_includes detection[:file_tables].keys, 'db/structure.sql'
        end
      end
    end
  end
end
