require 'capsens/codecom/version'
require 'securerandom'
require 'fileutils'
require 'tempfile'

module Capsens
  module Codecom
    class Runner
      attr_accessor :previous_comment_index

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   initialize
      #   #=> @return Expected returned value
      #
      # @return [Class] Describe what the method should return.
      def initialize
        self.previous_comment_index = -1

        Dir.glob("./**/*.rb").reject { |path| path.include?('spec') }.each do |path|
          temp_file = Tempfile.new(SecureRandom.hex)

          begin
            File.open(path).each_with_index do |line, index|
              if line.strip.start_with?('#')
                previous_comment_index = index
              end

              if line.strip.start_with?('def ')
                temp_file.puts(process_line(line, index))
              end

              temp_file.write line
            end

            temp_file.close
            FileUtils.mv(temp_file.path, path)
          ensure
            temp_file.close
            temp_file.unlink
          end
        end
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   template_options(line)
      #   #=> @return Expected returned value
      #
      # @param line [Class] Write param definition here.
      # @return [Class] Describe what the method should return.
      def template_options(line)
        {
          author_name: extract_author_name.strip,
          method_name: extract_method_name(line),
          params_name: extract_method_arguments(line)
        }
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   extract_method_arguments(line)
      #   #=> @return Expected returned value
      #
      # @param line [Class] Write param definition here.
      # @return [Class] Describe what the method should return.
      def extract_method_arguments(line)
        method = extract_method_name(line)
        if method.include?('(')
          method.scan(/\(([^\)]+)\)/)[0][0].split(',').map(&:strip)
        else
          []
        end
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   extract_author_name
      #   #=> @return Expected returned value
      #
      # @return [Class] Describe what the method should return.
      def extract_author_name
        `git config user.name`
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   extract_method_name(line)
      #   #=> @return Expected returned value
      #
      # @param line [Class] Write param definition here.
      # @return [Class] Describe what the method should return.
      def extract_method_name(line)
        line.strip.split('def ')[1]
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   black_listed_methods
      #   #=> @return Expected returned value
      #
      # @return [Class] Describe what the method should return.
      def black_listed_methods
        [ :initialize, :permitted_params ]
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   process_line(line, index)
      #   #=> @return Expected returned value
      #
      # @param line [Class] Write param definition here.
      # @param index [Class] Write param definition here.
      # @return [Class] Describe what the method should return.
      def process_line(line, index)
        if previous_comment_index == (index - 1)
          self.previous_comment_index = -1
        else
          replaced_template = replace_template(template, template_options(line))
          indent_template(replaced_template, line.index('def '))
        end
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   replace_template(data, options = {})
      #   #=> @return Expected returned value
      #
      # @param data [Class] Write param definition here.
      # @param options = {} [Class] Write param definition here.
      # @return [Class] Describe what the method should return.
      def replace_template(data, options = {})
        data = data.gsub('%{method_name}', options.fetch(:method_name))
        data = data.gsub('%{author_name}', options.fetch(:author_name))

        params = options.fetch(:params_name).map do |param|
          param_template.gsub('%{param}', param)
        end

        params = params.any? ? params.join("\n").prepend("#\n") : '# '
        data.gsub('# %{params}', params)
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   param_template
      #   #=> @return Expected returned value
      #
      # @return [Class] Describe what the method should return.
      def param_template
        "# @param %{param} [Class] Write param definition here."
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   indent_template(template, index)
      #   #=> @return Expected returned value
      #
      # @param template [Class] Write param definition here.
      # @param index [Class] Write param definition here.
      # @return [Class] Describe what the method should return.
      def indent_template(template, index)
        template.strip.split("\n").map(&:strip).map do |slice|
          slice.prepend(' ' * index)
        end.join("\n")
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   template
      #   #=> @return Expected returned value
      #
      # @return [Class] Describe what the method should return.
      def template
        "
        # Describe here what the method should be used for.
        # Remember to add use case examples if possible.
        #
        # @author %{author_name}
        #
        # Examples:
        #
        #   %{method_name}
        #   #=> @return Expected returned value
        # %{params}
        # @return [Class] Describe what the method should return.
        "
      end
    end
  end
end
