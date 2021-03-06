namespace "pirate" do
  desc "Use this task to translate config/locales dictionary into pirrrrate"
  task :translate, :dir_or_file_to_translate do |t, args|
    require 'cgi'
    args.with_defaults(:dir_or_file_to_translate => "config/locales")
    translate_locale(args[:dir_or_file_to_translate])
  end
end

def translate(filename)
  en_yml = YAML::load_file(filename)
  target_filename = TalkLikeAPirate.pirate_locale + filename.match(/\/en([a-zA-Z-]*).yml/)[1]
  dirname = filename.split("/")[0..-2].join("/")
  translation = {target_filename => parse_element(en_yml).values.first}
  File.open(dirname + "/#{target_filename}.yml", 'w:utf-8') do |f|
    YAML::dump translation, f
  end
end

def translate_locale(path)
  path = "#{Rails.root}/#{path}" unless path.include? Rails.root.to_s
  return translate(path) if File.exists?(path) && path.match("/\/en([a-zA-Z-]*).yml")

  relevent_file_paths(path).each do |file_path|
    if File.directory? file_path
      translate(file_path + "/en.yml") if File.exists?(file_path + "/en.yml")
      translate_locale file_path
    elsif file_path.match("\/en([a-zA-Z-]*).yml")
      puts file_path
      translate file_path
    end
  end
end

def parse_element(element)
  case element
    when Hash
      new_hash = {}
      element.each {|k,v| new_hash[k] = parse_element(v)}
      new_hash
    when Array
      element.map {|el| parse_element(element)}
    when String
      TalkLikeAPirate.translate element
    else
      element
  end
end

def relevent_file_paths(path)
  Dir.new(path).entries.reject do |filename|
    [".", ".."].include? filename
  end.map do |filename|
    "#{path}/#{filename}"
  end
end

