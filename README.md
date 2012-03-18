Protocolist
===========

Simple and flexible Activity feeds solution for Rails applications.

Installation
------------

Add the gem to your Gemfile and run the `bundle install` command to install it.

```ruby
gem "protocolist"
```

Run the generator to create Activity model and migration.

```ruby
rails generate protocolist:install
```

Run migration then:

```ruby
rake db:migrate
```

Getting started
---------------

Activity model has four attributes: subject("who did it"), type("what
they did"), object("what they did it to") and data(additional information). Subject will be
set as current user by default.

Protocolist expects you to have `current_user` action in a controller.
̶S̶e̶e̶ ̶C̶h̶a̶n̶g̶i̶n̶g̶ ̶D̶e̶f̶a̶u̶l̶t̶s̶ ̶t̶o̶ ̶c̶h̶a̶n̶g̶e̶ ̶t̶h̶i̶s̶ ̶b̶e̶h̶a̶v̶i̶o̶r̶.̶

Usage in models
---------------

The simplest way is just to write inside your model.

```ruby
fires :create
```

And when create event will be triggered,  it will automatically create
Action model with current user set as subject, `:create` as type,
`self` as object and empty data.

The more convenient usage:

```ruby
fires :edit, :on => :update,
             :data => :changes,
             :if => 'changes.any?'
```

The event type will be `edit`. A proc, symbol a̶n̶d̶ ̶a̶ ̶s̶t̶r̶i̶n̶g̶ for data
option represent a method, else types will be stored as is.

The `unless` option also can be passed.

The `on` option can be an array:

```ruby
fires :comment_activity, :on => [:create, :update, :destroy]
```

The most flexible way is to use `fire` method:

```ruby
def destroy_projects
    self.projects.destroy_all
    fire :destroy_all, :object => false, :data => {:company_id => company_id}
end
```

If you run without `:object` option set, it will set as `self`.

Usage in controllers
--------------------

The simple one:

```ruby
fires :download
```

which will strike after download action.

The customized one:

```ruby
fires :download, :only => [:download_report, :download_file, :download_map],
                 :data => lambda{ params[:city] },
                 :if => lambda{ response.status == 200 }
```

The `fire` method can be used same way as in models, but also if type is not
set, it will be set as `action_name`, and object will try to store `@model_name`.

```ruby
def show
    @article = Article.find(params[:id])
    fire
end
```
is the same as

```ruby
def show
    @article = Article.find(params[:id])
    fire :show, :object => @article
end
```
