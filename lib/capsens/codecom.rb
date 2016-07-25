require 'capsens/codecom/version'
require 'securerandom'
require 'fileutils'
require 'tempfile'

module Capsens
  module Codecom
    class Runner
      attr_accessor :previous_comment_index


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

        {
          author_name: extract_author_name,
          method_name: extract_method_name(line),
          params_name: extract_method_arguments(line)
        }
      end

      def extract_method_arguments(line)
        method = extract_method_name(line)
        if method.include?('(')
          method.scan(/\(([^\)]+)\)/)[0][0].split(',').map(&:strip)
        else
          []
        end
      end

      def extract_author_name
        `git config user.name`.strip
      end

      def extract_git_revision
        `git --git-dir #{File.expand_path('../..', File.dirname(__FILE__))}/.git rev-parse --short HEAD`.strip
      end

      def extract_method_name(line)
        line.strip.split('def ')[1]
      end

      def black_listed_methods
        [ :initialize, :permitted_params ]
      end

      def process_line(line, index)
        if previous_comment_index == (index - 1)
          self.previous_comment_index = -1
        else
          replaced_template = replace_template(template, template_options(line))
          indent_template(replaced_template, line.index('def '))
        end
      end

      def replace_template(data, options = {})
        data = data.gsub('%{method_name}', options.fetch(:method_name))
        data = data.gsub('%{author_name}', options.fetch(:author_name))

        params = options.fetch(:params_name).map do |param|
          param_template.gsub('%{param}', param)
        end

        params = params.any? ? params.join("\n").prepend("#\n") : '# '
        data.gsub('# %{params}', params)
      end

      def param_template
        "# @param %{param} [Class] Write param definition here."
      end

      def indent_template(template, index)
        template.strip.split("\n").map(&:strip).map do |slice|
          slice.prepend(' ' * index)
        end.join("\n")
      end

      def template
        "
        # @engine capsens-codecom
        # @commit #{extract_git_revision}
        #
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
