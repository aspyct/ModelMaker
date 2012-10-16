Gem::Specification.new do |s|
    s.name = 'ModelMaker'
    s.version = '0.1.0'
    s.date = '2012-10-16'
    s.summary = 'Objective-C model class generator'
    s.description = 'ModelMaker generates your model classes based on a simple ruby ' \
                    'definition. '
    s.authors = ["Antoine d'Otreppe"]
    s.email = 'a.dotreppe@aspyct.org'
    
    s.files = Dir['src/templates/*'] + ['src/bin/modelmake', 'src/lib/modelmaker.rb']
    s.require_path = 'src/lib'
    
    s.bindir = 'src/bin'
    s.executables = ['modelmake']
    s.default_executable = 'modelmake'
    
    s.homepage = 'https://github.com/aspyct/ModelMaker'
    s.license = 'MIT'
end