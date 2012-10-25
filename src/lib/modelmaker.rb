#!/usr/bin/env ruby

require 'erb'

module ModelMaker
    class Project
        attr_accessor :name, :copyright, :class_prefix, :entities
        
        def initialize
            @entities = []
        end
        
        def add_entity(entity)
            entity.project = self
            @entities << entity
        end
    end
    
    class ProjectBuilder
        def initialize(project)
            @project = project
        end
        
        def project(name)
            @project.name = name
        end
        
        def class_prefix(prefix)
            @project.class_prefix = prefix
        end
        
        def copyright(copyright)
            @project.copyright = copyright
        end
        
        def object(name, &configuration)
            builder = EntityBuilder.new(name, &configuration)
            @project.add_entity(builder.entity)
        end
    end
    
    class EntityBuilder
        attr_reader :entity
        
        def initialize(entity_name, &configuration)
            @entity = Entity.new(entity_name)
            instance_eval(&configuration)
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
        
        def array(*args)
            add_property(ArrayProperty.new(*args))
        end
        
        def date(propname)
            add_property(DateProperty.new(propname))
        end
        
        def id(propname, cls)
            add_property(IdProperty.new(propname, cls))
        end
        
        def add_property(property)
            @entity.add_property(property)
        end
    end
    
    class Entity
        attr_reader :name
        attr_accessor :superclass, :protocols, :project
        
        def initialize(name)
            @name = name
            
            @superclass = 'NSObject'
            @properties = {}
            @protocols = []
        end
        
        def short_name
            @name
        end
        
        def project=(project)
            @project = project
            
            for property in properties do
                property.project = project
            end
        end
        
        def class_name
            if @project
                "#{@project.class_prefix}#{@name}"
            else
                @name
            end
        end
        
        def mutable_class
            if @project
                "#{@project.class_prefix}Mutable#{@name}"
            else
                "Mutable#{@name}"
            end
        end
        
        alias :name :class_name
        
        def instance_name
            name = @name.clone
            name[0] = name[0].downcase
            name
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
        attr_accessor :project
        
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
        
        def assignation_value
            exposed_name
        end
        
        def comment_line
            nil
        end
        
        def make_classname(type)
            # If we're linked to a project and class has no prefix
            if project and not type =~ /^[A-Z]{3}/
                "#{project.class_prefix}#{type} *"
            else
                "#{type} *"
            end
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
    
    class DateProperty < Property
        def type
            'NSDate *'
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
            "#{internal_name} = [[NSMutableSet alloc] init]"
        end
        
        def assignation_value
            "[[NSMutableSet alloc] initWithSet:#{exposed_name}]"
        end
    end
    
    class ArrayProperty < Property
        def initialize(name, type=nil)
            super(name)
            
            @type = type
        end
        
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
            "#{internal_name} = [[NSMutableArray alloc] init]";
        end
        
        def assignation_value
            "[[NSMutableArray alloc] initWithArray:#{exposed_name}]"
        end
        
        def comment_line
            if @type
                "Array of #{make_classname(@type)}"
            else
                nil
            end
        end
    end
    
    class IdProperty < Property
        def initialize(name, cls)
            super(name)
            
            @cls = cls
        end
        
        def type
            make_classname(@cls)
        end
    end
    
    class DefaultRunner
        attr_accessor :pathname
        
        def initialize
            @pathname = 'Model' # Look for a file 'Model' in this directory
        end
        
        def run
            if not File.exists?(@pathname)
                raise 'No "Model" file found in the current directory'
            end
            
            project = Project.new()
            source = File.new(@pathname).read()
            
            builder = ProjectBuilder.new(project)
            builder.instance_eval(source, @pathname, 1)

            generator = Source::Generator.new(project)
            generator.generate()
        end
    end

    module Source
        class Generator
            def initialize(project)
                @project = project
            end
            
            def generate(target_directory='.')
                for cls in renderers do
                    renderer = cls.new()
                    
                    for entity in @project.entities
                        vars = TemplateVars.new()
                        vars.project = @project
                        vars.entity = entity
                        
                        filename = renderer.generated_file(vars)
                        puts "Generating #{filename}"
                        fullpath = File.join(target_directory, filename)
                        fhandle = File.new(fullpath, 'w')
                        fhandle.write(renderer.result(vars))
                    end
                end
            end
            
            def renderers
                [
                    HeaderRenderer,
                    ImplementationRenderer,
                    MutableHeaderRenderer,
                    MutableImplementationRenderer
                ]
            end
        end
        
        class TemplateVars
            attr_accessor :entity, :project, :file
            
            def get_binding
                binding
            end
        end
        
        class BaseRenderer
            def template_file
                raise 'Implement me'
            end
            
            def generated_file(template_vars)
                raise 'Implement me'
            end
            
            def result(template_vars)
                renderer.result(template_vars.get_binding)
            end
            
            def renderer
                if not @renderer
                    mydir = File.dirname(__FILE__)
                    template_path = File.join(mydir, '../templates', template_file)
                    template = File.new(template_path).read()
                    @renderer = ERB.new(template, 0, '>')
                end
                
                @renderer
            end
        end
        
        class HeaderRenderer < BaseRenderer
            def template_file
                'header.erb'
            end
            
            def generated_file(template_vars)
                "#{template_vars.entity.class_name}.h"
            end
        end
        
        class ImplementationRenderer < BaseRenderer
            def template_file
                'implementation.erb'
            end
            
            def generated_file(template_vars)
                "#{template_vars.entity.class_name}.m"
            end
        end
        
        class MutableHeaderRenderer < BaseRenderer
            def template_file
                'mutable_header.erb'
            end
            
            def generated_file(template_vars)
                "#{template_vars.entity.mutable_class}.h"
            end
        end
        
        class MutableImplementationRenderer < BaseRenderer
            def template_file
                'mutable_implementation.erb'
            end
            
            def generated_file(template_vars)
                "#{template_vars.entity.mutable_class}.m"
            end
        end
        
        class FileInfo
            attr_accessor :pathname
        end
    end
end
