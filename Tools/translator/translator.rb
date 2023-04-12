#!/usr/bin/ruby

require 'find'

class Translator
  def initialize
    # Define instance variables with default values
    @include_file_types = [".m", ".h", ".pch", ".mm", ".swift"]
    @exclude_file_names = ["Podfile"]
    @exclude_dir_names = ["Pods"]
    @rules = {
      /\bTuya(.+?)/ => 'Thing\1',
      /\bTUYA(.+?)/ => 'THING\1',
      /\bTY(.+?)/ => 'Thing\1',
      /\bty_(.+?)/ => 'thing_\1',
      /\btysdk_(.+?)/ => 'thingsdk_\1',
      /\btuya_(.+?)/ => 'thing_\1',
      /TuyaLink(.+?)/ => 'ThingLink\1',
    }

  end

  def replace_file_content(work_dir) 
    # 递归 work_dir 目录下的所有文件和目录
    Find.find(work_dir) do |path|

      # 排查不需要处理的文件和目录
      if @exclude_file_names.include?(File.basename(path))
        # puts "exclude_file_names #{path}"
        next
      end

      if @exclude_dir_names.include?(File.basename(path))
        # puts "exclude_dir_names #{path}"
        Find.prune
        next
      end

      if @include_file_types.include?(File.extname(path))
        # puts "include_file_types #{path}"
        file = File.open(path)
        content = file.read
        file.close

        replaceContent = content
        @rules.each do |key, value|
          replaceContent = replaceContent.gsub(key, value)
        end

        # 判断 replaceContent 和 content 是否相等，如果不相等，说明有替换，需要写入文件
        if content != replaceContent
          puts "repalcing.. #{path}"
                
          file = File.open(path, "w")
          file.write(replaceContent)
          file.close
        end
      end
    end        
  end

  def run(arguments) 
    work_dir = nil

    if arguments.empty?
      work_dir = Dir.pwd
    else 
      work_dir = arguments[0]
    end

    if File.exist?(work_dir) == false
      puts "#{work_dir} is not exist."
    end

    # replace_file(work_dir)
    replace_file_content(work_dir)
  end
end

Translator.new.run(ARGV)
