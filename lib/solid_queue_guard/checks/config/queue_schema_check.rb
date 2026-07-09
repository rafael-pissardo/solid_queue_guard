# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class QueueSchemaCheck < Base
        def call
          evaluation = evaluate_schema

          case evaluation[:status]
          when :pass
            pass(check_id, evaluation[:message], metadata: evaluation[:metadata])
          when :warn
            warn(
              check_id,
              evaluation[:message],
              suggestion: evaluation[:suggestion],
              metadata: evaluation[:metadata]
            )
          else
            failure(
              check_id,
              evaluation[:message],
              suggestion: evaluation[:suggestion],
              metadata: evaluation[:metadata]
            )
          end
        end

        private

        def evaluate_schema
          required = Schema::SolidQueueTables.required_tables
          detection = Schema::SolidQueueTables.detected_tables(rails_root: rails_root)
          missing = required - detection[:tables]
          metadata = schema_metadata(detection, missing: missing)

          return pass_evaluation(detection, required.size, metadata) if missing.empty?
          return partial_evaluation(missing, metadata) if detection[:tables].any?

          empty_evaluation(metadata)
        end

        def pass_evaluation(detection, table_count, metadata)
          {
            status: :pass,
            message: success_message(detection, table_count),
            metadata: metadata
          }
        end

        def partial_evaluation(missing, metadata)
          {
            status: :warn,
            message: "Missing Solid Queue tables: #{missing.join(', ')}",
            suggestion: 'Run bin/rails solid_queue:install or migrate the queue database',
            metadata: metadata
          }
        end

        def empty_evaluation(metadata)
          {
            status: :fail,
            message: [
              'No Solid Queue schema tables found in',
              'db/queue_schema.rb, db/schema.rb, db/structure.sql, or the queue database'
            ].join(' '),
            suggestion: 'Run bin/rails solid_queue:install and migrate the queue database',
            metadata: metadata
          }
        end

        def success_message(detection, table_count)
          sources = source_descriptions(detection)
          "Solid Queue schema complete (#{table_count}/#{table_count} tables) in #{sources.join(', ')}"
        end

        def source_descriptions(detection)
          sources = detection[:file_tables].keys
          sources << 'queue database' if detection[:database_tables].any?
          sources.presence || ['schema files']
        end

        def schema_metadata(detection, missing:)
          {
            required_tables: Schema::SolidQueueTables.required_tables,
            detected_tables: detection[:tables],
            missing_tables: missing,
            schema_sources: detection[:file_tables],
            database_tables: detection[:database_tables]
          }
        end
      end
    end
  end
end
