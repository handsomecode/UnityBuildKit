class Unitybuildkit < Formula
    desc "A command line tool that generates an iOS application with an embedded Unity scene"
    homepage "https://github.com/handsomecode/UnityBuildKit"
    url "https://github.com/handsomecode/UnityBuildKit/archive/1.1.0.tar.gz"
    sha256 "eaba983c1e2c9e016cdc83e272cb9dcf2ab095a9a224883ce8c9b6b86828c462"
    head "https://github.com/handsomecode/UnityBuildKit.git"

    depends_on :xcode

    def install
        system "make", "install", "PREFIX=#{prefix}"
    end
end