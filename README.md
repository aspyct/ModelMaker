ModelMaker
===

This neat tool lets you write simple model definitions, and turns them into state-of-the-art ObjC code.

Installing
---

There are two ways to install this. You can:

1. either install the gem with the standard mechanism: `gem install modelmaker`
2. or build the gem from source and install it.

Usage example
---

Simply create a file named `Model` where you want you model classes to live.

```ruby
project 'MyProject'
class_prefix 'MP'
copyright '2012 MyCompany'

object 'BlogPost' do
    inherits 'NSObject' # Put any superclass here.
    conforms_to 'AnyProtocol' # You may have several of these

    # Currently only these 6 types are supported
    int     :blogPostId
    string  :title
    string  :body
    date    :publicationDate
    set     :tags
    array   :comments
    url     :online
end

object 'Comment' do
    int     :commentId
    string  :body
    string  :author
end

# As you may have noticed, this is ruby
# So you can probably get something interesting out of this :)
```

Now open a command line in the directory where you put this `Model` file, and run

```
$ modelmake
```

A few classes will be generated in the current directory. Among them, `MPBlogPost.h` (in our case). See the [demo directory](https://github.com/aspyct/ModelMaker/tree/master/demo) for a preview.

You'll quickly notice that the properties are read-only. This is intended behavior. Use the builder to create and modify such objects.

**Add custom behavior**

Remember that the files are overwritten each time you do a generate. If you want to add custom methods to these classes, you will probably want to add this in separate categories.

May I use this for commercial projects ?
---

Please do.

Any bug report, suggestion or remark is welcome.

License
---

MIT, meaning you're free to use and share, but there is absolutely no warranty.
Be kind and metion me if you use this software :)

Contact me
---

The name's Antoine
Contact me via mail: a.dotreppe@aspyct.org
