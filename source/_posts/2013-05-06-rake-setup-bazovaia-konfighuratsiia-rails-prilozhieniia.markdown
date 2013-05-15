---
layout: post
title: "rake setup: Базовая конфигурация Rails приложения"
date: 2013-05-06 12:50
comments: true
categories: Программирование
keywords: programming, программирование, ruby, rake setup, ruby on rails, rake, rails, rails setup, rails4
description: How to setup Ruby On Rails application with rake setup task
---
Доброго времени суток!

Перечитывая блог [Signals Vs Noise](http://37signals.com/svn) я наткнулся на интересную [статью](http://37signals.com/svn/posts/2998-setting-up-a-new-machine-for-ruby-development).

В ней рекомендовали использовать rake для конфигурации приложения.

> `rake setup`

> All our apps has a rake setup task that’ll run bundler,
> create the databases, import seeds, and install any auxiliary
> software (little these days) or do any other setup. So when you git
> clone a new app, you know that “rake setup” will take care of you.

Склонируй приложение, запусти `rake setup` и работай. Удобно!

Я расскажу о том, как сделать подобную задачу в Ruby On Rails приложении.
<!-- more -->


Зайдем в папку с приложением и запустим  ```rake -T```. Данная команда выведет список всех задач, доступных для rake.

<pre>
rake about                            # List versions of all Rails frameworks and the environment
rake assets:clean                     # Remove old compiled assets
rake assets:clobber                   # Remove compiled assets
rake assets:environment               # Load asset compile environment
rake assets:precompile                # Compile all the assets named in config.assets.precompile
rake db:create                        # Create the database from DATABASE_URL or config/database.yml for the current Rails.env (use db:create:all to create all dbs in the config)
rake db:drop                          # Drops the database using DATABASE_URL or the current Rails.env (use db:drop:all to drop all databases)
...
</pre>

После того, как мы добавим нашу задачу, она тоже должна появиться в этом списке.

## Создаем новую Rake task

Если вы хотите создать собственную rake инструкцию у вас есть 3 варианта сделать это:

1. Написать ее самостоятельно.
2. Скопировать код с другой существующей задачи и изменить ее код.
3. Воспользоваться Rails генератором

<pre>
$ rails g task setup hello_world
</pre>

Он создаст скелет для нашей новой инструкции:

*lib/tasks/setup.rake*
``` ruby
namespace :setup do
  desc "TODO"
  task :hello_world => :environment do
  end
end
```

Убедимся что задача существует и мы можем ей воспользоваться:
<pre>
$ rake -T |grep setup
rake setup:hello_world                # TODO
</pre>

## Hello World

Пройдемся по лексемам только что созданной задачи

* ```namespace :setup```

  Namespace, оно же пространство имен - это окружение, под которым будут сгруппированы задачи.
  Примером из RoR можно привести ```rake db:migrate```, где ```db``` тоже является namespace'ом

* ```desc "TODO"```

  Описание нашей задачи. Является необязательным компонентом, но если его опустить, то задача не будет отображаться в общем списке при выводе командой ```rake -T```

* ```task :hello_world => :environment

  ```:hello_world``` - имя задачи.

  ```=> :environment``` - зависимости. Перед тем как запустить основную задачу, Rake запускает все зависимые задачи. В данном случае запустится инструкция ```rake environment```,
   которая включена в сборку RoR и позволяет работать с операциями, зависящими от окружения, например, использование базы данных.





