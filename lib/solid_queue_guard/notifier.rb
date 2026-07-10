# frozen_string_literal: true

module SolidQueueGuard
  # @api private
  class Notifier
    class << self
      def deliver_all(report, adapters: SolidQueueGuard.config.notify_with)
        Array(adapters).each do |adapter|
          deliver(adapter, report)
        end
      end

      def deliver(adapter, report)
        case adapter.to_sym
        when :slack then deliver_slack(report)
        when :datadog then deliver_datadog(report)
        when :webhook then deliver_webhook(report)
        else deliver_rails_logger(report)
        end
      end

      def post_json(url, payload, headers: {})
        require 'net/http'
        uri = URI(url)
        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        headers.each { |key, value| request[key] = value }
        request.body = JSON.generate(payload)
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(request)
        end
      end

      private

      def deliver_rails_logger(report)
        Rails.logger.warn("[SolidQueueGuard] status=#{report.status} warnings=#{report.warnings.join('; ')}")
      end

      def deliver_slack(report)
        webhook_url = ENV.fetch('SOLID_QUEUE_GUARD_SLACK_WEBHOOK_URL', nil)
        return if webhook_url.blank?

        post_json(webhook_url, { text: "SolidQueueGuard status: *#{report.status}*\n#{report.warnings.join("\n")}" })
      end

      def deliver_datadog(report)
        api_key = ENV.fetch('DD_API_KEY', nil)
        return if api_key.blank?

        alert_type = case report.status
                     when :unhealthy then 'error'
                     when :degraded then 'warning'
                     else 'info'
                     end

        post_json(
          'https://api.datadoghq.com/api/v1/events',
          {
            title: 'SolidQueueGuard alert',
            text: report.warnings.join("\n"),
            alert_type: alert_type,
            tags: ["status:#{report.status}"]
          },
          headers: { 'DD-API-KEY' => api_key }
        )
      end

      def deliver_webhook(report)
        webhook_url = ENV.fetch('SOLID_QUEUE_GUARD_WEBHOOK_URL', nil)
        return if webhook_url.blank?

        post_json(webhook_url, report.to_h)
      end
    end
  end
end
