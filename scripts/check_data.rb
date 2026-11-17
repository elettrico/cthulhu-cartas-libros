# frozen_string_literal: true

require 'squib'

root = File.expand_path('..', __dir__)
workbook = File.join(root, 'data', 'libros.xlsx')
sources = File.join(root, 'data', 'fuentes.yml')
assets = %w[backgroundg2.png coc_logo.png back_book.svg].map do |name|
  File.join(root, 'assets', name)
end

required_files = [workbook, sources, *assets]
missing_files = required_files.reject { |path| File.file?(path) }

unless missing_files.empty?
  warn 'Faltan estos archivos:'
  missing_files.each { |path| warn "  - #{path}" }
  exit 1
end

data = Squib.xlsx(file: workbook)
required_columns = %w[titulo origen idioma fecha autor estudio COR MCI MCC mitos PM ocultismo contenido hechizos]
missing_columns = required_columns.reject { |column| data[column] }

unless missing_columns.empty?
  warn "Faltan columnas en data/libros.xlsx: #{missing_columns.join(', ')}"
  exit 1
end

card_count = data['titulo'].size
column_sizes = required_columns.to_h { |column| [column, data[column].size] }
invalid_sizes = column_sizes.reject { |_column, size| size == card_count }

unless invalid_sizes.empty?
  warn "Las columnas no tienen la misma cantidad de filas: #{invalid_sizes.inspect}"
  exit 1
end

if card_count.zero?
  warn 'No hay libros en data/libros.xlsx.'
  exit 1
end

puts "OK: #{card_count} cartas, #{required_columns.size} columnas y recursos disponibles."
