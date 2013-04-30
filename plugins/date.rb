# encoding: utf-8
module Octopress
  module Date
    # Названия дней недели -- контекстные и отдельностоящие
    COMMOM_DAYNAMES_RU = ["воскресенье", "понедельник", "вторник", "среда", "четверг", "пятница", "суббота"]
    DAYNAMES_RU = ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]
    ABBR_DAYNAMES_RU = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
    STANDALONE_ABBR_DAYNAMES_RU = ["вс", "пн", "вт", "ср", "чт", "пт", "сб"]

    # Названия месяцев -- сокращенные и полные, плюс отдельностоящие.
    # Не забудьте nil в начале массиве (~)
    # 
    #
    # Don't forget the nil at the beginning; there's no such thing as a 0th month
    COMMON_MONTHNAMES_RU = [nil, "января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря"]
    MONTHNAMES_RU = [nil, "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    COMMON_ABBR_MONTHNAMES_RU = [nil, "янв.", "февр.", "марта", "апр.", "мая", "июня", "июля", "авг.", "сент.", "окт.", "нояб.", "дек."]
    ABBR_MONTHNAMES_RU = [nil, "Янв.", "Февр.", "Март", "Апр.", "Май", "Июнь", "Июль", "Авг.", "Сент.", "Окт.", "Нояб.", "Дек."]
    # Returns a datetime if the input is a string
    def datetime(date)
      if date.class == String
        date = Time.parse(date)
      end
      date
    end

    # Returns an ordidinal date eg July 22 2007 -> July 22nd 2007
    def ordinalize(date)
      #date = datetime(date)
      format_date(date, "%a, %e %B %Y")
      #format_date(date, "%d %B %Y")
     # "#{date.strftime('%b')} #{ordinal(date.strftime('%e').to_i)}, #{date.strftime('%Y')}"
    end

    # Returns an ordinal number. 13 -> 13th, 21 -> 21st etc.
    def ordinal(number)
      if (11..13).include?(number.to_i % 100)
        "#{number}<span>th</span>"
      else
        case number.to_i % 10
        when 1; "#{number}<span>st</span>"
        when 2; "#{number}<span>nd</span>"
        when 3; "#{number}<span>rd</span>"
        else    "#{number}<span>th</span>"
        end
      end
    end

    # Formats date either as ordinal or by given date format
    # Adds %o as ordinal representation of the day
    def format_date(date, format)
      date = datetime(date)
      if format.nil? || format.empty? || format == "ordinal"
        date_formatted = ordinalize(date)
      else
        format.gsub!(/%a/, ABBR_DAYNAMES_RU[date.wday])
        format.gsub!(/%A/, DAYNAMES_RU[date.wday])
        format.gsub!(/%b/, ABBR_MONTHNAMES_RU[date.mon])
        format.gsub!(/%B/, COMMON_MONTHNAMES_RU[date.mon])
        date_formatted = date.strftime(format)
        #date_formatted.gsub!(/%o/, ordinal(date.strftime('%e').to_i))
      end
      date_formatted
    end

  end
end


module Jekyll

  class Post
    include Octopress::Date

    # Convert this post into a Hash for use in Liquid templates.
    #
    # Returns <Hash>
    def to_liquid
      date_format = self.site.config['date_format']
      self.data.deep_merge({
        "title"             => self.data['title'] || self.slug.split('-').select {|w| w.capitalize! || w }.join(' '),
        "url"               => self.url,
        "date"              => self.date,
        # Monkey patch
        "date_formatted"    => format_date(self.date, date_format),
        "updated_formatted" => self.data.has_key?('updated') ? format_date(self.data['updated'], date_format) : nil,
        "id"                => self.id,
        "categories"        => self.categories,
        "next"              => self.next,
        "previous"          => self.previous,
        "tags"              => self.tags,
        "content"           => self.content })
    end
  end

  class Page
    include Octopress::Date

    # Initialize a new Page.
    #
    # site - The Site object.
    # base - The String path to the source.
    # dir  - The String path between the source and the file.
    # name - The String filename of the file.
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      self.process(name)
      self.read_yaml(File.join(base, dir), name)
      # Monkey patch
      date_format = self.site.config['date_format']
      self.data['date_formatted']    = format_date(self.data['date'], date_format) if self.data.has_key?('date')
      self.data['updated_formatted'] = format_date(self.data['updated'], date_format) if self.data.has_key?('updated')
    end
  end
  module Filters
    include Octopress::Date
    def date_ru(date, format)
      format_date(date, format)
    end
  end
end