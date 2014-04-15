module OpenStax::Connect
  class ActionList

    def initialize(options={})
      @options = options

      raise IllegalArgument, "must supply data procs" if options[:data_procs].nil?

      if options[:headings].present? && options[:data_procs].size != options[:headings].size
        raise IllegalArgument, "if you supply headings, you must supply one for each column"
      end

      if options[:widths].present? && options[:data_procs].size != options[:widths].size
        raise IllegalArgument, "if you supply widths, you must supply one for each column"
      end

    end

    def num_columns
      @options[:data_procs].size
    end

    def has_headings?
      @options[:headings].present?
    end

    def get_heading(column)
      @options[:headings].nil? ? nil : @options[:headings][column]
    end

    def get_width(column)
      @options[:widths].nil? ? nil : @options[:widths][column]
    end

    def get_data(column, *args)
      @options[:data_procs][column].call(*args)
    end

  end
end