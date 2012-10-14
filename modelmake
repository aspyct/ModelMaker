module ModelMaker
    class Project
        attr_reader :codename, :copyright_notice, :prefix
        
        def name(name)
            @codename = name
        end
        
        def class_prefix(prefix)
            @prefix = prefix
        end
        
        def copyright(copyright)
            @copyright_notice = copyright
        end
    end
    
    class EntityBuilder
        attr_reader :entity
        
        def initialize(entity_name)
            @entity = Entity.new(entity_name)
        end
        
        def inherits(superclass)
            @entity.superclass = superclass
        end
        
        def conforms_to(protocol)
            @entity.protocols << protocol
        end
        
        # There was a way to do that better... "define_all" or something
        def string(propname)
            add_property(StringProperty.new(propname))
        end
        
        def int(propname)
            add_property(IntegerProperty.new(propname))
        end
        
        def set(propname)
            add_property(SetProperty.new(propname))
        end
        
        def url(propname)
            add_property(UrlProperty.new(propname))
        end
        
        def array(propname)
            add_property(ArrayProperty.new(propname))
        end
        
        def add_property(property)
            @entity.add_property(property)
        end
    end
    
    class Entity
        attr_accessor :name, :superclass, :protocols
        
        def initialize(name)
            @name = name
            @superclass = 'NSObject'
            @properties = {}
            @protocols = []
        end
        
        def add_property(property)
            @properties[property.name] = property
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
    
    class FileExecuter
        pathname = 'Model' # Look for a file 'Model' in this directory
    end
    
    class Maestro
        @entities = []
        @project = Project.new()
        
        def self.new_entity(name, &configuration)
            builder = EntityBuilder.new(name)
            builder.instance_eval &configuration
            @entities << builder.entity
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

def project(&configuration)
    ModelMaker::Maestro.project.instance_exec &configuration
end

def object(name, &configuration)
    ModelMaker::Maestro.new_entity(name, &configuration)
end

# Here come the definitions

project {
    name 'HowTo'
    class_prefix 'HT'
    copyright '2012 Antoine d\'Otreppe'
}

object "HowToItem" do
    inherits 'UITableView'
    conforms_to 'UITableViewDelegate'
    conforms_to 'UITableViewDataSource'
    
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
    entities = ModelMaker::Maestro.entities
    template = File.new(file).read
    renderer = ERB.new(template, 0, '>')

    for entity in entities do
        vars = TemplateVars.new
        vars.project = ModelMaker::Maestro.project
        vars.entity = entity
        puts renderer.result(vars.get_binding)
    end
end
