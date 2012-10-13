module EntityMaker
    class Project
        attr_accessor :name, :copyright, :prefix
    end
    
    class Entity
        attr_accessor :name, :superclass, :protocols, :readonly
        
        def initialize(name)
            @name = name
            @properties = {}
            @superclass = 'NSObject'
            @protocols = []
        end
        
        def property(name, type)
            @properties[name] = Property.new(name, type)
        end
        
        def inherits(superclass)
            @superclass = superclass
        end
        
        def conforms_to(protocol)
            @protocols << protocol
        end
        
        alias :p :property
        
        # There was a way to do that better... "define_all" or something
        def string(propname)
            @properties[propname] = StringProperty.new(propname)
        end
        
        def int(propname)
            @properties[propname] = IntegerProperty.new(propname)
        end
        
        def set(propname)
            @properties[propname] = SetProperty.new(propname)
        end
        
        def url(propname)
            @properties[propname] = UrlProperty.new(propname)
        end
        
        def array(propname)
            @properties[propname] = ArrayProperty.new(propname)
        end
        
        def properties
            @properties.values
        end
        
        def needs_init?
            for property in properties do
                if property.needs_init?
                    return true
                end
            end
            
            return false
        end
    end
    
    class Property
        attr_reader :name
        
        def initialize(name)
            @name = name
        end
        
        def internal_type
            type
        end
        
        def exposed_type
            type
        end
        
        def internal_name
            "_#{@name}"
        end
        
        def exposed_name
            @name
        end
        
        def type
            raise "Implement me, or override internal_type and external_type"
        end
        
        def needs_init?
            false
        end
        
        def init_line
            nil
        end
    end
    
    class StringProperty < Property
        def type
            'NSString *'
        end
    end
    
    class IntegerProperty < Property
        def type
            'NSInteger'
        end
    end
    
    class UrlProperty < Property
        def type
            'NSURL *'
        end
    end
    
    class SetProperty < Property
        def internal_type
            'NSMutableSet *'
        end
        
        def exposed_type
            'NSSet *'
        end
        
        def needs_init?
            true
        end
        
        def init_line
            "#{internal_name} = [[NSMutableSet alloc] init];"
        end
    end
    
    class ArrayProperty < Property
        def internal_type
            'NSMutableArray *'
        end
        
        def exposed_type
            'NSArray *'
        end
        
        def needs_init?
            true
        end
        
        def init_line
            "#{internal_name} = [[NSMutableArray alloc] init];";
        end
    end
    
    class Maestro
        @entities = []
        @project = Project.new()
        
        def self.new_entity(name, &configuration)
            entity = Entity.new(name)
            entity.instance_eval &configuration
            @entities << entity
        end
        
        def self.current_entity
            @entities.last
        end
        
        def self.entities
            @entities
        end
        
        def self.project
            @project
        end
    end
end

def object(name, &configuration)
    EntityMaker::Maestro.new_entity(name, &configuration)
end

def project(&configuration)
    EntityMaker::Maestro.project.instance_exec &configuration
end

# Here come the definitions

project {
    @name = 'HowTo'
    @prefix = 'HT'
    @copyright = '2012 Antoine d\'Otreppe'
}

object "HowToItem" do
    inherits 'UITableView'
    conforms_to 'UITableViewDelegate'
    
    int     :id
    string  :title
    string  :author
    url     :image
    string  :description
    int     :score
    set     :tags
    array   :comments
end


# end of definitions

require 'erb'

class TemplateVars
    attr_accessor :entity, :project
    
    def get_binding
        binding
    end
end

for file in ['header.erb', 'implementation.erb'] do
    entities = EntityMaker::Maestro.entities
    template = File.new(file).read
    renderer = ERB.new(template, 0, '>')

    for entity in entities do
        vars = TemplateVars.new
        vars.project = EntityMaker::Maestro.project
        vars.entity = entity
        puts renderer.result(vars.get_binding)
    end
end
