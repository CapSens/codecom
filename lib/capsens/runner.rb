require 'yaml'
require 'ostruct'

module Capsens
  module Codecom
    class Runner
      attr_accessor :configuration

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
          author_name: extract_author_name,
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
        `git config user.name`.strip
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   extract_git_revision
      #   #=> @return Expected returned value
      #
      # @return [Class] Describe what the method should return.
      def extract_git_revision
        path = File.expand_path('../..', File.dirname(__FILE__))
        `git --git-dir #{path}/.git rev-parse --short HEAD`.strip
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
      #   extract_method_name_without_arguments(line)
      #   #=> @return Expected returned value
      #
      # @param line [Class] Write param definition here.
      # @return [Class] Describe what the method should return.
      def extract_method_name_without_arguments(line)
        name = extract_method_name(line)
        name.include?('(') ? name.split('(')[0] : name.split(' ')[0]
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
        method_name = template_options(line).fetch(:method_name)

        unless ignored_methods.include?(method_name.to_sym)
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
        end.join("\n") + "\n"
      end

      def initialize(force = false)
        process_configuration
        process_comments
        process_rspecs
      end

      def process_configuration
        self.configuration = YAML::load(File.read('.codecom.yml'))
      end

      def process_comments
        started_path    = configuration['comments']['started_path']
        ignored_paths   = configuration['comments']['ignored_paths']
        ignored_methods = configuration['comments']['ignored_methods']

        find_files_without(started_path, ignored_paths).each do |path|
          comments = []
          temp_file = Tempfile.new(SecureRandom.hex)

          begin
            File.open(path).each_with_index do |line, index|
              if line.strip.start_with?('#')
                comments.push(line)
              else
                if line.strip.start_with?('def ')
                  method_name = extract_method_name_without_arguments(line).to_sym

                  condition_0 = force || comments.none?
                  condition_1 = !ignored_methods.include?(method_name)

                  data = (condition_0 && condition_1) ? process_line(line, index) : comments.join
                  temp_file.print(data)
                else
                  temp_file.print(comments.join)
                end

                comments = []
                temp_file.write line
              end
            end

            temp_file.print(comments.join)
            temp_file.close
            FileUtils.mv(temp_file.path, path)
          ensure
            temp_file.close
            temp_file.unlink
          end
        end
      end

      def find_files_without(started_path, ignored_paths)
        files_paths = Dir.glob("./#{started_path}/**/*.rb")
        files_paths.select do |file_path|
          ignored_paths.map do |path|
            file_path.include?(path)
          end.none?
        end
      end

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   template(template_name = 'template.txt')
      #   #=> @return Expected returned value
      #
      # @param template_name = 'template.txt' [Class] Write param definition here.
      # @return [Class] Describe what the method should return.
      def template(template_name = 'template.txt')
        File.read([File.dirname(__FILE__), template_name].join('/'))
      end
    end
  end
end
