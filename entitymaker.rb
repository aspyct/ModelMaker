module EntityMaker
    require 'mustache'
    
    class Entities
        def self.new_entity(name)
            if @entities.nil?
                @entities = []
            end
            
            @entities << Entity.new(name)
        end
        
        def self.current_entity
            @entities.last
        end
        
        def self.entities
            @entities
        end
    end
    
    class Entity
        def initialize(name)
            @name = name
            @properties = {}
        end
        
        def add_property(name, type)
            @properties[name] = Property.new(name, type)
            puts "New property #{name} of type #{type}"
        end
        
        def properties
            @properties.values
        end
        
        def name
            @name
        end
        
        def to_liquid
            'liquid'
        end
    end
    
    class Property
        attr_accessor :name, :type
        
        def initialize(name, type)
            @name = name
            @type = type
        end
        
        def internal_type
            case @type
            when :string    then 'NSString *'
            when :int       then 'NSInteger '
            when :url       then 'NSMutableURL *'
            when :set       then 'NSMutableSet *'
            when :array     then 'NSMutableArray *'
            end
        end
        
        def exposed_type
            case @type
            when :string    then 'NSString *'
            when :int       then 'NSInteger '
            when :url       then 'NSURL *'
            when :set       then 'NSSet *'
            when :array     then 'NSArray *'
            end
        end
        
        def internal_name
            "_#{@name}"
        end
        
        def exposed_name
            @name
        end
    end
end

def object(name)
    EntityMaker::Entities.new_entity(name)
    yield
end

def property(type, name)
    EntityMaker::Entities.current_entity.add_property(name, type)
end

object 'HowTo' do
    property :string, 'title'
    property :int, 'howToId'
    property :string, 'author'
    property :url, 'image'
    property :string, 'description'
    property :int, 'score'
    property :set, 'tags'
end

require 'erb'

class TemplateVars
    attr_accessor :entity, :prefix
    
    def get_binding
        binding
    end
end

entities = EntityMaker::Entities.entities
template = File.new('header.erb').read
renderer = ERB.new(template, 0, '>')

for entity in entities do
    vars = TemplateVars.new
    vars.entity = entity
    vars.prefix = 'AP'
    puts renderer.result(vars.get_binding)
end
