require 'fileutils'

desc 'Genera todas las cartas de libros'
task default: :build

task :build do
  ruby 'deck.rb'
end

desc 'Comprueba los datos y recursos necesarios'
task :check do
  ruby 'scripts/check_data.rb'
end

desc 'Borra solamente los archivos generados'
task :clean do
  FileUtils.rm_rf(Dir['output/*'])
  FileUtils.mkdir_p('output/cards')
end

