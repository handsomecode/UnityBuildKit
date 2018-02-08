class Unitybuildkit < Formula
    desc "A command line tool that generates an iOS application with an embedded Unity scene"
    homepage "https://github.com/handsomecode/UnityBuildKit"
    url "https://github.com/handsomecode/UnityBuildKit/archive/1.1.4.tar.gz"
    sha256 "88c19c9c2e93d3283eb5f3b924d4aac05e29e7264845caf8098f11d6cb7895fb"
    head "https://github.com/handsomecode/UnityBuildKit.git"

    depends_on :xcode

    def install
        system "make", "install", "PREFIX=#{prefix}"
    end
end
