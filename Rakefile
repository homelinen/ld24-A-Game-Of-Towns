
desc "Remove the _site folder"
task :clean do
    sh 'rm -r _site'
end

desc "Create the _site Folder"
task :build => :clean do
    sh 'coffee -c js/*.coffee'
    fl = FileList['*.html', 'js/*.js', 'js/libs/*', 'img/*.png']

    flDest = fl.pathmap("_site/%p")

    sh 'mkdir -p _site/js/libs _site/img'

    count = 0
    for src in fl
        sh "cp -R #{src} #{flDest[count]}"
        count += 1
    end
end

desc "Throw the files onto a server\n
Site: url/path"
task :deploy, [:site] => :build do |t, args|
    if args.site?
        sh "rsync -uzvr _site/* #{args.site}"
    else
        puts "Require url"
    end
end
