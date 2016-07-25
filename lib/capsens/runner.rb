module Capsens
  module Codecom
    class Runner
      attr_accessor :ignored_methods

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   initialize(force = false)
      #   #=> @return Expected returned value
      #
      # @param force = false [Class] Write param definition here.
      # @return [Class] Describe what the method should return.
      def initialize(force = false)
        self.ignored_methods = [ :initialize, :permitted_params ]

        Dir.glob("./**/*.rb").reject { |path| path.include?('app') }.each do |path|
          comments = []
          temp_file = Tempfile.new(SecureRandom.hex)

          begin
            File.open(path).each_with_index do |line, index|
              if line.strip.start_with?('#')
                comments.push(line)
              else
                if line.strip.start_with?('def ')
                  condition_0 = force || comments.none?
                  condition_1 = ignored_methods.include?(extract_method_name(line).to_sym)

                  if condition_0 && !condition_1
                    temp_file.print(process_line(line, index))
                  else
                    temp_file.print(comments.join)
                  end
                else
                  comments = []
                end

                temp_file.write line
              end
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
      #   process_line(line, index)
      #   #=> @return Expected returned value
      #
      # @param line [Class] Write param definition here.
      # @param index [Class] Write param definition here.
      # @return [Class] Describe what the method should return.
      def process_line(line, index)
        method_name = template_options(line).fetch(:method_name)

        unless ignored_methods.include?(method_name.to_sym)
          options = [template, template_options(line)]
          replaced_template = replace_template(*options)
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