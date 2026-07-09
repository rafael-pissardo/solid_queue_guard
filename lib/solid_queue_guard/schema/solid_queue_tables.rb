# frozen_string_literal: true

module SolidQueueGuard
  module Schema
    # @api private
    class SolidQueueTables
      SCHEMA_FILES = %w[
        db/queue_schema.rb
        db/schema.rb
        db/structure.sql
      ].freeze

      RUBY_CREATE_TABLE_PATTERN = /
        create_table
        \s+
        (?:
          ["'](?<quoted>solid_queue_[a-z_]+)["']
          |
          :(?<symbol>solid_queue_[a-z_]+)
        )
      /ix

      SQL_CREATE_TABLE_PATTERN = /
        CREATE \ TABLE
        (?: \ IF \ NOT \ EXISTS )?
        \s+
        (?:[\w.]+\.)?
        (?:
          "(?<quoted>solid_queue_[a-z_]+)"
          |
          (?<unquoted>solid_queue_[a-z_]+)
        )
      /ix

      class << self
        def required_tables
          @required_tables ||= tables_from_gem_template || default_required_tables
        end

        def detected_tables(rails_root: Rails.root)
          file_tables = {}
          tables = Set.new

          SCHEMA_FILES.each do |relative_path|
            path = rails_root.join(relative_path)
            next unless path.exist?

            tables_in_file = parse_file(path)
            next if tables_in_file.empty?

            file_tables[relative_path] = tables_in_file.sort
            tables.merge(tables_in_file)
          end

          database_tables = tables_in_queue_database
          tables.merge(database_tables)

          {
            tables: tables.sort,
            file_tables: file_tables,
            database_tables: database_tables.sort
          }
        end

        def missing_tables(rails_root: Rails.root)
          required_tables - detected_tables(rails_root: rails_root)[:tables]
        end

        def tables_from_gem_template
          spec = Gem.loaded_specs['solid_queue']
          return nil unless spec

          template = File.join(
            spec.full_gem_path,
            'lib/generators/solid_queue/install/templates/db/queue_schema.rb'
          )
          return nil unless File.exist?(template)

          parse_ruby_schema(File.read(template))
        end

        def default_required_tables
          %w[
            solid_queue_blocked_executions
            solid_queue_claimed_executions
            solid_queue_failed_executions
            solid_queue_jobs
            solid_queue_pauses
            solid_queue_processes
            solid_queue_ready_executions
            solid_queue_recurring_executions
            solid_queue_recurring_tasks
            solid_queue_scheduled_executions
            solid_queue_semaphores
          ].freeze
        end

        private

        def parse_file(path)
          content = path.read
          path.extname == '.sql' ? parse_sql_schema(content) : parse_ruby_schema(content)
        end

        def parse_ruby_schema(content)
          content.scan(RUBY_CREATE_TABLE_PATTERN).flatten.compact.uniq
        end

        def parse_sql_schema(content)
          content.scan(SQL_CREATE_TABLE_PATTERN).flatten.compact.uniq
        end

        def tables_in_queue_database
          return [] unless defined?(SolidQueue::Record)

          pool = SolidQueue::Record.connection_pool
          return [] unless pool&.with_connection(&:active?)

          SolidQueue::Record.connection.tables.grep(/\Asolid_queue_/)
        rescue StandardError
          []
        end
      end
    end
  end
end
