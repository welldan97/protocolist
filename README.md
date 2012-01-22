Protocolist
===========

Simple and yet flexible Activity feeds solution for Rails
applications.

Installation
------------

Add the gem to your Gemfile and run the `bundle install` command to install it.

```ruby
gem "protocolist"
```

Run the generator to create Action model and migration.

```ruby
rails generate protocolist:install
```

Getting started
---------------

Action model has three attributes: actor, type and data. Actor will be
set as current user. Type is used to distinguish actions
between each other. And data attribute stores a serialization of
additional information.

Protocolist expects you to have `current_user` action in a controller.
See Changing Defaults to change this behavior.

Usage in models
---------------

The simplest way is to just write inside your model.

```ruby
fires :create
```

And when create event will be triggered,  it will automatically create
Action model with current user set as actor, `:create` as type, and
model id as data.

The more convenient usage:

```ruby
fires :edit, :on => :update,
             :data => :changes,
             :if => 'changes.any?'
```

The event type will be `edit`. A proc, symbol and a string for data
option represent a method, else types will be stored directly.

The `unless` option also can be passed.

The `on` option can also be an array:

```ruby
fires :comment_action, :on => [:create, :update, :destroy]
```

The most flexible way is to use `fire` method:

```ruby
def destroy_projects
    self.projects.destroy_all
    fire :destroy_all, :data => {:company_id => company}
end
```

Usage in controllers
--------------------

The simple one:

```ruby
fires :download
```

which will strike after download action.

The customized one:

```ruby
fires :download, :on => [:download_report, :download_file, :download_map],
                 :data => lambda{ params[:city] },
                 :if => lambda{ response.status == 200 }
```

The `fire` method can be used as in models, and also if type is not
set, it will be set as `action_name`, and data will try to store
`@model_name`.

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
    fire :show, data => @article
end
```
