class UnityBuildKit < Formula
    desc "A command line tool that generates an iOS application with an embedded Unity scene"
    homepage "https://github.com/handsomecode/UnityBuildKit"
    url "https://github.com/handsomecode/UnityBuildKit/archive/0.8.0.tar.gz"
    sha256 "80ae226bcd7afbe904bf30f2b28deac8b560f88ccac35d46b12f1278304cdddb"
    head "https://github.com/handsomecode/UnityBuildKit.git"

    depends_on :xcode

    def install
        system "make", "install"
    end
end