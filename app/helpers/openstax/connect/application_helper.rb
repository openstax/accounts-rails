module OpenStax
  module Connect
    module ApplicationHelper

      def unless_errors(options={}, &block)
        options[:errors] ||= @handler_result.errors
        options[:errors_html_id] ||= OpenStax::Connect.configuration.default_errors_html_id
        options[:errors_partial] ||= OpenStax::Connect.configuration.default_errors_partial
        options[:trigger] ||= OpenStax::Connect.configuration.default_errors_added_trigger

        if options[:errors].any? || flash[:alert]
          "$('##{options[:errors_html_id]}').html('#{ j(render options[:errors_partial], errors: options[:errors]) }').trigger('#{options[:trigger]}');".html_safe
        else
          ("$('##{options[:errors_html_id]}').html('');" + capture(&block)).html_safe
        end
      end

    end
  end
end
