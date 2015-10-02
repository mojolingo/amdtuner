class TestFile
  attr_accessor :name

  def self.get(id)
    mylist = TestFile.list
    id = id.to_i
    return self.new(mylist[id]) if mylist[id]
    nil
  end

  def self.list
    Dir.chdir File.join(Adhearsion.config.platform[:root], 'samples')
    Dir['*'].sort
  end

  def self.annotated_list
    result = []
    TestFile.list.each do |f|
      file = TestFile.new(f)
      result << {
        name: file.name,
        human: file.is_human? ? true : false
      }
    end
    result
  end

  def initialize(name)
    @name = name
  end

  def path
    File.join(Adhearsion.config.amd_tuner.samples_dir, @name)
  end

  def asterisk_path
    path.gsub(/\.[a-z]*$/, '')
  end

  def is_human?
    name.match /human/
  end
end