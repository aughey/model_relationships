# ModelRelationships

class ModelDrawer
  def self.draw
    yield self.new
  end

  def define(model,options)
    return if model.are_relationships_set?
    for k,v in (options || { })
      case k
      when :children :
        for child in v
          raise "You must use symbol names in Model Relationship defintions (child #{child})" unless child.is_a?(Symbol)

          # puts "Defining #{model} has children of type #{child}"
          model.send(:has_children,child.to_s.tableize.to_sym)
          child.to_s.constantize.send(:my_parent,model.to_s.tableize.singularize.to_sym)
        end
      end
    end
    model.send(:has_children,:notes)
    model.send(:acts_as_taggable)
    model.send(:searchable)
  end
end

class ModelRelationships
  def self.define(*relationships)
    @relationships = relationships
    ModelReloadChecker.reloaded(false)
    self.create_dot
#    ModelRelationships.do_reload(self)
  end

  def self.create_dot
    File.open("schema.dot","w") do |f|
      f.puts "digraph Schema {"
      for r in @relationships
        parent = r[0]
        puts parent
        options = r[1] || { }

        for c in (options[:children] || {})
          f.puts "#{parent} -> #{c}"
        end
      end
      f.puts "}"
    end
    system("dot -opublic/schema.png -Tpng schema.dot")
  end


  def self.do_reload(other)
    return unless @relationships
    return unless ModelReloadChecker.needs_reloading?

    ModelReloadChecker.reloaded

    ModelDrawer.draw do |m|
      for r in @relationships
        raise "You must use symbol names in Model Relationship defintions (#{r})" unless r[0].is_a?(Symbol)
        m.define r[0].to_s.constantize, r[1]
      end
    end

  end

end

