# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class TopologyRecommendationCheck < Base
        def call
          recommendations = Recommendations::Topology.analyze

          if recommendations.empty?
            pass('topology_recommendation', 'No queue.yml topology changes recommended')
          else
            warn(
              'topology_recommendation',
              recommendations.join('; '),
              suggestion: 'Review config/queue.yml worker and database pool settings',
              metadata: { recommendations: recommendations }
            )
          end
        end
      end
    end
  end
end
