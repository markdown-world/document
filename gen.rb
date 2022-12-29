require "markdown_extension"
require "liquid"
require "json"

site = MarkdownExtension::Site.new("./wiki.toml", :wiki)

wiki_name = site.config.title ? site.config.title : "My Wiki"
unless Dir.exists?("./wiki")
    Dir.mkdir("wiki")
end

site.write_data_json("./wiki/data.json")
kg_template = Liquid::Template.parse(File.read("./template/kg.liquid"))
f = File.new("./wiki/kg.html", "w")
f.puts(kg_template.render('config'=>{'title'=>wiki_name}))
f.close

summary = site.summary
template = Liquid::Template.parse(File.read("./template/wiki.liquid"))

site.pages.each do |page|
    filename = "./wiki/" + page.item_name + ".html"
    f = File.new(filename, "w")
    f.puts template.render(
        'config'=>{'title'=>wiki_name, 'giscus'=>site.config.preprocessing["giscus"]}, 
        'summary_html'=>summary.html,
        'wiki_html' => page.html,
        'giscus'=>site.config.giscus)
    f.close
end

if Dir.exists?("./src/assets")
    `cp -r ./src/assets ./wiki/assets`
end