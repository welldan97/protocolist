#Protocolist [![Build Status](https://secure.travis-ci.org/welldan97/protocolist.png?branch=master)](http://travis-ci.org/welldan97/protocolist) [![Dependency Status](https://gemnasium.com/welldan97/protocolist.png)](https://gemnasium.com/welldan97/protocolist)

Simple activity feeds solution for Rails applications. Gives a flexible way to build activity feeds infrastructure over it.

Installation
------------

Add the gem to your Gemfile and run the `bundle install` command to install it.

```ruby
gem 'protocolist'
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

Activity model has four attributes: actor("who did it"), activity_type("what
they did"), target("what they did it to") and data(additional information). Subject will be
set as current user by default.

Protocolist expects you to have `current_user` method in a
controller. See [Changing Defaults](https://github.com/welldan97/protocolist/wiki/Changing-Defaults) to change this behavior.

If creation isn't possible it will silently skip it.

Usage in models
---------------

The simplest way is just to write inside your model:

```ruby
fires :create
```

When "create" event will be triggered,  it will automatically create
Activity with current user set as actor, `:create` as type,
`self` as target and empty data.

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
    fire :destroy_all, :target => false, :data => {:company_id => company_id}
end
```

If you run without `:target` option set, it will default to `self`.

For other options see [Custom attributes usage](https://github.com/appstack/protocolist/wiki/Even-more-complicated-usage).

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
                 :data => lambda{|c| c.params[:city] },
                 :if => lambda{|c| c.response.status == 200 }
```

The `fire` method can be used same way as in models, but also if type is not
set, it will be set as `action_name`, and target will try to store `@model_instance`.

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
    fire :show, :target => @article
end
```

Usage in elsewhere
--------------------

You can also call 'fire' directly from Protocolist module. It can be useful for your rake task, etc.
Do not forget to provide 'actor' attribute.

```ruby
Protocolist.fire :sms_received, actor: account.owner, data: {text: message}
```

Contributing
------------
I would appreciate any help with gem development: pull requests, issue
posts, etc.


Also there is probably a bunch of mistakes in English grammar/spelling. Any
corrections are also appreciated, especially from native speakers.

Thanks
--------------
Protocolist was inspired by
[timeline_fu](https://github.com/jamesgolick/timeline_fu).  I used it,
but its functionality wasn't enough for me, so I made my own with
blackjack and stewardesses.



