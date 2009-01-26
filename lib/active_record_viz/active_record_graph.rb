module ActiveRecordViz 
  class ActiveRecordGraph
    def self.generate(opts = {})

      if opts[:file].nil?
        graph_file = StringIO.new("", "w")
        return_graph_as_string = true
      else
        graph_file = opts[:file]
        return_graph_as_string = false
      end      
      show_column_names = opts[:show_columns]
      
      polymorphic_entities = {} #Holds names of abstract associations which have no real AR object

      graph_file.puts "digraph x {"
      
      #Go through each AR class and read its meta data
      #FIXME - is there any way other than the filesystem to do this?
      Dir.glob("#{RAILS_ROOT}/app/models/*rb") do |f|
        f.match(/\/([a-z_]+).rb/)
        classname = $1.camelize
        klass = Kernel.const_get classname
        if klass.superclass == ActiveRecord::Base 

          if show_column_names
            graph_file.puts "#{classname} [label=\"#{classname}\\n\\n#{klass.column_names.join('\n')}\"]"
          else
            graph_file.puts classname
          end

          klass.reflect_on_all_associations.each do |a|
            unless a.options[:through]
              if a.macro == :has_many || a.macro == :has_one
                if a.options[:class_name]
                  graph_file.puts "#{classname} -> #{a.options[:class_name]} [label=\"#{a.macro}\\n(#{a.name})\"]"
                else
                  graph_file.puts "#{classname} -> #{a.name.to_s.camelize.singularize} [label=\"#{a.macro}\"]"
                end
              end
              if a.macro == :belongs_to
                unless a.options[:polymorphic].blank?
                  graph_file.puts "#{classname} -> #{a.name.to_s.camelize.singularize} [label=\"#{a.macro}\"]"
                  polymorphic_entities[a.name.to_s.camelize.singularize] = true
                end
              end
            end
          end
          
        end
      end
      
      #Write out Abstract entities
      polymorphic_entities.keys.each do |key|
        graph_file.puts key
      end
      
      #Write end of file
      graph_file.puts "}"

      #Return it if we want a string
      return return_graph_as_string ? graph_file.string : graph_file
    end
  end
end
