namespace :slices do
  namespace :gluttonberg do
    desc "Regenerate list positions for all Classes using DragTree"
    task :repair_drag_trees => :merb_env do
      Gluttonberg::DragTree::ModelTracker.class_list.each do |model_class|
        p "Repairing DragTree lists for #{model_class.name.to_s}"
        model_class.repair_list
      end
    end
  end
end