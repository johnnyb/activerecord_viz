namespace :arviz do
  namespace :argraph do
    task :create => :environment do
      ar_graph = File.open("#{RAILS_ROOT}/db/argraph.dot", "w")
      ActiveRecordViz::ActiveRecordGraph.generate(:file => ar_graph, :show_columns => false)
      ar_graph.close
    end
  end
end
