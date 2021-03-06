require "erdf"
require "pathname"
require "open3"
require "sequel"
require "erb"

class Erdf::CLI
  def self.start(*args)

    if ARGV.empty?
      puts 'Error: Args missing'
      puts ' > Help'
      puts ' > ----'
      puts '   erdf file <filename> <output_file.png>'
      puts '   erdf database erde database postgres://postgres:postgres@localhost/rioosdb?search_path=shard_0,public ./schema.png <output_file.png>'
    exit
    end

    command = args.shift.strip

    case command
    when "version"
      puts 'erdf 0.6.1'
      exit
    when "file"
      file = Pathname(args.shift.strip)
      input = file.read
      text_transformer = Erdf::TextTransformer.new(input)
      hash_schema = text_transformer.to_hash
    when "database"
      url = args.shift.strip
      database_transformer = Erdf::DatabaseTransformer.new(url)
      hash_schema = database_transformer.to_hash
    else
      printf('Error: "%s"  - command not found', command)
      puts ''
      puts ' > Help'
      puts ' > ----'
      puts '   erdf file <filename> <output_file.png>'
      puts '   erdf database erde database postgres://postgres:postgres@localhost/rioosdb?search_path=shard_0,public ./schema.png <output_file.png>'
      exit
    end

    hash_transformer = Erdf::HashTransformer.new(hash_schema)
    dot_schema = hash_transformer.to_dot

    output_file = args.shift.strip

    layouted_graph, dot_log = Open3.capture3("dot -Tpng -o #{output_file}", stdin_data: dot_schema)
  end
end

class Erdf::HashTransformer
  def initialize(hash)
    @hash = hash
  end

  def to_dot
    template = File.read(File.expand_path("../template.dot.erb", __FILE__))

    schema_string = ""
    schema_string << "digraph tables {"
    schema_string << "node [shape=plaintext rankdir=LR];"

    @hash.each_pair do |table_name, table_schema|
      renderer = ERB.new(template)
      schema_string << renderer.result(binding)

      table_schema['relations'].each_pair do |column, target|
        schema_string << "#{table_name}:#{column} -> #{target['table']}:#{target['column']};"
      end
    end

    schema_string << "}"

    schema_string
  end
end

class Erdf::DatabaseTransformer
  def initialize(url)
    @url = url
  end

  def to_hash
    generated_hash = {}

    Sequel.connect(@url) do |db|
      db.tables.each do |table|
        generated_hash[table] = {}
        generated_hash[table]['columns'] = []
        generated_hash[table]['relations'] = {}

        generated_hash[table]['columns'] = db.schema(table).map(&:first)

        db.foreign_key_list(table).each do |foreign_key|
          generated_hash[table]['relations'][foreign_key[:columns].first] = {
            'table' => foreign_key[:table],
            'column' => foreign_key[:key].first
          }
        end
      end
    end

    generated_hash
  end
end

class Erdf::TextTransformer
  def initialize(text)
    @lines = text.lines
  end

  def to_hash
    generated_hash = {}
    current_table = nil

    @lines.each do |line|
      cleaned_line = line.strip

      if current_table && cleaned_line.length > 0
        generated_hash[current_table]['columns'] << cleaned_line
      end

      if cleaned_line.length == 0
        current_table = nil
      end

      if match = cleaned_line.match(/^\[(\w+)\]/)
        current_table = match[1]
        generated_hash[current_table] = {}
        generated_hash[current_table]['columns'] = []
        generated_hash[current_table]['relations'] = {}
      end

      if match = cleaned_line.match(/^(\w+):(\w+) -- (\w+):(\w+)/)
        generated_hash[match[1]]['relations'][match[2]] = { 'table' => match[3], 'column' => match[4] }
      end
    end

    generated_hash
  end
end
