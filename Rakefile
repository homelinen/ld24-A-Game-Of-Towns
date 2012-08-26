
task :clean do
    sh 'rm -r _site'
end

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
