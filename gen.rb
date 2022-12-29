require "markdown_extension"
require "liquid"
require "json"

site = MarkdownExtension::Site.new("./wiki.toml", :wiki)

Giscus_HTML = <<END
<script src="https://giscus.app/client.js"
        data-repo="zhuangbiaowei/wiki.md"
        data-repo-id="R_kgDOIkTcvA"
        data-category="General"
        data-category-id="DIC_kwDOIkTcvM4CTLWi"
        data-mapping="pathname"
        data-strict="0"
        data-reactions-enabled="1"
        data-emit-metadata="0"
        data-input-position="bottom"
        data-theme="light"
        data-lang="zh-CN"
        crossorigin="anonymous"
        async>
</script>
END

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
        'config'=>{'title'=>wiki_name}, 
        'summary_html'=>summary.html,
        'wiki_html' => page.html,
        'giscus_html'=>Giscus_HTML)
    f.close
end

if Dir.exists?("./src/assets")
    `cp -r ./src/assets ./wiki/assets`
end