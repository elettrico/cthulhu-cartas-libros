# frozen_string_literal: true

require 'fileutils'
require 'squib'

ROOT = File.expand_path(__dir__)
OUTPUT = File.join(ROOT, 'output')
CARD_OUTPUT = File.join(OUTPUT, 'cards')
ASSETS = File.join(ROOT, 'assets')

FileUtils.mkdir_p(CARD_OUTPUT)

data = Squib.xlsx(file: File.join(ROOT, 'data', 'libros.xlsx'))

columns = %w[titulo origen idioma fecha autor estudio COR MCI MCC mitos PM ocultismo contenido hechizos]
cards = columns.to_h do |column|
  [column, data[column]]
end
card_count = cards.fetch('titulo').size
raise 'No hay libros en data/libros.xlsx' if card_count.zero?

unless cards.values.map(&:size).uniq == [card_count]
  raise 'Las columnas de data/libros.xlsx no tienen la misma cantidad de filas'
end

def present?(value)
  !value.nil? && !value.to_s.strip.empty?
end

def clean_number(value)
  number = value.to_f
  number == number.to_i ? number.to_i : number
end

metadata = cards['titulo'].each_index.map do |index|
  [cards['idioma'][index], cards['fecha'][index], cards['autor'][index]]
    .compact.map(&:to_s).reject(&:empty?).join(' · ')
end

metadata_sizes = metadata.map do |value|
  case value.length
  when 0..48 then 8.5
  when 49..60 then 7.0
  else 6.0
  end
end

origins = cards['origen'].map do |origin|
  present?(origin) ? origin.to_s : ''
end

spell_sizes = cards['hechizos'].map do |value|
  case value.to_s.length
  when 0..160 then 8.5
  when 161..220 then 7.5
  when 221..300 then 7.0
  else 6.5
  end
end

title_sizes = cards['titulo'].map do |title|
  case title.length
  when 0..34 then 16
  when 35..45 then 13.5
  when 46..58 then 11.5
  else 10
  end
end

Squib::Deck.new(
  width: '70mm',
  height: '99mm',
  cards: card_count,
  layout: File.join(ROOT, 'layout.yml'),
  config: File.join(ROOT, 'config.yml')
) do
  rect layout: :card_border
  png file: File.join(ASSETS, 'backgroundg2.png'), layout: :watermark
  rect layout: :title_band
  rect layout: :metadata_band
  text str: cards['titulo'], layout: :title, font_size: title_sizes
  text str: metadata, layout: :metadata, font_size: metadata_sizes

  text str: 'Contenido', y: '21mm', layout: :section_label
  line y1: '26mm', y2: '26mm', layout: :section_line
  text str: cards['contenido'], layout: :content

  text str: 'Hechizos sugeridos', y: '48mm', layout: :section_label
  line y1: '53mm', y2: '53mm', layout: :section_line
  text str: cards['hechizos'], layout: :spells, font_size: spell_sizes

  stats_by_card = cards['titulo'].each_index.map do |index|
    rows = []
    rows << ['Pérdida de Cordura:', cards['COR'][index].to_s] if present?(cards['COR'][index])

    if present?(cards['MCI'][index]) && present?(cards['MCC'][index])
      initial = clean_number(cards['MCI'][index])
      full = clean_number(cards['MCC'][index])
      rows << ['Mitos de Cthulhu:', "+#{initial}% / +#{full}%"]
    elsif present?(cards['mitos'][index])
      rows << ['Mitos de Cthulhu:', "+#{clean_number(cards['mitos'][index])}%"]
    end

    if present?(cards['PM'][index])
      rows << ['Puntuación de Mitos:', "#{clean_number(cards['PM'][index])}%"]
    end
    if present?(cards['ocultismo'][index])
      rows << ['Ocultismo:', "+#{clean_number(cards['ocultismo'][index])}%"]
    end
    rows << ['Estudio completo:', cards['estudio'][index].to_s] if present?(cards['estudio'][index])

    raise "Demasiadas estadísticas para #{cards['titulo'][index]}" if rows.size > 4

    rows
  end

  4.times do |index|
    labels = stats_by_card.map { |rows| rows.dig(index, 0).to_s }
    values = stats_by_card.map { |rows| rows.dig(index, 1).to_s }
    y = 75 + (index * 6)
    text str: labels, y: "#{y}mm", layout: :stat_label
    text str: values, y: "#{y}mm", layout: :stat_value
    line y1: "#{y - 1}mm", y2: "#{y - 1}mm", layout: :stat_line
  end

  rect x: 0, y: 0, width: :deck, height: :deck,
       fill_color: '#00000000', stroke_color: '#8b5e3c', stroke_width: '0.35mm'

  save_png prefix: 'front_', dir: CARD_OUTPUT
  save_pdf file: 'libros_frentes.pdf', dir: OUTPUT,
           width: '210mm', height: '297mm', margin: 0, gap: 0
end

Squib::Deck.new(
  width: '70mm',
  height: '99mm',
  cards: card_count,
  layout: File.join(ROOT, 'layout.yml'),
  config: File.join(ROOT, 'config.yml')
) do
  rect layout: :back_frame
  png file: File.join(ASSETS, 'backgroundg2.png'), layout: :watermark
  png file: File.join(ASSETS, 'coc_logo.png'), layout: :back_logo
  svg file: File.join(ASSETS, 'back_book.svg'), layout: :back_type
  text str: cards['titulo'], layout: :back_title
  line layout: :back_origin_line
  text str: origins, layout: :back_origin

  save_png prefix: 'back_', dir: CARD_OUTPUT
  save_pdf file: 'libros_dorsos.pdf', dir: OUTPUT,
           width: '210mm', height: '297mm', margin: 0, gap: 0, rtl: true
end

puts "Generadas #{card_count} cartas en #{OUTPUT}"

