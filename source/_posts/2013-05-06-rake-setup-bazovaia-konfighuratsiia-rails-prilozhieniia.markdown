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

В ней рекомендовали создать rake задачу, которая полностью подготовит ваше приложение к разработке после клонирование из репозитория.

> `rake setup`

> All our apps has a rake setup task that’ll run bundler,
> create the databases, import seeds, and install any auxiliary
> software (little these days) or do any other setup. So when you git
> clone a new app, you know that “rake setup” will take care of you.

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

После того, как мы добавим нашу задачу, она тоже появится в этом списке.

## Создаем новую Rake task

Если вы хотите создать собственную rake инструкцию у вас есть 3 варианта сделать это:

1. Написать ее самостоятельно.
2. Скопировать код с другой существующей задачи и изменить ее код.
3. Воспользоваться Rails генератором.

Воспользуемся 3им пунктом.
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

## Hello World

Пройдемся по лексемам только что созданной задачи

* ```namespace :setup```

  Namespace, оно же пространство имен - это окружение, под которым будут сгруппированы задачи.
  Примером из RoR можно привести ```rake db:migrate```, где ```db``` тоже является namespace'ом

* ```desc "TODO"```

  Описание нашей задачи. Является необязательным компонентом, но если его опустить, то задача не будет отображаться в общем списке при выводе командой ```rake -T```

* ```task :hello_world => :environment```

  ```:hello_world``` - имя задачи.

  ```=> :environment``` - зависимости. Перед тем как запустить основную задачу, Rake запускает все зависимые задачи. В данном случае запустится инструкция ```rake environment```,
   которая включена в сборку RoR и позволяет работать с операциями, зависящими от окружения, например, использование базы данных.

Поприветствовать мир через rake будет просто. Добавим в тело задачи ``` puts 'Hello from rake!' ``` и запустим ее
<pre>
$ rake setup:hello_world
Hello from rake!
</pre>

## Invoke

Rake позволяет вызвать одну задачу из другой с помощью метода ```invoke```, например:

<pre> Rake::Task['db:drop'].invoke </pre>

Это дает возможность создать ряд инструкций, которые с помощью Rails задач подготовят нашу базу к работе:

```
task :drop_database do
  puts "*** Drop old database ***"
  Rake::Task['db:drop'].invoke
end

task :create_database do
  puts "*** Create new database ***"
  Rake::Task['db:create'].invoke
end

task :migrate_database do
  puts "*** Do migrations ***"
  Rake::Task['db:migrate'].invoke
end

task :seed_database do
  puts "*** Seeding database ***"
  Rake::Task['db:seed'].invoke
end

task :create_test_database do
  puts "*** Setup test database ***"
  Rake::Task['db:test:prepare'].invoke
end
```

Мы удаляем старую базу, создаем новую, выполняем все миграции, добавляем начальные данные, и создаем базу для тестов. Это стандартные действия, которые делает каждый разработчик при установке приложения.

## Работа с моделями

Внутри задачи мы можем работать с моделями точно так же, как в любом месте Rails приложения.

В моем приложении существует модель ```User```, в которой есть метод для добавления админской роли. В файле ```seeds.rb``` 
так же присутствует запись для создания пользователя в базе. Мне нужно сделать так, чтобы этот созданный пользователь сразу
был администратором, и мне не приходилось вызывать для него метод вручную через Rails консоль. Реализовать это просто:
```
task :set_admin_user do
  puts "*** Add admin role to first user ***"
  User.first.become_admin!
end
```

## Собираем все вместе

Допишем в конце файла (вне блока ```namespace :setup```) следующую инструкцию:
```
desc 'Configure the application for development.'
task :setup => :environment do
  Rake::Task['setup:drop_database'].invoke
  Rake::Task['setup:create_database'].invoke
  Rake::Task['setup:migrate_database'].invoke
  Rake::Task['setup:seed_database'].invoke
  Rake::Task['setup:set_admin_user'].invoke
  Rake::Task['setup:create_test_database'].invoke
end
```

## Запуск!

<pre>
$ rake setup
*** Drop old database ***
*** Create new database ***
*** Do migrations ***
...
...
*** Seeding database ***
*** Add admin role to first user ***
*** Setup test database ***
</pre>

Все прошло как и было задумано! Поздравляю!

## Заключение

После создания данной rake задачи на вас ложится еще одна ответственность - держать этот файл в актуальном состоянии, не забывайте про это.

И помните - вы не единственный разработчик. Если какая-то деталь кажется вам очевидной, то другой может потерять много времени
до того как поймет как с ней работать. Старайтесь упростить разработку не только себе, но и коллегам.
