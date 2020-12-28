require 'json'

require_relative './email_address'

module Amply
  module Helpers
    class Email
      def initialize(data)
        @data = data
        @request_data = {}
      end

      def parsed_data
        unless @data.is_a?(Hash)
          raise 'Expecting hash for email data'
        end

        data_sym = JSON.parse(JSON.dump(@data), symbolize_names: true)

        set_from(data_sym[:from])
        set_subject(data_sym[:subject])
        set_text(data_sym[:text])
        set_html(data_sym[:html])
        set_content(data_sym[:content])
        set_reply_to(data_sym[:reply_to])
        set_template(data_sym[:template])
        set_dynamic_template_data(data_sym[:dynamic_template_data])
        set_unsubscribe_group_uuid(data_sym[:unsubscribe_group_uuid])
        set_ip_or_pool_uuid(data_sym[:ip_or_pool_uuid])
        set_attachments(data_sym[:attachments])
        set_headers(data_sym[:headers])
        set_categories(data_sym[:categories])
        set_clicktracking(data_sym[:clicktracking])
        set_substitutions(data_sym[:substitutions])

        if data_sym[:personalizations].nil?
          set_personalizations_from_to(data_sym[:to], data_sym[:cc], data_sym[:bcc])
        else
          set_personalizations(data_sym[:personalizations])
        end

        @request_data
      end

      private

      def set_from(from)
        return if from.nil?
        @request_data[:from] = format_emails(from)[0]
      end

      def set_subject(subject)
        unless subject.is_a?(String)
          raise 'String expected for `subject`'
        end

        @request_data[:subject] = subject
      end

      def set_text(text)
        return if text.nil?

        @request_data[:content] ||= []
        @request_data[:content].push(type: 'text/plain', value: text)
      end

      def set_html(html)
        return if html.nil?

        @request_data[:content] ||= []
        @request_data[:content].push(type: 'text/html', value: html)
      end

      def set_content(content)
        return if content.nil?

        unless content.is_a?(Array)
          raise 'Array expected for `content`'
        end

        @request_data[:content] ||= []

        content.each_with_index do |part, i|
          unless part.is_a?(Hash)
            raise "Hash expected for `content[#{i}]`"
          end

          type = part[:type] || part['type']
          value = part[:value] || part['value']

          if type.nil?
            raise "`type` must be defined for `content[#{i}][type]`"
          end

          if value.nil?
            raise "`value` must be defined for `content[#{i}][type]`"
          end

          @request_data[:content].push(type: type, value: value)
        end
      end

      def set_reply_to(reply_to)
        return if reply_to.nil?
        @request_data[:reply_to] = format_emails(reply_to)[0]
      end

      def set_template(template)
        return if template.nil?
        @request_data[:template] = template
      end

      def set_dynamic_template_data(dynamic_template_data)
        return if dynamic_template_data.nil?

        unless dynamic_template_data.is_a?(Hash)
          raise 'Hash expected for `dynamic_template_data`'
        end

        @request_data[:substitutions] ||= {}

        dynamic_template_data.each do |sub_from, sub_to|
          @request_data[:substitutions]["${#{sub_from}}"] = sub_to.to_s
        end
      end

      def set_unsubscribe_group_uuid(unsubscribe_group_uuid)
        return if unsubscribe_group_uuid.nil?
        @request_data[:unsubscribe_group_uuid] = unsubscribe_group_uuid
      end

      def set_ip_or_pool_uuid(ip_or_pool_uuid)
        return if ip_or_pool_uuid.nil?
        @request_data[:ip_or_pool_uuid] = ip_or_pool_uuid
      end

      def set_attachments(attachments)
        return if attachments.nil?

        unless attachments.is_a?(Array)
          raise 'Array expected for `attachments`'
        end

        @request_data[:attachments] ||= []

        attachments.each_with_index do |attachment, i|
          unless attachment.is_a?(Hash)
            raise "Hash expected for `attachments[#{i}]`"
          end

          content     = attachment[:content] || attachment['content']
          filename    = attachment[:filename] || attachment['filename']
          type        = attachment[:type] || attachment['type']
          disposition = attachment[:disposition] || attachment['disposition']

          if content.nil?
            raise "`content` must be defined for `attachments[#{i}][content]`"
          end

          if filename.nil?
            raise "`filename` must be defined for `attachments[#{i}][filename]`"
          end

          data = { content: content, filename: filename }
          data.merge!(type: type) unless type.nil?
          data.merge!(disposition: disposition) unless disposition.nil?

          @request_data[:attachments].push(data)
        end
      end

      def set_headers(headers)
        return if headers.nil?

        unless headers.is_a?(Hash)
          raise 'Hash expected for `headers`'
        end

        @request_data[:headers] ||= {}

        headers.each do |name, value|
          @request_data[:headers][name] = value.to_s
        end
      end

      def set_categories(categories)
        return if categories.nil?

        unless categories.is_a?(Array)
          raise 'Array expected for `categories`'
        end

        @request_data[:analytics] ||= {}
        @request_data[:analytics][:categories] = categories.map { |category| category.to_s }
      end

      def set_clicktracking(clicktracking)
        return if clicktracking.nil?

        unless [TrueClass, FalseClass].include?(clicktracking.class)
          raise 'Expecting TrueClass or FalseClass for `clicktracking`'
        end

        @request_data[:analytics] ||= {}
        @request_data[:analytics][:clicktracking] = clicktracking
      end

      def set_substitutions(substitutions)
        return if substitutions.nil?

        unless substitutions.is_a?(Hash)
          raise 'Hash expected for `substitutions`'
        end

        @request_data[:substitutions] ||= {}

        substitutions.each do |sub_from, sub_to|
          @request_data[:substitutions][sub_from] = sub_to.to_s
        end
      end

      def set_personalizations_from_to(to, cc, bcc)
        @request_data[:personalizations] = [{}]

        if to.nil? && cc.nil? && bcc.nil?
          raise 'Provide at least one of `to`, `cc` or `bcc`'
        end

        @request_data[:personalizations][0][:to] = format_emails(to) unless to.nil?
        @request_data[:personalizations][0][:cc] = format_emails(cc) unless cc.nil?
        @request_data[:personalizations][0][:bcc] = format_emails(bcc) unless bcc.nil?
      end

      def set_personalizations(personalizations)
        @request_data[:personalizations] = personalizations
      end

      def format_emails(emails)
        if emails.is_a?(Array)
          return emails.map { |email| EmailAddress.new(email).to_json }
        end

        [EmailAddress.new(emails).to_json]
      end
    end
  end
end
